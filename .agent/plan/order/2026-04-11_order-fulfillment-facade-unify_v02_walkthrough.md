# 订单履约命令模型压平工作总结

## 完成内容

- 删除了 `FulfillmentVoucherIssueCmd`
- `OrderFulfillmentCmd` 新增：
  - `channelOrderNo`
  - `List<FulfillmentVoucherIssueItemCmd> voucherItems`
- `FulfillmentVoucherService.issueVouchers(...)` 已改为直接接收 `OrderFulfillmentCmd`
- `ChannelIssueVoucherOrderFulfillmentStrategy` 已改为直接读取 `voucherItems`
- 抖音适配器已改为构造 `voucherItems`，不再组装中间的 `FulfillmentVoucherIssueCmd`

## 结果

- 履约模型从三层收敛为两层：
  - 订单级统一履约命令
  - 券级发券明细
- 避免了订单级字段在 `OrderFulfillmentCmd` 与 `FulfillmentVoucherIssueCmd` 之间重复维护
- 后续如果新增其他渠道券类履约，直接复用 `OrderFulfillmentCmd + FulfillmentVoucherIssueItemCmd` 即可

## 验证

- 执行：
  - `mvn clean compile -DskipTests`
- 结果：
  - `plt-order-service / plt-order-api / plt-order-core` 全部编译通过
  - Maven 依旧存在本地仓库 tracking file 权限告警，但未影响构建成功
