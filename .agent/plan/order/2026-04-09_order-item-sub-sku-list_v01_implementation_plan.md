# 组合票子SKU集合实施计划

## 背景

`o_order_item` 不再适合保存单值 `subSkuId`。组合票需要在订单项层保留完整的子票集合，并在发券时按子项集合拆分凭证。

## 目标

1. `o_order_item` 改为使用 `sub_sku_list` JSON 保存组合票子项集合。
2. `sub_sku_list` 元素固定包含：
   - `subSkuId`
   - `subSpuId`
   - `quantity`
   - `subSkuName`
3. `o_voucher` 继续保留单值 `sub_sku_id`，并按 `sub_sku_list[].quantity` 展开发券。

## 实施步骤

1. 新增共享子项对象 `OrderSubSkuInfo`。
2. 修改标准下单指令与商品解析指令，将单值 `subSkuId` 改为 `subSkuList`。
3. 调整抖音团购创单转换逻辑：主项挂子 SKU 集合，不再把子 SKU 拆成多个 `order item`。
4. 调整商品解析门面，将子 SKU 集合解析成内部 `subSkuId/subSpuId/quantity/subSkuName`。
5. 调整 `OrderServiceImpl`，将 `subSkuList` 以 JSON 形式落库到 `o_order_item`。
6. 调整 `VoucherServiceImpl`：
   - 普通票：按 `order_item.quantity` 发券
   - 组合票：按 `sub_sku_list[].quantity` 发券，并写入对应 `sub_sku_id`
7. 更新 `OrderItemMapper.xml` 与 `unified_order_schema.sql`。
8. 使用 `maven-compile` skill 编译 `plt-order-core` 验证。

## 默认约定

- 普通票：`sub_sku_list` 为空，凭证 `sub_sku_id=0`
- 组合票：`sub_sku_list` 非空，凭证 `ticket_type=COMBO`
- 当前抖音 `createOrder` 请求拿不到 `subSkuName`，本次先落空串占位
