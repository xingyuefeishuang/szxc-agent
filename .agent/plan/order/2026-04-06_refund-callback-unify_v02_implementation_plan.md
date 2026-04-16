# 退款回调语义收敛实施计划

## 目标

- 保留统一路径名 `POST /api/core/refund/callback`
- 将接口语义收敛为“退款成功回写”
- 不再在订单域回调接口中处理支付中心退款失败

## 实施步骤

1. 从 `RefundCallbackDO` 中移除成功/失败结果字段，避免接口继续承诺“结果回调”。
2. 将 `RefundController`、`RefundApplyService` 的接口描述收敛为退款成功回写。
3. 删除 `RefundApplyServiceImpl` 中的失败分支，`handleRefundCallback(...)` 只推进成功终态。
4. 更新退款两阶段设计文档，明确“发起退款失败”由审核通过后调用支付中心时自行处理。

## 边界

- 本次不实现支付中心发起退款失败后的重试/补偿策略。
- `FAILED` 枚举先保留，后续是否启用取决于支付中心退款失败链路设计。
