# 退款回调状态约束工作总结

## 本次修改

- `RefundApplyServiceImpl.completeRefund(...)` 不再接受 `APPLYING` 状态
- 退款回调现在仅允许：
  - `APPROVED -> SUCCESS`
  - `SUCCESS -> SUCCESS` 幂等返回

## 效果

- 退款回调不能再绕过审核阶段
- 当前两阶段退款模型和代码行为重新对齐
