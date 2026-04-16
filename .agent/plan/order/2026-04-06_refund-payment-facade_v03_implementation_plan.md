# 退款支付策略统一回退实施计划

## 目标

- 回退到“统一由退款支付策略处理审核结果后动作”的方案
- 删除退款审核事件链，避免策略与事件双通道冲突
- 让抖音订单也作为退款支付策略之一承接审核结果回写

## 实施步骤

1. 恢复 `DouyinRefundPaymentStrategy`
2. 将退款支付门面/策略的方法从“审核通过后提交”扩展为“审核结果后处理”
3. 删除 `RefundAuditResultEvent` 及其发布/监听链路
4. `RefundApplyServiceImpl.auditRefund(...)` 统一调用退款支付门面
5. 抖音策略直接复用 `OrderChannelAdapter.notifyRefundResult(...)`

## 边界

- 本次不接真实支付中心退款
- 平台支付策略在审核驳回时显式 no-op
- 抖音策略当前仅复用现有渠道适配器回写能力
