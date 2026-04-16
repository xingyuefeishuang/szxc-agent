# 退款失败状态移除工作总结

## 本次修改

- `RefundStatusEnum` 删除 `FAILED`
- `o_refund_apply.refund_status` 设计 SQL 注释删除 `FAILED`
- 退款两阶段设计文档明确：发起退款失败不在订单域状态模型里维护独立终态

## 结果

- 当前订单域退款状态重新收敛为：
  - `APPLYING`
  - `APPROVED`
  - `SUCCESS`
  - `REJECTED`
- “退款发起失败”回到调用支付中心阶段自行处理，不再伪装成订单域已落地状态
