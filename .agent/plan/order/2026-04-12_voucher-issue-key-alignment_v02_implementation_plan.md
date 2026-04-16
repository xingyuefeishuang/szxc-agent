# 发码阶段 SKU 映射与幂等收口

## Summary
- 保持 `FulfillmentVoucherIssueItemCmd` 只承载渠道字段。
- 建单阶段把渠道子 SKU 快照同步落到 `OrderItem.channelSubSkuList`。
- 发码阶段通过 `OrderItem.subSkuList + OrderItem.channelSubSkuList` 合并出平台/渠道子 SKU 对照表，再解析平台 `subSkuId`。
- 发码幂等、履约分桶、履约项查重统一基于 `orderItemId + skuId + subSkuId`。

## Implementation Changes
- `OrderProductFacadeServiceImpl`
  - 为组合商品生成 `channelSubSkuList` JSON 快照。
  - 新增 `OrderChannelSubSkuInfo` 作为渠道子 SKU 快照结构。
- `FulfillmentVoucherServiceImpl`
  - 新增 `resolveIssueTarget(...)`，先定位 `OrderItem`，再归一到平台 `skuId/subSkuId`。
  - 新增 `buildMergedSubSkuMappings(...)`，按建单快照顺序合并平台/渠道子 SKU。
  - 删除仅凭 `subSkuList` 猜平台子 SKU 的逻辑。
  - `containsChannelSubSku(...)` 改为解析 `channelSubSkuList` 后精确匹配。
  - `getOrCreateFulfillmentItem(...)` 增加 `channelSubSkuId` 入参，避免 `channelSubSkuId` 落成平台值。
- 幂等键保持：
  - 履约桶键：`orderItemId + skuId + subSkuId`
  - 渠道精确幂等键：`orderItemId + skuId + subSkuId + channelVoucherId`

## Test Plan
- 组合商品建单后，`OrderItem.channelSubSkuList` 应落库为可解析 JSON。
- 发码时，`channelSubSkuId` 能通过订单快照映射到正确平台 `subSkuId`。
- 快照缺失或平台/渠道子 SKU 列表长度不一致时，显式报错，不继续猜测映射。
- `FulfillmentItem.channelSubSkuId` 与渠道侧值一致，不再写入平台值。
- 仓库编译仍尝试执行订单模块最小编译；若 JDK 17 环境不满足，记录为验证阻塞。

## Assumptions
- `subSkuList` 与 `channelSubSkuList` 在建单阶段顺序对齐。
- 不带 `channel` 前缀的字段默认表示平台内部语义。
- 对旧订单若缺少 `channelSubSkuList` 快照，组合商品显式发码会直接失败，而不是做不可靠兜底。
