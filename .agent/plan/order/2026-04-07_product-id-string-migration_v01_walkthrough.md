# 商品标识字符串化迁移 v01 - 工作总结

## 本次改动

### 1. 核心商品标识字段统一改为 `String`

已调整的 Java 模型：

- `StandardOrderCreateCmd.OrderItemCmd`
- `PriceCalcCmd.PriceItem`
- `OrderItemBO`
- `OrderItem`
- `SpuRule`
- `ChannelSkuMapping`
- `ShoppingCart`
- `OtaProductMappingAddDO`
- `OtaProductMappingBO`
- `OtaProductMappingQueryDO`
- `OtaProductMappingUpdateDO`

## 2. 抖音过渡商品解析不再要求数字主键

文件：
- `DouyinChannelAdapter.java`
- `OrderProductFacadeServiceImpl.java`

变更：
- 不再把 `sku_out_id/product_out_id` 强制 `Long.parseLong(...)`
- 改为直接按字符串承载内部 `spuId/skuId`
- 只要值非空即可进入订单域

这意味着：
- 当前抖音 B10/B11 过渡协议不再被“必须是数字 ID”卡住

## 3. 设计 SQL 已同步

文件：
- `.agent/designs/order/unified_order_schema.sql`

已调整字段：
- `o_order_item.spu_id / sku_id`
- `o_spu_rule.spu_id / sku_id`
- `o_channel_sku_mapping.spu_id / sku_id`
- `o_shopping_cart.spu_id / sku_id`

统一从 `bigint` 改为 `varchar(128)`

## 当前效果

### 已解决

1. 订单域商品标识不再强依赖数字主键
2. 抖音过渡商品标识可直接按字符串进入订单域
3. 后续接美团、OTA、商品域时，商品标识类型阻力更小

### 仍需注意

1. 这次只改了订单域代码和设计 SQL
2. 真实数据库迁移还没执行
3. 如果其他服务模块也依赖这些表字段是 `bigint`，后续要一起校验

## 备注

这次是对象模型级调整，不是单点修补。后续如果继续推进商品域接入，应以 `String` 作为统一商品标识类型继续设计。
