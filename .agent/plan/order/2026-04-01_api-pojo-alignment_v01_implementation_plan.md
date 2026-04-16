# 统一订单 API POJO 对齐实施计划

## 目标

修正 `plt-order-api` 中仍停留在旧版设计的 POJO，使其字段名和字段类型与 `plt-order-core/db/model` 当前实体保持一致，避免 `BeanUtil.copyProperties` 与序列化过程中出现静默丢字段或类型不匹配。

## 实施范围

### 1. 规则文档

- 在 `.agent/rules/AI_BEHAVIOR_RULES.md` 中补充：
- Maven 编译必须优先检查并遵循 `.agent/skills/maven-compile/SKILL.md`

### 2. 订单 API 对象

- `OrderBO`
- `OrderAddDO`
- `OrderUpdateDO`
- `OrderQueryDO`

对齐目标：
- `id -> orderId`
- `Integer orderStatus -> String orderStatus`
- 删除旧版设计中的 `productMappingId/platformProductId/channelProductId/productName/totalQuantity/...`
- 新增并保留 `parentOrderId/prodId/appId/channelUserId/payAmount/discountAmount/couponAmount/userId/userAccount/payType/clientIp/extendAttr`

### 3. 凭证 API 对象

- `VoucherBO`
- `VoucherAddDO`
- `VoucherUpdateDO`
- `VoucherQueryDO`

对齐目标：
- `id -> voucherId`
- `orderId -> orderItemId`
- `voucherStatus -> status`
- 删除旧版设计中的 `channelCode/holderName/holderIdCard/verifyTime/verifyChannel/verifyDeviceId`
- 新增 `userId/prodId/appId`

### 4. 退款 API 对象

- `RefundBO`
- `RefundAddDO`
- `RefundUpdateDO`
- `RefundQueryDO`

对齐目标：
- `id -> refundId`
- `Integer refundStatus -> String refundStatus`
- 删除旧版设计中的 `channelCode/channelRefundNo/refundQuantity/auditRemark/auditTime`
- 新增 `orderItemId/prodId/appId/userId`

### 5. OTA API 对象

- `OtaChannelConfig*`
- `OtaProductMapping*`

对齐目标：
- `configId/mappingId` 与主键一致
- `OtaChannelConfig*` 对齐 `appId/appSecret/privateKey/publicKey/status/extraConfig`
- `OtaProductMapping*` 对齐 `prodId/appId/channelSpuId/channelSkuId/spuId/skuId`

## 验证方式

1. 编译 `plt-order-service` 聚合模块。
2. 确认 API POJO 不再包含明显脱离当前实体结构的旧字段。
3. 验证发码链路中 `OrderBO.orderStatus` 不再因为类型不一致而导致转换异常。
