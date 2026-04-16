# 退款渠道流水号落库工作总结

## 本次修改

- `RefundApply` 增加 `channelRefundNo`
- `RefundBO` 增加 `channelRefundNo`
- `o_refund_apply` 设计 SQL 增加 `channel_refund_no`
- 退款成功回调时将 `channelRefundNo` 写入退款单

## 当前行为

- 通过 `/api/core/refund/callback` 进入的退款成功回调，若携带 `channelRefundNo`，会同步落库
- `completeRefundByOrderNo(orderNo, remark)` 由于没有渠道流水号入参，当前仍不会写该字段
