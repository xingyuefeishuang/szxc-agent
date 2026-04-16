# 退款支付门面与渠道审核事件拆分实施计划

## 目标

- 解决 `OrderRefundPaymentFacadeService` 与 `RefundApprovedEvent` 的职责冲突
- 让退款支付门面只负责“审核通过后的资金退款提交”
- 让 OTA 渠道审核结果回写单独走事件链路

## 实施步骤

1. 删除 `DouyinRefundPaymentStrategy`，避免与抖音适配器退款审核回写逻辑重复。
2. 将 `RefundApprovedEvent` 重命名并收敛为 `RefundAuditResultEvent`。
3. `auditRefund(approved=true)`：
   - OTA 渠道发布审核结果事件
   - 非 OTA 渠道调用退款支付门面
4. `auditRefund(approved=false)`：
   - OTA 渠道发布审核结果事件
   - 非 OTA 渠道仅完成内部驳回恢复
5. 将平台支付策略命中条件从“非抖音”收窄为“非 OTA”。

## 边界

- 本次不接支付中心退款接口
- 本次不改抖音适配器的具体退款回写实现，只改事件语义与入口路由
