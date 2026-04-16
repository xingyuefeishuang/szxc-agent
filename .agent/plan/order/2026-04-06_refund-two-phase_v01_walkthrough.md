# 退款两阶段模型工作总结

## 本次改动
- 新增 `RefundSuccessCallbackDO`
- `RefundController` 新增 `/success-callback` 接口
- `RefundApplyService` 新增 `handleRefundSuccessCallback(...)`
- `RefundApply` / `RefundBO` 增加 `originalOrderStatus`
- `RefundStatusEnum` 增加 `FAILED`
- `RefundApplyServiceImpl` 改为：
  - 审核通过只写 `APPROVED`
  - 退款成功回调才写 `SUCCESS`
  - 驳回时按 `originalOrderStatus` 恢复订单状态
- `OrderStateMachine` 增加 `REFUNDING -> DELIVERING` 通路
- 设计 SQL 补 `o_refund_apply.original_order_status`

## 结果
- 退款审核与退款成功不再混成一步。
- 凭证作废延后到退款成功回调阶段，避免审核通过后立即永久失效。
- 已进入履约中的订单，退款驳回后可以恢复到 `DELIVERING`。

## 未覆盖事项
- 支付中心退款发起和失败回调尚未实现。
- `FAILED` 状态目前仅完成模型预留，尚未接入真实失败链路。
- 未补自动化测试，本次结论基于静态代码修改。
