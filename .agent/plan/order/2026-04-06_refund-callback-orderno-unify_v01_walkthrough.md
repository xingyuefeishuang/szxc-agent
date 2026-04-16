# 退款回调按订单号兼容统一工作总结

## 本次修改

- `RefundCallbackDO` 增加 `orderNo`
- 增加 `refundNo/orderNo` 至少传一项的校验
- `RefundApplyServiceImpl.handleRefundCallback(...)` 支持：
  - 优先按 `refundNo`
  - 其次按 `orderNo`
- 删除 `completeRefundByOrderNo(...)` 公开入口
- `DouyinChannelAdapter` 退款通知改为直接复用 `handleRefundCallback(...)`

## 当前语义

- 退款成功回写统一走一条核心入口
- 当前整单退款阶段允许按 `orderNo` 兼容定位退款单
- 该兼容定位仍取最新一笔退款单，只适合作为当前阶段的过渡方案
