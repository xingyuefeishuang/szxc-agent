# 实施计划

## 目标

- 删除 `FulfillmentVoucherServiceImpl` 中对 `channelSubSkuList` 的未上线兼容逻辑。
- 统一发码阶段子 SKU 映射来源，只依赖 `OrderItem.subSkuList` 内的 `OrderSubSkuInfo.channelSubSkuId`。
- 收口相关注释，避免继续出现“兼容旧字段”的误导性描述。

## 变更点

- 删除 `parseLegacyChannelSubSkuList(...)` 等未使用兼容逻辑。
- `buildMergedSubSkuMappings(...)` 改为直接校验 `subSkuList` 中的渠道子 SKU 快照，不再回退。
- 调整 `resolveOrderItemByChannelSku(...)` 相关注释，明确匹配来源是 `subSkuList` 映射。
