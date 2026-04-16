# 退款支付门面与渠道审核事件拆分工作总结

## 本次修改

- 删除 `DouyinRefundPaymentStrategy`
- `RefundApprovedEvent` 重命名为 `RefundAuditResultEvent`
- `DouyinChannelAdapter` 改为监听退款审核结果事件
- `RefundApplyServiceImpl.auditRefund(...)` 按渠道拆分后续动作：
  - OTA：发布审核结果事件
  - 非 OTA：调用退款支付门面
- `PlatformPayRefundPaymentStrategy` 收窄为只匹配非 OTA 订单

## 当前边界

- 退款支付门面现在只承接“审核通过后的资金退款提交”
- OTA 渠道审核结果回写不再和退款支付策略共用一条扩展链
- 抖音现有审核结果回写链路继续可用，但事件语义更准确

## 设计收益

- 消除了“抖音到底走策略还是走事件”的歧义
- 避免未来为抖音同时触发两条后续动作链
- 让退款支付门面和渠道审核回写职责各自单一
