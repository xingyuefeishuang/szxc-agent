# 退款渠道流水号落库实施计划

## 目标

- 将 `channelRefundNo` 正式落到退款单模型中
- 在退款成功回调时持久化支付中心/渠道退款流水号

## 实施步骤

1. 给 `RefundApply` 增加 `channelRefundNo`
2. 给 `RefundBO` 增加 `channelRefundNo`
3. 更新 `o_refund_apply` 设计 SQL
4. 调整 `RefundApplyServiceImpl.handleRefundCallback(...)`
5. 在 `completeRefund(...)` 中写入 `channelRefundNo`

## 边界

- 本次只处理退款成功回调落库
- `completeRefundByOrderNo(...)` 这条按订单号推进的链路暂不补渠道流水号
