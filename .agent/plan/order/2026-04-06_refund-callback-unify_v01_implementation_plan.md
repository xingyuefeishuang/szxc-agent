# 退款结果回调统一方案实施计划

## 目标

- 将退款回调接口从仅支持成功结果的 `/success-callback` 收敛为统一 `/callback`
- 支持支付中心或渠道回调退款成功、退款失败两种结果
- 让 `FAILED` 状态真正落到代码链路，和两阶段退款模型保持一致

## 实施步骤

1. 将回调 DTO 从“成功回调”语义改为“结果回调”语义，补充退款结果字段。
2. 将 `RefundController`、`RefundApplyService`、`RefundApplyServiceImpl` 中的回调接口与方法统一重命名为 `callback / handleRefundCallback`。
3. 成功分支继续复用现有 `completeRefund(...)` 逻辑。
4. 新增失败分支：
   - 退款单状态置为 `FAILED`
   - 解冻已锁定凭证
   - 按 `originalOrderStatus` 恢复主订单状态
5. 更新退款两阶段设计文档，明确统一回调接口同时承接成功与失败结果。

## 边界

- 本次不接入支付中心“发起退款”调用，仅收敛回调入参与内部状态推进。
- 本次不新增失败原因等更多数据库字段，回调备注继续复用 `remark` 承接。
