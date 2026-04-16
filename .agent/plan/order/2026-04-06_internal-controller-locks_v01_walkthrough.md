# 内部 Controller 请求级锁工作总结

## 本次改动
- `OrderController.cancel(...)` 增加按 `orderNo` 的分布式锁。
- `OrderController.payCallback(...)` 增加按 `orderNo` 的分布式锁。
- `OrderController.create(...)` 注释调整为：
  - 当前由网关统一处理内部创建请求级幂等/锁
  - Controller 层不在缺少稳定业务键时补伪锁
- `OrderRedisKeyConstant` 新增：
  - `INTERNAL_ORDER_CANCEL_LOCK_PREFIX`
  - `INTERNAL_ORDER_PAY_CALLBACK_LOCK_PREFIX`
- 在 `.agent/designs/order` 新增锁分层约定文档。

## 后续收敛说明

- 上述两个早期常量前缀后续已被统一订单资源锁前缀取代：
  - `PLT:ORDER:LOCKER:`
- 最新口径以：
  - [2026-04-06_internal-order-resource-lock_v01_implementation_plan.md](D:/08-Work/01-博思/10-平台2.0/.agent/plan/order/2026-04-06_internal-order-resource-lock_v01_implementation_plan.md)
  - [2026-04-06_internal-order-resource-lock_v01_walkthrough.md](D:/08-Work/01-博思/10-平台2.0/.agent/plan/order/2026-04-06_internal-order-resource-lock_v01_walkthrough.md)
  为准。

## 结果
- 内部取消与内部支付回调的同订单并发请求已在 Controller 层先被串行化。
- 锁分层约定从注释提升为设计文档，后续补锁时有明确依据。

## 未覆盖事项
- 内部创建请求仍依赖网关统一锁/幂等。
- 未执行自动化测试，本次结论基于静态代码修改。
