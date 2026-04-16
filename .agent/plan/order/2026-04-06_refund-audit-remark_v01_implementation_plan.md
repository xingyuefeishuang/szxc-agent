# 退款审核备注字段补充实施计划

## 目标

- 将退款申请原因与审核备注/驳回原因拆开建模
- 避免渠道审核结果回写继续错误复用 `refundReason`

## 实施步骤

1. 给 `RefundApply` 增加 `auditRemark`
2. 给 `RefundBO` 增加 `auditRemark`
3. 更新 `o_refund_apply` 设计 SQL
4. 在 `auditRefund(...)` 中写入审核备注
5. 在渠道退款审核结果回写命令中优先使用 `auditRemark`

## 边界

- 本次只补模型和当前退款链路使用点
- 不额外新增独立 DTO 入参，仍复用 `auditRefund(refundNo, approved, remark)`
