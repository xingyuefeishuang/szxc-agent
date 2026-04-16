# 订单 Redis 锁前缀口径修正实施计划

## 目标

- 将内部订单资源锁前缀收回到既定口径
- 避免代码、设计和排障口径出现大小写与层级不一致

## 实施步骤

1. 修正 `OrderRedisKeyConstant.INTERNAL_ORDER_RESOURCE_LOCK_PREFIX`
2. 将前缀改回 `PLT:ORDER:LOCKER:`
3. 保持其余 key 暂不扩散修改，避免本次变更范围失控

## 边界

- 本次只修正内部订单资源锁前缀
- 其他 Redis key 风格统一问题后续再统一收口
