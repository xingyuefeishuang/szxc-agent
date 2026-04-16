# 订单履约门面统一命令收敛实施计划

## 目标

将抖音发码履约接入 `OrderFulfillmentFacadeService`，但保持渠道 DTO 留在 `channel` 防腐层，核心层统一基于内部履约命令执行。

## 实施项

1. 为订单履约新增统一命令与结果模型：
   - `OrderFulfillmentCmd`
   - `OrderFulfillmentScene`
   - `OrderFulfillmentResult`
2. 改造 `OrderFulfillmentFacadeService` 与 `OrderFulfillmentStrategy`：
   - 门面新增 `fulfill(cmd)` 统一入口
   - 保留 `fulfillAfterPaid(order)` 兼容支付回调入口
   - 策略改为按 `fulfillmentType + scene + order` 选择
3. 拆分券类履约策略：
   - 自有渠道支付后即时发券
   - OTA 渠道支付后仅推进到履约中
   - 渠道回调触发发券
   - `NONE` 履约保持支付后不立即履约
4. 调整抖音适配器：
   - 保留 DTO 解析、支付前校验、响应组装
   - 将 B11/A21 发码动作改为调用履约门面
5. 进行最小范围编译验证并归档结果

## 验证点

- `OrderService.handlePayCallback` 仍只依赖履约门面，不感知渠道协议
- 抖音团购/日历票发码改走统一履约入口
- `plt-order-service` 执行 `clean compile -DskipTests` 通过

## 默认假设

- OTA 渠道支付成功后先进入 `DELIVERING`，发码由渠道回调补齐
- 当前仍不支持同一订单混合多种履约类型
- 渠道原始 DTO 不进入核心 `service` 层
