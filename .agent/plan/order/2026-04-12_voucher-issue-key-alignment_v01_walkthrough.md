# 发码唯一键与命令语义收口实施总结

## Summary
- 完成 `plt-order-core` 发码链路的唯一键修正。
- 保持显式发码命令只传渠道字段，平台 `skuId/subSkuId` 改为服务内部解析。
- 为复杂发码逻辑补充了面向业务原因的中文注释，并保留原有注释语义。

## Completed Changes
- `FulfillmentVoucherServiceImpl`
  - 显式发码主流程改为先按 `channelOrderItemId/channelSkuId/channelSubSkuId` 定位 `OrderItem`
  - 履约桶键、渠道幂等键统一带上平台 `skuId`
  - 新增 `resolvePlatformSubSkuId(...)`，通过订单快照归一平台子 SKU
  - `getOrCreateFulfillmentItem(...)` 查重条件补上 `skuId`
  - `findExistingVoucher(...)` 注释明确两层幂等逻辑和 `reusedCountMap` 的作用
- `ScenicGroupbuyDouyinSolution`
  - 补充注释，明确发码明细只做协议翻译，不回填平台 SKU
- `OrderProductFacadeServiceImpl`
  - 补充注释，限定“内部 SKU = 外部 SKU”仅是临时兼容

## Verification
- 进行了静态签名自检，确认 `FulfillmentVoucherServiceImpl` 内部调用已同步到新键签名。
- 执行 `mvn -pl plt-core-service/plt-order-service/plt-order-core -am -DskipTests compile` 时，构建在上游模块 `plt-framework-swagger-starter` 被环境阻塞：
  - 错误：`无效的目标发行版: 17`
  - 结论：当前机器 Maven/JDK 环境未满足仓库 JDK 17 要求，因此未能完成订单模块编译验证。

## Risks
- `resolvePlatformSubSkuId(...)` 当前仍依赖订单快照中子 SKU 与渠道子 SKU 可匹配；若后续引入正式映射表，应优先替换为映射表解析。
- `resolveOrderItemByChannelSku(...)` 在 `channelSkuId` 非唯一的极端场景下仍依赖 `channelOrderItemId` 或单条订单项兜底，后续如出现多条同渠道 SKU 订单项，应继续增强匹配条件。
