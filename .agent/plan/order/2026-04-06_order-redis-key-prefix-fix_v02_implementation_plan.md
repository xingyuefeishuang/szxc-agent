# 订单 Redis Key 前缀风格统一实施计划

## 目标

- 将 `OrderRedisKeyConstant` 中剩余前缀统一收口到 `PLT:ORDER:*` 风格
- 避免平台资源锁、发券锁、抖音幂等 key 出现大小写和命名前缀混用

## 实施步骤

1. 保留 `INTERNAL_ORDER_RESOURCE_LOCK_PREFIX = PLT:ORDER:LOCKER:`
2. 将发券锁前缀调整为 `PLT:ORDER:VOUCHER:ISSUE:`
3. 将抖音创单锁前缀调整为 `PLT:ORDER:DOUYIN:CREATE:`
4. 将抖音退款审核/通知幂等前缀调整为：
   - `PLT:ORDER:DOUYIN:REFUND:APPLY:`
   - `PLT:ORDER:DOUYIN:REFUND:NOTIFY:`

## 边界

- 本次只统一常量值，不改常量命名
- 不扩散调整其他模块 Redis key 风格
