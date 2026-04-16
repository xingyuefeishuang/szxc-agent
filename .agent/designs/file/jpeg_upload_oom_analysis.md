# plt-file JPEG 上传 OOM 问题分析

## 背景
前端将图片压缩为 `jpeg` 后，通过 `plt-file` 文件上传接口上传到文件服务时，服务返回以下异常：

```json
{
  "errorShowType": "2",
  "code": "B000001",
  "errorSource": "dv-file-center",
  "errorMessage": "Handler dispatch failed; nested exception is java.lang.OutOfMemoryError: Java heap space",
  "message": "服务异常,请稍后再试!",
  "errorTraceId": "6271d882d030d745",
  "success": false
}
```

同一批图片若压缩为 `webp` 再上传，则通常不会报错。

## 初步结论
该问题优先判定为 `plt-file` 服务端上传链路的内存使用问题，不是前端 JPEG 编码本身错误，也不是 FastDFS 服务端单点异常。

更准确地说：
- `jpeg` 会进入服务端“图片识别 + 缩略图生成 + 再次缩放上传”的图片处理分支；
- `webp` 在当前实现和依赖能力下，大概率不会被 `ImageIO.read(...)` 识别为图片，因此只走普通文件上传分支；
- 两条分支的内存占用差异明显，`jpeg` 分支更容易触发 `java.lang.OutOfMemoryError: Java heap space`。

## 涉及代码
- `plt-comm-service/plt-file-service/plt-file-core/src/main/java/cn/com/bsszxc/plt/file/service/impl/FastDfsOssServiceImpl.java`
- `plt-comm-service/plt-file-service/plt-file-core/src/main/java/cn/com/bsszxc/plt/file/common/utils/FileUtil.java`
- `plt-comm-service/plt-file-service/plt-file-core/src/main/java/cn/com/bsszxc/plt/file/service/impl/AbstractFileService.java`

## 问题链路分析

### 1. JPEG 命中图片处理分支
`FastDfsOssServiceImpl.uploadFile(...)` 中存在如下逻辑：

```java
byte[] bytes = FileUtil.readInputStream(file.getInputStream());
if (ImageIO.read(file.getInputStream()) != null) {
    ...
    fileInfo.setFileUrl(getFileUrl(bytes, extensionName));
}
```

这意味着：
- 上传文件会先被整体读入内存，形成一份完整 `byte[]`；
- 对于可被 `ImageIO` 正常识别的图片，再进入图片专用处理逻辑；
- `jpeg/jpg` 基本都会命中这条分支。

### 2. 图片分支存在重复解码与重复上传
图片分支内至少包含以下高内存操作：

1. `FileUtil.readInputStream(...)`
   - 将整个上传文件完整读入内存；
   - 对于大图，首先产生一份完整 `byte[]`。

2. `ImageIO.read(file.getInputStream())`
   - 将图片解码为 `BufferedImage`；
   - 解码后占用与像素数量直接相关，而不是仅与文件体积相关。

3. `storageClient.uploadImageAndCrtThumbImage(...)`
   - 上传原图并创建一份缩略图。

4. `getFileUrl(bytes, extensionName)`
   - 再次基于 `byte[]` 构造输入流；
   - 再次 `ImageIO.read(...)` 解码图片；
   - 再次根据宽高生成缩略图并上传。

即：同一张 `jpeg` 图片在单次上传中可能经历“整文件读入 + 多次解码 + 多次上传/缩略图处理”。

### 3. 为什么 webp 常常不报错
当前服务依赖 JDK 默认 `ImageIO` 能力，通常对 `webp` 支持不完整。

因此 `ImageIO.read(file.getInputStream())` 对 `webp` 可能直接返回 `null`，随后走到普通文件上传分支：

```java
storageClient.uploadFile(file.getInputStream(), file.getSize(), extensionName, null);
```

这条路径不会执行额外的图片解码和缩略图逻辑，堆内存压力显著更低，所以表现为：
- `jpeg` 容易 OOM；
- `webp` 不容易 OOM。

## 根因判断
根因是服务端将 `jpeg` 作为图片进行同步处理时，采用了高内存实现：

- 全量读入文件到 `byte[]`
- 对同一张图片重复 `ImageIO.read(...)`
- 同步生成多个图片衍生物
- 未对图片像素尺寸做前置限制

因此问题本质不是“JPEG 格式不兼容”，而是“JPEG 被识别后进入了高内存图片处理链路”。

## 风险特征
该问题和“文件大小”不是一一对应关系，更容易由“高分辨率图片”触发。

典型风险场景：
- 手机原图或超大分辨率图片；
- 前端虽然做了 JPEG 压缩，但只是降低文件体积，没有显著降低像素尺寸；
- 多个并发上传请求同时进入图片处理分支；
- `dv-file-center` 的 JVM 堆空间设置较小。

## 建议修复方向

### 方案一：最小风险修复
1. 在服务端增加图片宽高上限校验，只允许合理范围内的像素尺寸进入图片处理逻辑。
2. 超过阈值时直接拒绝上传，或按普通文件处理，不生成缩略图。
3. 临时提高 `dv-file-center` 的 JVM 堆参数，仅作为缓解措施，不作为根治方案。

### 方案二：推荐修复
1. 去掉 `FileUtil.readInputStream(...)` 的整文件全量读入。
2. 避免对同一张图片重复 `ImageIO.read(...)`。
3. 将图片元数据读取、缩略图生成与原图上传解耦。
4. 大图缩略图生成改为异步任务，不阻塞上传接口。
5. 对图片处理链路增加明确的分辨率、像素总量、单文件大小三重限制。

### 方案三：格式策略优化
1. 明确系统是否需要把 `webp` 视为“图片文件”处理。
2. 若需要支持 `webp` 缩略图和元数据解析，则引入对应的 ImageIO 插件，并同步评估内存开销。
3. 若不需要，则统一将 `webp` 作为普通文件上传，避免出现不同格式行为不一致但无文档说明的问题。

## 排查与验证建议
1. 记录出问题 JPEG 的文件大小、宽高、像素总数。
2. 结合 OOM 日志确认堆栈是否落在以下调用附近：
   - `ImageIO.read`
   - `uploadImageAndCrtThumbImage`
   - `getFileUrl`
3. 使用同一张源图分别导出为 `jpeg` 和 `webp` 进行对照上传，验证是否存在稳定的分支差异。
4. 压测高分辨率 JPEG 并观察 `dv-file-center` 堆内存曲线，验证是否存在瞬时大对象堆积。

## 结论
本次问题可归档为：

`plt-file` 文件上传服务在 FastDFS 存储模式下，对 JPEG 图片采用了高内存的同步图片处理链路，导致高分辨率图片上传时出现 `Java heap space`；而 webp 因未进入同等处理分支，所以通常不会复现该异常。`
