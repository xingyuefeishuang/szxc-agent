# 订单门面边界拆分实施计划

## 背景
- `OrderServiceImpl.createOrder(...)` 中存在金额一致性校验、可售/库存预占等商品域职责。
- `OrderServiceImpl.handlePayCallback(...)` 中存在固定发码并推进履约的履约域职责。
- 继续把这些逻辑直接留在订单主流程里，会导致订单域长期耦合商品域和履约域细节。

## 实施方案
1. 扩展订单侧商品能力门面：
   - 新增 `validateAmountsOnCreate(...)`
   - 由 `createOrder(...)` 统一调用
2. 新增订单履约门面：
   - 定义 `fulfillAfterPaid(Order order)`
   - 由 `handlePayCallback(...)` 统一调用
3. 默认实现先沿用现有行为：
   - 商品门面仍是空实现 + TODO
   - 履约门面默认仍发码并推进 `DELIVERING`

## 边界说明
- 本次不改变现有业务结果，只改变责任归属与调用边界。
- 后续接入商品域、库存域、实物发货或人工履约时，优先替换门面实现。
