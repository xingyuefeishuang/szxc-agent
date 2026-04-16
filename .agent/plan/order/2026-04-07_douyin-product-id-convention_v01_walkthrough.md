# 抖音商品标识过渡约定 v01 - 工作总结

## 本次处理

### 1. 收回了对映射表的当前依赖

文件：
- `plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/channel/douyin/adapter/DouyinChannelAdapter.java`

变更：
- 删除了 `ChannelSkuMapping`
- 删除了 `ChannelSkuMappingService`
- 删除了 `LambdaQueryWrapper`
- 删除了适配器里当前对 `channelSkuMappingService` 的依赖

原因：
- 当前商品域未接入
- `o_channel_sku_mapping` 未正式启用
- 若继续强依赖映射表，B10/B11 当前链路会被全部拒单

### 2. 明确了当前过渡约定

在 `resolveSkuMapping(...)` 中，当前逻辑改成：

1. `sku_out_id` 优先承载内部 `skuId`
2. `product_out_id` 优先承载内部 `spuId`
3. 若 `out_id` 缺失，再回退到抖音原始 `sku_id / product_id`
4. 若最终不能解析成内部数字 ID，则视为失败

也就是：
- 当前阶段仍要求传入的过渡商品标识可解析为内部数字主键
- 这是一套阶段性约定，不是最终商品域方案

### 3. `handleCanBuy(...)` 也同步收口

当前预订校验不再查映射表。

现在只做：
- SKU 标识是否存在
- 购买数量是否合法
- 其余库存/限购/可售规则继续保留 TODO

## 当前结论

### 已明确

1. 当前抖音创单/预订校验不再强依赖 `o_channel_sku_mapping`
2. 商品域未接入阶段，抖音商品标识按过渡约定直接承载内部 ID

### 仍是后续 TODO

1. 后续接商品域后，应由 `OrderProductFacadeService` 或商品映射能力统一接管
2. 未来不应长期依赖“渠道外部字段承载内部数字 ID”这种过渡协议

## 风险提示

当前约定要求：
- `sku_out_id/product_out_id` 或回退值 `sku_id/product_id`
- 最终必须能解析成内部数字 ID

如果抖音侧传的是纯业务字符串而不是数字主键，当前实现仍会失败。

这不是 bug，而是当前阶段过渡协议的明确边界。
