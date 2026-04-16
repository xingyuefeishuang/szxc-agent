# 订单履约命令模型压平实施计划

## 目标

删除 `FulfillmentVoucherIssueCmd`，避免与 `OrderFulfillmentCmd` 的订单级字段重复，保留：

- 订单级统一命令：`OrderFulfillmentCmd`
- 券级明细：`FulfillmentVoucherIssueItemCmd`

## 实施项

1. 将 `channelOrderNo` 与券类明细列表并入 `OrderFulfillmentCmd`
2. 删除 `FulfillmentVoucherIssueCmd`
3. 将 `FulfillmentVoucherService.issueVouchers(...)` 改为直接接收 `OrderFulfillmentCmd`
4. 调整渠道发码策略与抖音适配器，改为直接填充 `voucherItems`
5. 重新执行 `plt-order-service` 编译验证

## 验证点

- 不再存在 `FulfillmentVoucherIssueCmd` 引用
- 抖音团购发码仍能构造 item 级明细进入履约门面
- `mvn clean compile -DskipTests` 通过

## 默认假设

- 发券上下文始终属于订单级履约命令，不再单独抽一层“发券命令”
