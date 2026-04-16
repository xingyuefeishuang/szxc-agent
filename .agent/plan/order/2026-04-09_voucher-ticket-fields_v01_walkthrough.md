# 凭证票型字段补充工作总结

## 完成内容

- `o_voucher` 模型已增加：
  - `spuId`
  - `skuId`
  - `subSkuId`
  - `ticketType`
- `o_order_item` 模型已增加 `subSkuId`，用于承接创单阶段的组合票子 SKU 信息。
- `StandardOrderCreateCmd` 与 `OrderProductResolveCmd` 已增加 `subSkuId` 字段。
- 抖音团购创单转换逻辑已补充：
  - 普通项默认 `subSkuId=0`
  - 子 SKU 项写入 `subSkuId`
- 发券逻辑已补充：
  - 从 `OrderItem` 写入 `Voucher.spuId / skuId / subSkuId`
  - 根据 `subSkuId` 自动判定 `ticketType`
- `VoucherBO`、Mapper XML、`unified_order_schema.sql` 已同步更新。

## 编译验证

已按仓库 `maven-compile` skill 执行：

```powershell
cd D:\08-Work\01-博思\10-平台2.0\plt-core-service
$env:JAVA_HOME="D:\05-Development\jdk-17"
mvn -pl plt-order-service/plt-order-core -am compile -DskipTests -s "D:\05-Development Tools\apache-maven-3.5.4\conf\settings.xml"
```

结果：

- `plt-order-api` 成功
- `plt-order-core` 成功

## 注意事项

- 需要手动执行数据库 DDL，补齐 `o_order_item` 与 `o_voucher` 新字段。
- 当前默认语义为：
  - `sub_sku_id = 0` -> `ticket_type = NORMAL`
  - `sub_sku_id != 0` -> `ticket_type = COMBO`
- 本次只补充字段落库与透传，不调整组合票父子项的既有建单语义。
