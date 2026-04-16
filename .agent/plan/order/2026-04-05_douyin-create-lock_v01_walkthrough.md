# walkthrough

## 变更内容
- 在 `DouyinChannelAdapter.handleCreateOrder` 方法上新增：
  - `@DistributedLock(keyPrefix = "ORDER:CREATE:DOUYIN:", lockKey = "#request.orderId")`
- 新增 `DistributedLock` import。

## 设计说明
- 锁放在抖音适配层，而不是核心 `OrderService.createOrder`：
  - 幂等键 `request.orderId` 属于渠道语义。
  - 内部订单不依赖 `channelOrderNo`，不适合把该锁下沉到核心层。
- 当前方法内已包含：
  - 外部单号查重
  - 创单
  - 支付后创单补偿
  因此加在方法级可以把整段流程纳入同一锁域。

## 后续建议
- 该方案属于短期增强，后续仍建议补充：
  - 支付回调失败后的重查状态闭环
  - 发券侧业务门闩
  - 渠道幂等记录表
