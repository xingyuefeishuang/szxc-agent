# 工作总结

## 结果

已完成 `FulfillmentVoucherServiceImpl` 中 `ChannelSubSkuList` 残留清理，当前履约发码相关子 SKU 映射仅依赖 `OrderItem.subSkuList` 内嵌快照。

## 具体修改

1. 删除 `buildMergedSubSkuMappings(...)` 中对 `orderItem.getChannelSubSkuList()` 的 legacy 回退解析。
2. 删除私有方法 `parseLegacyChannelSubSkuList(...)`。
3. 将映射构造逻辑改为逐条读取 `subSkuList`，若 `channelSubSkuId` 为空则直接抛出 `ORDER_CHANNEL_SUB_SKU_SNAPSHOT_MISSING`。
4. 同步修正文档注释和匹配说明，将“查找 channelSubSkuList”更新为“查找 subSkuList 快照”。

## 校验

- 使用全文检索确认 `FulfillmentVoucherServiceImpl` 内已无 `ChannelSubSkuList`、`channelSubSkuList`、`getChannelSubSkuList`、`parseLegacyChannelSubSkuList` 残留。
- 未执行 Maven 编译；本次做的是单类局部清理，完成了静态引用收口检查。

## 影响说明

- 新逻辑与当前订单快照模型保持一致。
- 若存在未迁移完成的历史订单数据，本次清理会更早暴露快照缺失问题，而不是继续隐式依赖已删除字段。
