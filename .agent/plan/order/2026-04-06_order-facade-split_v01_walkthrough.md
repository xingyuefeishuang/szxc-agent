# 订单门面边界拆分工作总结

## 本次改动
- 扩展 `OrderProductFacadeService`：
  - 新增 `validateAmountsOnCreate(...)`
- 新增 `OrderFulfillmentFacadeService` 与默认实现 `OrderFulfillmentFacadeServiceImpl`
- `OrderServiceImpl.createOrder(...)` 现在统一通过商品门面处理：
  - 金额一致性校验入口
  - 可售/库存预占入口
- `OrderServiceImpl.handlePayCallback(...)` 现在统一通过履约门面处理支付后的履约动作

## 结果
- 支付回调不再直接硬编码“发码 + 进入履约”细节，订单主流程只保留“支付成功后交给履约门面”。
- 订单主流程中与商品域相关的 TODO 被收敛到商品门面中，后续接商品域时不必再回改订单主流程调用点。

## 未覆盖事项
- 商品门面和履约门面当前仍是默认实现/空实现。
- 未补自动化测试，本次结论基于静态代码修改。
