# 发券幂等门闩实施计划

## 背景
- `VoucherServiceImpl.issueVouchers` 当前没有服务内幂等保护。
- 调用方虽然会先做 `hasIssuedVouchers(orderNo)` 判断，但这是锁外预判，并发下仍可能重复发券。

## 实施方案
1. 在订单 Redis Key 常量类中新增发券锁前缀。
2. 在 `VoucherServiceImpl.issueVouchers(Long orderId)` 增加分布式锁，锁粒度为 `orderId`。
3. 在锁内查询订单子项并提取 `orderNo`。
4. 若锁内发现该订单已存在凭证，则直接返回已发放的凭证码列表。
5. 若未发现历史凭证，则继续沿用现有发券逻辑逐张生成凭证。

## 边界说明
- 本次不改表结构，不新增“发券中/已发券”状态字段。
- 本次不调整调用方 `DouyinChannelAdapter` 的预判逻辑，只把正确性收敛到服务层。
- 该方案属于短期并发门闩；长期仍建议补数据库级业务门闩或幂等记录。
