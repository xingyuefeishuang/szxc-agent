# 实施计划

## 任务

清理 `plt-order-core` 中 `FulfillmentVoucherServiceImpl` 对已删除字段 `ChannelSubSkuList` 的残留依赖，确保履约发码逻辑仅依赖 `subSkuList` 快照中的 `channelSubSkuId`。

## 实施步骤

1. 阅读仓库全局规范、编码规则和订单模块相关设计，确认本次变更属于订单模块局部清理。
2. 检查 `FulfillmentVoucherServiceImpl` 中所有 `channelSubSkuList` / legacy 解析引用，识别真实使用路径。
3. 删除 `orderItem.getChannelSubSkuList()` 与 `parseLegacyChannelSubSkuList(...)` 回退逻辑。
4. 将子 SKU 映射构造逻辑统一收敛为仅从 `subSkuList` 读取，并在缺少 `channelSubSkuId` 时直接抛出快照缺失异常。
5. 更新相关注释，避免后续维护者继续按旧字段理解匹配逻辑。
6. 使用检索方式确认目标类内已无 `channelSubSkuList` 残留引用。

## 风险与关注点

- 旧历史订单若未写入 `subSkuList[].channelSubSkuId`，履约时会直接触发 `ORDER_CHANNEL_SUB_SKU_SNAPSHOT_MISSING`，不再尝试旧字段兜底。
- 本次仅清理 `FulfillmentVoucherServiceImpl`，不扩散修改其他模块。
