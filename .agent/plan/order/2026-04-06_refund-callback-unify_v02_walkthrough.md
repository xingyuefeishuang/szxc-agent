# 退款回调语义收敛工作总结

## 本次修改

- `RefundCallbackDO` 去掉 `success` 字段
- `RefundController` 的 `/callback` 文案改为退款成功回写
- `RefundApplyServiceImpl.handleRefundCallback(...)` 只保留成功推进逻辑
- 删除了订单域内“退款失败回调 -> FAILED/解冻/恢复订单”的分支实现

## 语义变化

- 订单域的 `/api/core/refund/callback` 现在只承接退款成功通知
- 支付中心退款发起失败不再通过该接口回写
- 发起退款失败的处理责任留在 `auditRefund(approved=true)` 调支付中心的阶段

## 设计同步

- 更新 `ORDER_REFUND_TWO_PHASE_RULE_2026-04-06.md`
- 明确回调接口是“成功回写接口”，不是“成功/失败结果总线”

## 当前边界

- `FAILED` 仍保留在枚举中，但当前未接入真实业务链路
- 后续如支付中心确实存在“最终失败异步通知”，需要再单独设计失败状态、重试与补偿模型
