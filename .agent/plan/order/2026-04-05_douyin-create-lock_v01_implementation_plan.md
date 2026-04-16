# implementation_plan

## 基本信息
- 模块: `order`
- featureKey: `douyin-create-lock`
- 日期: `2026-04-05`

## 目标
- 为抖音创单入口增加基于外部订单号的 Redis 分布式锁。
- 保持锁位于渠道适配层，不下沉到核心 `OrderService.createOrder`。

## 方案选择
- 采用短期方案：
  - `Redis 分布式锁 + 锁内查重`
- 暂不引入幂等记录表。
- 暂不修改数据库唯一索引。

## 实施要点
1. 查阅现有 `@DistributedLock` 注解定义与项目内用法。
2. 在 `DouyinChannelAdapter.handleCreateOrder` 方法增加锁注解。
3. key 使用 `request.orderId`，前缀为 `ORDER:CREATE:DOUYIN:`。
4. 保持现有“查重 + 创单 + 支付后补偿”逻辑处于同一方法锁域中。

## 约束
- 不改现有中文注释内容。
- 不使用 PowerShell 写回源码。
