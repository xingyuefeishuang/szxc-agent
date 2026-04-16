# 退款支付门面骨架工作总结

## 本次修改

- 新增 `OrderRefundPaymentFacadeService`
- 新增 `OrderRefundPaymentStrategy`
- 新增两个策略占位：
  - `PlatformPayRefundPaymentStrategy`
  - `DouyinRefundPaymentStrategy`
- 新增 `OrderRefundPaymentFacadeServiceImpl`
- `RefundApplyServiceImpl.auditRefund(approved=true)` 改为调用退款支付门面

## 当前行为

- 审核通过后，核心退款服务不再自己留“直接调支付中心”的 TODO
- 改为由退款支付门面按订单渠道路由
- 当前两个策略都只记录日志并保留 TODO，不发起真实退款请求

## 设计约束

- 平台支付退款提交后续接 `pay-service`
- 抖音订单退款提交后续接抖音渠道能力
- 当前抖音审核结果回写仍沿用 `RefundApprovedEvent` 监听链路，避免本次骨架改动打断既有链路
