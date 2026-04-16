# 订单退款两阶段模型设计

## 背景

当前退款链路需要区分两个动作：

1. **业务审核通过**
2. **资金退款成功**

如果在审核通过时就直接把退款单打成 `SUCCESS`，会出现业务终态与资金终态脱节的问题。

## 两阶段语义

### 1. 申请阶段

- 创建退款申请单
- 冻结相关凭证（`LOCKED`）
- 主订单进入 `REFUNDING`

### 2. 审核阶段

- 审核通过：
  - `refund_status = APPROVED`
  - 凭证继续保持 `LOCKED`
  - 主订单继续保持 `REFUNDING`
  - 后续由支付中心/渠道退款回调推动终态

- 审核驳回：
  - `refund_status = REJECTED`
  - 凭证 `LOCKED -> USABLE`
  - 主订单恢复到申请退款前的原状态

### 3. 退款回调阶段

- 退款成功：
  - `refund_status = SUCCESS`
  - 凭证 `LOCKED -> INVALID`
  - 主订单 `REFUNDING -> REFUNDED`

- 发起退款失败：
  - 不通过订单域回调接口处理
  - 由审核通过后调用支付中心退款时自行处理失败原因、重试或补偿
  - 当前订单域退款状态模型不单独维护 `FAILED` 终态

## 数据模型补充

为支持“驳回恢复前态”，在 `o_refund_apply` 中增加：

- `original_order_status`

用途：

- 记录退款申请创建前主订单所处状态
- 退款驳回时，按该状态恢复主订单

## 当前接口

新增内部接口：

- `POST /api/core/refund/callback`

用途：

- 供支付中心或渠道退款成功后回调
- 推进内部退款单到 `SUCCESS`
- 作废凭证并终结主订单退款状态
