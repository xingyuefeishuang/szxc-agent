# 抖音景区 SPI 结构重组实施计划 v12

## 背景

当前抖音代码仍以单一 `DouyinSpiController + DouyinChannelAdapter` 组织，SPI 入口、方案编排和公共逻辑混在一起，目录表达不出景区团购与景区日历票这两套解决方案。

## 目标

1. 保持所有抖音 SPI URL 继续以 `/spi/douyin/**` 开头。
2. 代码层面按场景拆出独立的 `spi/scenic` 入口类。
3. 去掉 `channel/douyin/adapter` 目录，逻辑迁入 `channel/douyin/solution`。
4. 在 `solution/scenic` 下按类名区分：
   - `ScenicGroupbuy...`
   - `ScenicCalendarTicket...`
5. 抽出抖音 SPI 公共验签服务。

## 计划改动

### 1. SPI 分层

- 新增 `channel/douyin/spi/common/DouyinSpiSignatureService`
- 新增 `channel/douyin/spi/scenic/ScenicGroupbuySpiController`
- 新增 `channel/douyin/spi/scenic/ScenicCalendarTicketSpiController`
- 删除旧的 `DouyinSpiController`

### 2. Solution 分层

- 将原 `DouyinChannelAdapter` 迁移到 `channel/douyin/solution/common/DouyinScenicSolutionSupport`
- 保留原有核心逻辑，先作为景区方案公共支撑
- 新增 `solution/scenic` 下两个薄编排类：
  - `ScenicGroupbuyDouyinSolution`
  - `ScenicCalendarTicketDouyinSolution`

### 3. 渠道回写接口兼容

- `DouyinScenicSolutionSupport` 继续实现 `OrderChannelAdapter`
- 保持核销回写、退款审核回写与事件监听链路不受影响

### 4. 兼容修正

- `OrderController.payCallback(...)` 补齐新的 `FulfillmentPolicy` 入参
- 更新旧注释中对 `DouyinSpiController` 的引用

## 验证计划

1. 搜索确认旧 `adapter` 包和旧 `DouyinSpiController` 无引用残留。
2. 编译 `plt-core-service/plt-order-service`：
   - `mvn clean compile -DskipTests`
3. 校验归档命名：
   - `powershell -ExecutionPolicy Bypass -File .agent/workflows/plan-archive/validate-plan-archive.ps1 -Mode strict`
