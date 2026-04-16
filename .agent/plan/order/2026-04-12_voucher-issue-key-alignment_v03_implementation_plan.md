# 实施计划

## 目标

- 将渠道子 SKU 映射从独立 `channelSubSkuList` 收口到 `subSkuList` 内部。
- 发码阶段优先消费 `OrderSubSkuInfo` 中的平台/渠道子 SKU 对应关系。
- 保留对旧 `channelSubSkuList` 快照的兼容读取，避免历史订单回归。

## 变更点

- 在 `OrderSubSkuInfo` 中增加 `channelSubSkuId/channelSubSkuName`。
- 建单阶段写入 `subSkuList` 时同步固化渠道子 SKU 信息，不再额外构造新的渠道子 SKU 快照。
- 发码阶段的子 SKU 映射优先读取 `subSkuList`，旧 `channelSubSkuList` 仅作为兼容兜底。
- 保持 `cmd item` 只承载渠道字段，履约幂等仍基于平台 `orderItemId + skuId + subSkuId`。
