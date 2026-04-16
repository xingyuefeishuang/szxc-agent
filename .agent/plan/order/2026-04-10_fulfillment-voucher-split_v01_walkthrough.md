# fulfillment-voucher-split walkthrough

## 完成内容

已按本次评审结果完成订单履约拆表实现：

- 新增 `FulfillmentItem`、`FulfillmentItemMapper`、`FulfillmentItemService`、`FulfillmentItemServiceImpl` 和 mapper XML，对应 `o_fulfillment_item`。
- 将 `Voucher` 实体映射从 `o_voucher` 切换为 `o_fulfillment_voucher`，保留原 `VoucherService`/`VoucherBO` 对外语义以减少调用方改动。
- 删除 `VoucherMapper` 中引用旧表和旧字段的自定义核销 SQL，核销继续走 MyBatis Plus 条件更新。
- `VoucherServiceImpl` 发码时先创建/复用履约项，再创建实际码券；抖音 B11 可以按 `certificate_info_list` 一条 certificate 生成一张内部码。
- `o_order_item` 增加并贯通 `channel_order_no`、`channel_item_id`、`channel_sub_sku_list`、`sku_type`。
- 抖音 B10 创建订单时记录渠道订单项快照；B11 发码时把 `certificate_id` 写入 `channel_voucher_id`。
- `unified_order_schema.sql` 已同步新字段和新表关键约束，并移除旧 `o_voucher` 建表，仅保留 drop 清理。

## 验证

执行命令：

```powershell
cd D:\08-Work\01-博思\10-平台2.0\plt-core-service
$env:JAVA_HOME='D:\05-Development\jdk-17'
$env:Path='D:\05-Development\jdk-17\bin;D:\05-Development Tools\apache-maven-3.5.4\bin;' + $env:Path
mvn -pl plt-order-service/plt-order-core -am compile -DskipTests -s 'D:\05-Development Tools\apache-maven-3.5.4\conf\settings.xml'
```

结果：`BUILD SUCCESS`。

备注：Maven 仍有本地仓库 tracking file `拒绝访问` 警告，但未阻断编译。

## 后续注意

- 当前商品域未接入，`spu_id/sku_id/sub_sku_id` 仍按渠道或 `out_id` 过渡解析；后续商品域接入后，应在商品门面统一替换解析逻辑。
- `o_fulfillment_item.fulfillment_status` 当前在发码成功创建时置为 `ISSUED`，后续如果要做部分核销/部分退款统计，可以再补充 issued/verified/refund 计数字段或状态聚合任务。

