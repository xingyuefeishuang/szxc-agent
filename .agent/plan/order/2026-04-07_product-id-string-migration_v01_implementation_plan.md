# 商品标识字符串化迁移 v01 - 实施计划

## 背景

在继续审查抖音 B 类 SPI 时，确认当前订单域的 `spuId/skuId` 仍大量使用 `Long`，这会持续把渠道商品标识和订单域主流程绑定到“必须为数字主键”的假设上。

结合当前阶段特征：

- 商品域未完全接入
- 多渠道接入会带来字符串型商品标识
- 抖音 `sku_out_id/product_out_id` 的过渡约定已经存在

因此决定统一把订单域商品标识从 `Long` 调整为 `String`。

## 本次目标

1. 将订单域核心商品标识字段统一从 `Long` 改为 `String`
2. 同步修改设计 SQL
3. 去掉抖音过渡逻辑里“必须解析成数字”的限制

## 预计影响范围

### 表/实体

1. `o_order_item`
2. `o_spu_rule`
3. `o_channel_sku_mapping`
4. `o_shopping_cart`

### Java 模型

1. `StandardOrderCreateCmd.OrderItemCmd`
2. `PriceCalcCmd.PriceItem`
3. `OrderItemBO`
4. `OrderItem`
5. `SpuRule`
6. `ChannelSkuMapping`
7. `ShoppingCart`
8. `OtaProductMapping*` DTO

### 过渡解析逻辑

1. `DouyinChannelAdapter.resolveSkuMapping(...)`
2. `OrderProductFacadeServiceImpl.resolveDouyinGroupbuyItems(...)`

## 实施步骤

1. 先改 Java 模型字段类型
2. 再改抖音过渡商品解析逻辑
3. 最后改设计 SQL 和残留注解/导入

## 本次不做

1. 不执行真实数据库变更
2. 不全面重构所有商品业务
3. 不接商品域
