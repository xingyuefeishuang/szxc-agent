# 退款结果回调统一方案工作总结

## 本次修改

- 删除 `RefundSuccessCallbackDO`，新增 `RefundCallbackDO`
- `RefundController` 将 `/success-callback` 调整为 `/callback`
- `RefundApplyService` 将 `handleRefundSuccessCallback(...)` 调整为 `handleRefundCallback(...)`
- `RefundApplyServiceImpl` 按 `request.success` 分发：
  - 成功：沿用 `completeRefund(...)`
  - 失败：新增 `failRefund(...)`

## 失败分支语义

- `refund_status -> FAILED`
- 凭证 `LOCKED -> USABLE`
- 主订单按 `originalOrderStatus` 恢复到申请退款前状态

## 设计同步

- 更新 `ORDER_REFUND_TWO_PHASE_RULE_2026-04-06.md`
- 明确内部接口统一为 `POST /api/core/refund/callback`
- 明确该接口同时处理退款成功与退款失败结果

## 当前边界

- `FAILED` 现已接入内部回调处理链路
- 支付中心退款发起动作仍保留 TODO，后续在审核通过后接入
- 未执行自动化测试，本次结论基于静态修改与链路自审
