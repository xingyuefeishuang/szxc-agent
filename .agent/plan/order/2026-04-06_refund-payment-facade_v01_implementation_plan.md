# 退款支付门面骨架实施计划

## 目标

- 为退款审核通过后的资金退款提交建立统一门面
- 避免在 `RefundApplyServiceImpl.auditRefund(...)` 中硬编码支付中心或渠道逻辑
- 先搭骨架，不接真实支付中心

## 实施步骤

1. 新增 `OrderRefundPaymentFacadeService`
2. 新增 `OrderRefundPaymentStrategy`
3. 提供两个策略占位：
   - `PlatformPayRefundPaymentStrategy`
   - `DouyinRefundPaymentStrategy`
4. 在 `auditRefund(approved=true)` 中调用退款支付门面
5. 保留当前抖音 `RefundApprovedEvent` 监听链路，不在本次改动中替换

## 边界

- 本次不接 `pay-service`
- 本次不改抖音退款回写既有事件链路
- 策略实现仅记录日志并保留 TODO
