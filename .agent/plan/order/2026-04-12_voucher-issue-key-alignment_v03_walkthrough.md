# 工作总结

## 本次调整

- `OrderSubSkuInfo` 已补充渠道子 SKU 字段，`subSkuList` 现在同时保存平台子 SKU 与渠道子 SKU 的映射关系。
- `OrderProductFacadeServiceImpl` 建单时已把渠道子 SKU 信息并入 `subSkuList`，不再依赖新建的独立渠道快照。
- `FulfillmentVoucherServiceImpl` 发码时优先从 `subSkuList` 中解析渠道子 SKU 到平台子 SKU 的映射；如果遇到历史订单仍只有 `channelSubSkuList`，则走兼容兜底。

## 影响

- 新订单只需要一份 `subSkuList` 快照即可支持后续发码映射。
- 历史订单不需要立即迁移，现有 `channelSubSkuList` 仍可被读取。
