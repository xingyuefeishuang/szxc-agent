# 凭证票型字段补充实施计划

## 背景

`o_voucher` 需要补充商品与票型识别字段，用于区分普通票与组合票，并保留组合票的子 SKU 维度信息。

## 目标

1. 在 `o_voucher` 中增加：
   - `spu_id`
   - `sku_id`
   - `sub_sku_id`
   - `ticket_type`
2. `sub_sku_id` 默认值统一为 `0`，仅组合票场景使用。
3. 从创单到发券链路保留 `sub_sku_id`，确保发券时能正确写入凭证表。

## 实施步骤

1. 扩展 `OrderItem`、`Voucher`、`VoucherBO` 字段定义。
2. 扩展标准下单指令与商品解析指令，补充 `subSkuId` 透传。
3. 修改抖音团购创单转换逻辑：
   - 普通票默认 `subSkuId=0`
   - 子 SKU 场景写入对应 `subSkuId`
4. 修改 `OrderServiceImpl`，将 `subSkuId` 落库到 `o_order_item`。
5. 修改 `VoucherServiceImpl`，发券时写入 `spuId/skuId/subSkuId/ticketType`。
6. 更新 Mapper XML 与订单设计 SQL。
7. 使用仓库 `maven-compile` skill 编译 `plt-order-core` 验证。

## 默认约定

- `ticket_type` 取值：
  - `NORMAL`
  - `COMBO`
- 当 `sub_sku_id = 0` 时视为普通票；非 `0` 时视为组合票。
