# 发券幂等门闩工作总结

## 本次改动
- 在 `OrderRedisKeyConstant` 新增 `ORDER_VOUCHER_ISSUE_LOCK_PREFIX` 常量。
- 在 `VoucherServiceImpl.issueVouchers(Long orderId)` 增加：
  - `@DistributedLock(keyPrefix = OrderRedisKeyConstant.ORDER_VOUCHER_ISSUE_LOCK_PREFIX, lockKey = "#orderId")`
  - 锁内空子项保护
  - 锁内基于 `orderNo` 的二次幂等检查
  - 命中已有凭证时直接返回已发放凭证码

## 结果
- 同一订单的并发发券请求会先按 `orderId` 串行化。
- 第二个进入的请求在锁内会看到已生成的凭证，直接复用结果，不再重复落库。

## 未覆盖事项
- Redis 锁不是最终真相源；若需要更强恢复能力，后续仍应补数据库级发券门闩。
- 未补自动化测试，本次结论基于静态代码修改与链路分析。
