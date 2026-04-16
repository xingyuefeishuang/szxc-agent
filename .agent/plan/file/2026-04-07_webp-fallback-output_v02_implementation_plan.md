# implementation_plan

## task
将 `plt-file` 的 WebP 图片处理链路调整为“优先按原格式写出，写失败时自动降级为 png”。

## steps
1. 检查 `FastDfsOssServiceImpl` 当前处理后图片输出逻辑。
2. 将处理后主图与缩略图的输出改为优先使用原始扩展名。
3. 在 `ImageIO.write` 不支持目标格式时，自动降级为 `png`，避免上传链路中断。
4. 归档本次实施结果与最终行为。
