# 退款两阶段模型实施计划

## 背景
- 当前 `auditRefund` 在审核通过时就直接把退款单写成 `SUCCESS`，且立刻作废凭证。
- 这与“资金原路退款成功后才算退款成功”的业务语义不一致。

## 实施方案
1. 给 `RefundApply` 增加 `originalOrderStatus` 字段，用于驳回后恢复前态。
2. `auditRefund(approved=true)` 只推进到 `APPROVED`，不再直接写 `SUCCESS`。
3. 新增退款成功回调接口与服务方法，专门负责：
   - `refundStatus -> SUCCESS`
   - 凭证作废
   - 主订单推进到 `REFUNDED`
4. `auditRefund(approved=false)` 改为按 `originalOrderStatus` 恢复订单状态。
5. 状态机增加 `REFUNDING -> DELIVERING` 恢复通路。

## 边界说明
- 本次仍不实现支付中心对接，只新增回调落点。
- 本次不扩展部分退款模型，继续按整单退款处理。
