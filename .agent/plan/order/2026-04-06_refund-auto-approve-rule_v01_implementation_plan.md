# 退款自动审批规则收敛实施计划

## 目标

- 将退款自动审批口径从“只看第一条订单子项”收敛为整单口径
- 当前规则改为：任一子项需要人工审核，则整单人工

## 实施步骤

1. 调整 `shouldAutoApproveRefund(...)`，查询整单全部 `OrderItem`
2. 逐项读取 `SpuRule.needRefundAudit`
3. 仅当所有子项都明确为自动审核时，整单才自动审批
4. 在 `completeRefundByOrderNo(...)` 上补充过渡注释，明确其当前仅为兼容链路

## 边界

- 本次不优化查询批量化，只先修正业务口径
- 本次不改 `completeRefundByOrderNo(...)` 的定位方式，只补说明
