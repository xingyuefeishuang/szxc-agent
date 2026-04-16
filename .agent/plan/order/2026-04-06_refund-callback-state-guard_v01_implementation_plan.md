# 退款回调状态约束实施计划

## 目标

- 收紧退款回调状态约束
- 禁止 `APPLYING -> SUCCESS` 直接越过审核通过阶段

## 实施步骤

1. 调整 `RefundApplyServiceImpl.completeRefund(...)` 的状态前置判断
2. 仅允许 `APPROVED -> SUCCESS`
3. 保留 `SUCCESS` 幂等直接返回逻辑

## 边界

- 本次只修改退款回调状态判断
- 不扩展退款失败状态链路
