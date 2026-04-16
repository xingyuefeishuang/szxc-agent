# 履约门面策略化骨架实施计划

## 背景
- 已经确定支付回调后的履约逻辑不应继续硬编码在 `OrderServiceImpl.handlePayCallback(...)` 中。
- 当前 `OrderFulfillmentFacadeServiceImpl` 仍是单默认实现，不利于后续扩展发码履约、不立即履约、实物发货等模式。

## 实施方案
1. 保留统一的 `OrderFulfillmentFacadeService` 作为对外入口。
2. 新增策略接口 `OrderFulfillmentStrategy`。
3. 新增履约类型枚举 `OrderFulfillmentType`，先保留：
   - `VOUCHER`
   - `NONE`
4. 落两个策略实现：
   - `VoucherOrderFulfillmentStrategy`
   - `NoopOrderFulfillmentStrategy`
5. 门面内部先按默认逻辑回退到 `VOUCHER`，并在注释中明确后续应按 `o_spu_rule.fulfillment_type` 路由。

## 边界说明
- 本次只搭策略骨架，不引入真实履约类型路由。
- 本次不改数据库结构。
