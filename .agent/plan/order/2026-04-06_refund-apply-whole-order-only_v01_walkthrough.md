# 退款申请整单收敛工作总结

## 本次改动
- `RefundController.apply` 的接口说明改为“发起整单退票申请”。
- `RefundAddDO` 明确标注：
  - 当前仅支持整单退款
  - `orderNo` 为必填
  - `orderItemId` 当前未启用
  - `refundAmount` 必须大于 0
- `RefundApplyServiceImpl.applyRefund(...)` 增加保护：
  - 如果传入 `orderItemId`，直接抛 `PARTIAL_REFUND_UNSUPPORTED`

## 结果
- 退款申请接口不再继续对外暗示“支持部分退款”。
- 当前整单冻结、整单状态推进的实现和接口契约已初步对齐。

## 未覆盖事项
- 审核通过后直接写 `SUCCESS`、驳回后一律恢复 `PAID` 等问题尚未处理。
- 未补自动化测试，本次结论基于静态代码修改。
