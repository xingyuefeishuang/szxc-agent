# 抖音下单默认值适配实施计划

## 目标

在不破坏统一订单中心分层边界的前提下，补齐抖音 SPI 创单、发券、查单链路中的关键适配缺口，确保核心模型可稳定入库，并避免抖音重试导致重复建单、重复发券。

## 实施原则

1. 默认值收口在 Core 层，不在抖音适配层散落平台内部字段规则。
2. 抖音适配层只负责协议转换，缺失字段允许留空，由统一订单核心补齐。
3. 默认值仅覆盖“渠道天然取不到、但内部表结构要求稳定”的字段；业务语义不明确的字段保持现有含义，不额外伪造。

## 变更范围

### 1. OrderServiceImpl

- 在 `createOrder()` 中统一补齐：
- `userId -> "0"`
- `userAccount -> ""`
- `prodId -> "0"`
- `appId -> "0"`
- `totalAmount/payAmount/discountAmount/couponAmount -> BigDecimal.ZERO`
- `payType -> 0`
- `createUser/modifyUser -> 由 userId 安全解析，失败时回退 0L`
- `deleted -> 0`

### 2. OrderItem 入库

- 子单继承主单标准化后的 `userId/prodId/appId`
- `price/couponAmount -> BigDecimal.ZERO`
- `refundStatus -> "NONE"`
- `createUser/modifyUser -> auditUserId`
- `deleted -> 0`

### 3. VoucherServiceImpl

- 发券时统一补齐：
- `userId -> "0"`
- `prodId/appId -> "0"`
- `createUser/modifyUser -> 继承子单，缺失回退 0L`
- `deleted -> 0`

### 4. DouyinChannelAdapter

- 创单前增加 `channelOrderNo` 幂等检查
- 重复创单直接返回既有平台订单号
- 发码前优先查询已有凭证，重复回调不再重复发券
- 查单时直接读取 core 实体状态并统计已核销凭证数量

### 5. OrderServiceImpl.getOrderDetail

- 显式回填 `OrderBO.id = order.orderId`
- 修复 adapter 通过 `order.getId()` 取主键时可能为 `null` 的问题

## 验证方式

1. 编译 `plt-order-core` 模块确认无语法问题。
2. 用抖音创单/发券请求验证：
- 未传内部用户、产品线、应用字段时不再触发入库异常。
- `o_order`、`o_order_item`、`o_voucher` 三层字段值保持一致。
3. 用同一抖音 `orderId` 连续重复请求验证：
- 创单不会重复落库。
- 发码不会重复生券。

## 风险与后续

1. 当前仓库编译要求 JDK 17，本机仅发现 JDK 11，需补齐环境后再做完整编译验证。
2. 后续若美团/小程序接入，继续复用同一套 Core 默认值策略，不在各渠道 adapter 重复实现。
