# 组合票子SKU集合工作总结

## 完成内容

- `o_order_item` 已由单值 `subSkuId` 改为 `subSkuList` JSON。
- 新增 `OrderSubSkuInfo`，结构为：
  - `subSkuId`
  - `subSpuId`
  - `quantity`
  - `subSkuName`
- 抖音团购创单链路已调整为：
  - 主商品仍落一个 `order item`
  - 子 SKU 作为集合挂在 `sub_sku_list`
  - 不再把每个子 SKU 拆成单独 `order item`
- `VoucherServiceImpl` 已改为：
  - 普通票按 `order_item.quantity` 发券
  - 组合票按 `sub_sku_list[].quantity` 展开发券
  - 每张组合票凭证写入具体 `sub_sku_id`

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

- 需要手动执行数据库 DDL，将 `o_order_item.sub_sku_id` 调整为 `sub_sku_list` JSON 字段。
- 当前 `subSkuName` 因抖音创单请求中无名称字段，先以空串落库；若后续需要真实名称，可在后续对接发券回调或商品域补齐。
