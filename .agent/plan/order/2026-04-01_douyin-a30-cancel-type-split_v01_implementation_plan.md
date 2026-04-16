# 抖音 A30 取消通知分流实施计划

## 背景
- `A30` 文档明确区分 `cancel_type=1 BeforePay`、`2 AfterPay`、`3 External`。
- 通知类接口要求不要返回业务错误，只在系统异常时返回可重试错误码。
- 当前实现把所有取消通知都试图映射成内部 `cancelOrder`，语义不够精确。

## 实施目标
- `BeforePay`：仅在内部订单仍为 `PENDING` 时执行取消。
- `AfterPay`：不再直接映射成内部 `cancelOrder`，只记录外部支付后取消事件，避免把已支付订单回退为 `CANCELED`。
- `External`：按“第三方创单失败/撤销”语义处理，仍只允许取消 `PENDING` 单。
- 查单优先使用 `order_out_id`，找不到再回退 `order_id`。
- 保持通知接口返回成功，不对外抛业务错误。

## 具体改动
1. 在 `DouyinChannelAdapter` 增加 `cancel_type` 常量与判定辅助方法。
2. 重写 `handleCancelOrder` 的分支逻辑：
   - `BeforePay/External` 且状态为 `PENDING`：执行 `orderService.cancelOrder`
   - `BeforePay/External` 且状态非 `PENDING`：记录非法取消通知并成功返回
   - `AfterPay`：仅记录，不修改内部状态
3. 新增 `findOrderForCancelRequest`，优先 `order_out_id` 查单。
4. 保留原有步骤注释、业务注释和 TODO，不做删减。

## 验证
- 使用 JDK 17 编译 `plt-core-service/plt-order-service`。
- 目标是验证 `DouyinChannelAdapter` 改造后编译通过且不影响现有链路。
