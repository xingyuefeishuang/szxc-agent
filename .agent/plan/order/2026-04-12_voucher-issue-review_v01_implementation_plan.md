# 发码逻辑审核与修复

## 背景

审核 plt-order-core 的发码逻辑，需支持平台内部发码规则和抖音回调 SPI 发码逻辑，明确 cmd 中 SKU 字段语义。

## 修复项

1. **DefaultVoucherIssueExecutor 状态判断 Bug**：`||` → `&&`，原逻辑会拒绝所有发码请求
2. **FulfillmentVoucherIssueItemCmd 字段重命名**：`skuId` → `channelSkuId`，`subSkuId` → `channelSubSkuId`
3. **日历票改走标准门面层**：由直接调用 VoucherIssueExecutor 改为通过 OrderFulfillmentFacadeService

## 待确认

- 日历票创单的渠道→平台商品映射
