# fulfillment-voucher-rename walkthrough

## 完成内容

已完成实际履约码内部类名收敛：

- `Voucher` -> `FulfillmentVoucher`
- `VoucherMapper` -> `FulfillmentVoucherMapper`
- `VoucherService` -> `FulfillmentVoucherService`
- `VoucherServiceImpl` -> `FulfillmentVoucherServiceImpl`
- `VoucherController` -> `FulfillmentVoucherController`
- `VoucherApi` -> `FulfillmentVoucherApi`
- `VoucherBO/AddDO/QueryDO/UpdateDO` -> `FulfillmentVoucherBO/AddDO/QueryDO/UpdateDO`
- `VoucherIssueCmd/ItemCmd` -> `FulfillmentVoucherIssueCmd/ItemCmd`
- `VoucherStatusEnum` -> `FulfillmentVoucherStatusEnum`
- `VoucherTicketTypeEnum` -> `FulfillmentVoucherTicketTypeEnum`
- `VoucherCodeGenerator` -> `FulfillmentVoucherCodeGenerator`
- `VoucherOrderFulfillmentStrategy` -> `FulfillmentVoucherOrderFulfillmentStrategy`

已保留：

- `VoucherRule`：码券规则配置，与实际履约码表拆分后的新命名不冲突。
- `DouyinIssueVoucherRequest`：三方协议 DTO，不应改为内部领域名。
- `voucherCode`、`voucher_id` 等字段名：仍表示真实票码/码券 ID。

## 验证

执行 Maven 编译：

```powershell
cd D:\08-Work\01-博思\10-平台2.0\plt-core-service
$env:JAVA_HOME='D:\05-Development\jdk-17'
$env:Path='D:\05-Development\jdk-17\bin;D:\05-Development Tools\apache-maven-3.5.4\bin;' + $env:Path
mvn -pl plt-order-service/plt-order-core -am compile -DskipTests -s 'D:\05-Development Tools\apache-maven-3.5.4\conf\settings.xml'
```

结果：`BUILD SUCCESS`。

备注：Maven 仍输出本地仓库 tracking file `拒绝访问` 警告，但不影响编译。

