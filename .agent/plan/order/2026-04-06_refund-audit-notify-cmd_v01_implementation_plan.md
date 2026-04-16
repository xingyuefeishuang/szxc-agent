# 渠道退款审核回写命令收敛实施计划

## 目标

- 将渠道接口 `notifyRefundResult(...)` 收敛为更准确的审核结果语义
- 使用 `RefundAuditResultNotifyCmd` 承接回写参数
- 为后续扩展审核备注、驳回原因等字段预留稳定入口

## 实施步骤

1. 新增 `RefundAuditResultNotifyCmd`
2. `OrderChannelAdapter` 改名为 `notifyRefundAuditResult(...)`
3. `DouyinRefundPaymentStrategy` 改为组装命令对象后调用适配器
4. `DouyinChannelAdapter` 同步改签名并更新日志语义
5. 更新退款支付路由设计文档

## 边界

- 本次不扩展更多字段，只保留最小审核结果集合
- `remark` 先复用退款申请原因/备注，后续如需区分驳回原因可再单独补字段
