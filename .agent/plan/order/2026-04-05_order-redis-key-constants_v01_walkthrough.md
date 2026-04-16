# walkthrough

## 本次调整
- 新增常量类：
  - `OrderRedisKeyConstant`
- 收敛的 key 前缀包括：
  - 抖音创单分布式锁前缀
  - 抖音退款审核幂等 key 前缀
  - 抖音退款结果通知幂等 key 前缀

## 代码替换点
- `DouyinChannelAdapter.handleCreateOrder` 的 `@DistributedLock.keyPrefix`
- `buildApplyIdempotentKey`
- `buildNotifyIdempotentKey`

## 结果
- `order` 模块已实际使用的 Redis key 不再散落在业务方法中。
- 常量统一放置在 `plt-order-api` 的 `constant` 包，便于 `core` 与后续其他调用方复用。

## 说明
- 本次未处理注释里的示例字符串（例如 TODO 注释中的 `ORDER_STOCK:`），仅处理实际参与运行的 key。
- 其他服务模块中的 Redis key 未纳入本次改动范围。
