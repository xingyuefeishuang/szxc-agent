# 抖音商品标识过渡约定 v01 - 实施计划

## 背景

在继续审查抖音 B 类 SPI 时，确认当前阶段尚未接入商品域，也未正式启用 `o_channel_sku_mapping`。

因此，B10/B11 商品识别逻辑不能强依赖：

- `ChannelSkuMappingService`
- `o_channel_sku_mapping`

否则当前创单链路会被全部拒单。

## 本次目标

把“未接商品域阶段的过渡商品标识方案”直接落到代码里：

1. 暂时约定 `sku_out_id / product_out_id` 承载内部 `skuId / spuId`
2. 若 `out_id` 缺失，再回退到抖音原始 `sku_id / product_id`
3. 若最终不能解析成内部数字 ID，则按失败处理

## 实施步骤

1. 修改 `DouyinChannelAdapter.handleCreateOrder` 相关注释，明确当前过渡约定。
2. 修改 `resolveSkuMapping(...)`：
   - 去掉对 `channelSkuMappingService` 的当前依赖
   - 改为按过渡约定解析内部 ID
3. 修改 `handleCanBuy(...)`：
   - 不再查询映射表
   - 仅校验当前 SKU 标识是否完整
4. 删除不再使用的映射表相关依赖和导入。

## 本次不做

1. 不接商品域
2. 不重构到 `OrderProductFacadeService` 真正执行解析
3. 不解决非数字内部 ID 方案，当前继续要求该过渡约定使用数字 ID
