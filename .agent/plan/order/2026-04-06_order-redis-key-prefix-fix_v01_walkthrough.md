# 订单 Redis 锁前缀口径修正工作总结

## 本次修改

- `OrderRedisKeyConstant.INTERNAL_ORDER_RESOURCE_LOCK_PREFIX`
  - 从 `plt:order:resource:locker:`
  - 调整为 `PLT:ORDER:LOCKER:`

## 结果

- 内部订单资源锁重新回到已确认口径
- `cancel/payCallback/refund apply` 三个入口共享的资源锁前缀与设计说明重新一致
