# 订单退款支付路由设计

## 背景

订单退款审核完成后，后续动作并不唯一：

- 自有平台订单通常走支付中心退款
- 抖音等 OTA 订单需要将审核结果回写给渠道，由渠道继续处理资金回退

因此，退款核心服务不能默认“一律调支付中心”，而应统一走退款支付策略，由不同渠道/支付来源自行处理审核结果后的后续动作。

## 设计

本次将退款资金提交收敛为：

- `OrderRefundPaymentFacadeService`
- `OrderRefundPaymentStrategy`

由门面统一接收“退款审核结果后的后续动作”，再按订单渠道路由到具体策略。

## 当前策略

### 1. `PlatformPayRefundPaymentStrategy`

- 适用于非 OTA 渠道订单
- 审核通过：后续在此对接 `pay-service` 退款接口
- 审核驳回：显式 no-op
- 约束：若支付中心同步返回失败，应抛异常让 `auditRefund` 整体回滚

### 2. `DouyinRefundPaymentStrategy`

- 适用于抖音订单
- 审核通过/驳回都通过抖音渠道适配器回写审核结果
- 抖音侧在收到审核结果后继续处理资金回退
- 当前直接复用 `OrderChannelAdapter.notifyRefundAuditResult(...)`

## 渠道接口语义

为避免和“退款成功回调”混淆，渠道适配器接口统一使用：

- `notifyRefundAuditResult(RefundAuditResultNotifyCmd cmd)`

当前命令字段：

- `orderId`
- `refundNo`
- `approved`
- `remark`

## 边界

- 本次只搭路由骨架，不接真实支付中心
- `RefundApplyServiceImpl.auditRefund(...)` 不再发布退款审核事件
- 所有订单统一调用退款支付门面
- 由不同策略自行决定审核通过/驳回后的后续动作
