# 发码唯一键与命令语义收口

## Summary
- 保持 `FulfillmentVoucherIssueItemCmd` 只承载渠道侧字段，不向命令模型补平台 `skuId/subSkuId`。
- 在 `FulfillmentVoucherServiceImpl` 内部完成渠道字段到平台履约维度的解析。
- 将显式发码的幂等键、履约桶键、履约项查重键统一收口为 `orderItemId + skuId + subSkuId`。

## Implementation Changes
- 调整 `FulfillmentVoucherServiceImpl.issueVouchers(OrderFulfillmentCmd cmd)`：
  - 显式发码仍只消费 `channelOrderItemId/channelSkuId/channelSubSkuId/channelVoucherId`。
  - 先解析到平台 `OrderItem`，再从订单快照提取平台 `skuId/subSkuId` 参与分桶和幂等。
- 调整幂等辅助方法：
  - `buildIssueQuantityKey(...)` 改为 `orderItemId + skuId + subSkuId`
  - `buildChannelVoucherKey(...)` 改为 `orderItemId + skuId + subSkuId + channelVoucherId`
  - `findExistingVoucher(...)` 改为先精确复用渠道券，再按履约桶顺序复用
- 调整履约项查重：
  - `getOrCreateFulfillmentItem(...)` 增加 `skuId` 维度，避免仅凭 `subSkuId` 合并履约项
- 调整渠道适配注释：
  - 抖音团购发码 DTO 只做协议翻译，不回填平台 SKU
  - 商品解析门面的“内部 SKU = 外部 SKU”仅作为过渡兼容，不代表领域语义

## Test Plan
- 校验普通商品 `subSkuId=0` 场景下，不同平台 `skuId` 不会落入同一履约桶。
- 校验组合商品同一 `orderItem` 下，不同 `subSkuId` 会形成不同履约桶。
- 校验同一 `channelVoucherId` 重复回调时命中同一张券。
- 校验未携带 `channelVoucherId` 时，按 `orderItemId + skuId + subSkuId` 顺序复用已有券。
- 编译检查以订单模块为目标执行；若环境 JDK 不满足 17，记录为外部阻塞。

## Assumptions
- 领域主语义仍为平台 SKU，渠道标识统一使用 `channel*` 前缀。
- `FulfillmentVoucherIssueItemCmd` 不对外暴露平台 `skuId/subSkuId`。
- 当前阶段平台与渠道子 SKU 可能同值，子 SKU 解析优先按订单快照匹配，无法匹配时保留渠道值作为兼容回退。
