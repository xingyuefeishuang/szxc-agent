# 内部订单资源锁统一实施计划

## 目标

- 将内部订单相关入口锁统一收敛为同一把订单资源锁
- 锁前缀统一为 `PLT:ORDER:LOCKER:`
- 让同一订单的取消、支付回调、退款申请共享同一锁键

## 实施步骤

1. 将内部订单锁常量统一收敛为 `INTERNAL_ORDER_RESOURCE_LOCK_PREFIX`
2. `OrderController.cancel(...)` 改用统一订单资源锁
3. `OrderController.payCallback(...)` 改用统一订单资源锁
4. `RefundController.apply(...)` 接入同一把 `orderNo` 资源锁

## 边界

- 本次只覆盖直接带 `orderNo` 的入口
- `RefundController.audit/callback` 因当前不直接带 `orderNo`，暂不强行接入同锁
