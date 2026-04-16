# 抖音景区 SPI 结构重组实施总结 v12

## 实施结果

本轮已将抖音景区 SPI 从“单 controller + 单 adapter”重组为“按场景拆 SPI、按 solution 组织编排”的结构，同时保留了 `/spi/douyin/**` 作为统一对外前缀。

## 结构调整

### 1. SPI 入口拆分

新增：

- `channel/douyin/spi/common/DouyinSpiSignatureService`
- `channel/douyin/spi/scenic/ScenicGroupbuySpiController`
- `channel/douyin/spi/scenic/ScenicCalendarTicketSpiController`

删除：

- `channel/douyin/spi/DouyinSpiController`

### 2. Solution 迁移

原 `channel/douyin/adapter/DouyinChannelAdapter` 已迁移为：

- `channel/douyin/solution/common/DouyinScenicSolutionSupport`

并新增两个景区方案编排类：

- `channel/douyin/solution/scenic/ScenicGroupbuyDouyinSolution`
- `channel/douyin/solution/scenic/ScenicCalendarTicketDouyinSolution`

当前做法是：

- 团购/日历票入口已分开
- 共享逻辑先沉到 `DouyinScenicSolutionSupport`
- 后续如果景区方案内部继续变复杂，再从 support 中继续细拆

### 3. 兼容修正

- `OrderController.payCallback(...)` 已补齐 `FulfillmentPolicy.IMMEDIATE`
- 渠道回写接口仍由 `DouyinScenicSolutionSupport` 实现 `OrderChannelAdapter`，避免影响现有退款审核/核销回写链路

## 验证结果

### 编译

已执行：

```powershell
$env:JAVA_HOME='D:\05-Development\jdk-17'; mvn clean compile -DskipTests
```

目录：

```text
plt-core-service/plt-order-service
```

结果：

- `plt-order-api` 成功
- `plt-order-core` 成功
- `BUILD SUCCESS`

### 其他检查

- 搜索未发现旧 `DouyinSpiController`、`channel/douyin/adapter` 的代码引用残留
- 本地 Maven 仓库 tracking file 权限告警依旧存在，但未影响本次构建
