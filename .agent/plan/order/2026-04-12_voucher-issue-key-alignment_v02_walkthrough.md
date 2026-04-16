# 发码阶段 SKU 映射与幂等收口实施总结

## Summary
- 已把组合商品发码的子 SKU 解析从“猜测共值”调整为“消费订单快照映射”。
- 建单与发码现在使用同一条边界：建单写快照，发码读快照。
- 复杂逻辑注释已补充，原有注释未做无关删除。

## Completed Changes
- 新增 [OrderChannelSubSkuInfo.java](/D:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/support/OrderChannelSubSkuInfo.java)
  - 用于存储组合票渠道子 SKU 快照。
- 更新 [OrderProductFacadeServiceImpl.java](/D:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/impl/OrderProductFacadeServiceImpl.java)
  - 建单时把 `sourceItem.subSkuList` 同步转成 `channelSubSkuList` JSON。
  - 注释明确：平台 `skuId/subSkuId` 语义不因临时回退而改变。
- 更新 [FulfillmentVoucherServiceImpl.java](/D:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/impl/FulfillmentVoucherServiceImpl.java)
  - 引入 `ResolvedIssueTarget` / `MergedSubSkuInfo` 内部结构。
  - 显式发码先归一化到平台履约维度，再参与分桶和幂等。
  - `resolveSubSkuId(...)` 改为通过 `subSkuList + channelSubSkuList` 合并映射。
  - `containsChannelSubSku(...)` 改为解析 JSON 后精确匹配。
  - `getOrCreateFulfillmentItem(...)` 单独接收 `channelSubSkuId`，避免渠道字段写错。

## Verification
- 进行了静态代码自检，确认：
  - 旧的 `resolvePlatformSubSkuId(...)` 已移除。
  - 发码流程与数量统计都改为走 `resolveIssueTarget(...)`。
  - `channelSubSkuList` 快照在建单阶段已写入。
- 由于当前机器 Maven/JDK 环境仍不满足仓库 JDK 17 要求，未完成编译闭环：
  - 先前编译阻塞点：`plt-framework-swagger-starter`
  - 错误：`无效的目标发行版: 17`

## Risks
- 当前平台/渠道子 SKU 的映射仍依赖建单阶段列表顺序对齐；后续如需消除顺序依赖，应引入正式映射字段或映射表。
- 旧订单如果没有 `channelSubSkuList` 快照，组合商品显式发码会报 `ORDER_CHANNEL_SUB_SKU_SNAPSHOT_MISSING`。
