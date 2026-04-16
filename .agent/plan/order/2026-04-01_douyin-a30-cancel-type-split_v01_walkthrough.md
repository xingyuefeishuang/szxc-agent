# 抖音 A30 取消通知分流总结

## 本次完成内容
- `DouyinChannelAdapter.handleCancelOrder` 已按 `cancel_type` 分流。
- `BeforePay` 与 `External` 只在内部订单仍为 `PENDING` 时才执行 `cancelOrder`。
- `AfterPay` 不再尝试把已支付订单回退成 `CANCELED`，当前先记录日志并成功返回。
- 取消通知查单已改为优先使用 `order_out_id`，找不到再用抖音 `order_id`。

## 关键结论
- 这次调整与 `A30` 文档一致：
  - 通知类接口不返回业务错误
  - 协议允许 `AfterPay`
- 统一订单中心内部状态机仍保持不变：
  - 已支付及之后状态不能走 `cancelOrder`
  - 支付后取消的最终落点仍应回到退款/售后链路

## 验证结果
- 已使用 JDK 17 编译通过 `plt-core-service/plt-order-service`。

## 后续建议
- 当开始补退款主链路时，把 `AfterPay` 对应的外部取消事件正式接入退款单或订单扩展记录，而不是只打日志。
