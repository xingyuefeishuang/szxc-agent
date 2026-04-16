# 统一商品解析命令骨架 v01 - 工作总结

## 本次改动

### 1. 扩展了订单商品门面接口

文件：
- `plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/OrderProductFacadeService.java`

新增方法：
- `OrderProductResolveResult resolveCreateItems(OrderProductResolveCmd cmd)`

语义：
- 适配层先把抖音、美团等原始协议 DTO 转成统一商品解析命令
- 商品门面只消费统一命令，不直接暴露渠道专属方法

### 2. 新增统一商品解析输入模型

文件：
- `plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/cmd/OrderProductResolveCmd.java`

当前字段：
- `channelCode`
- `bizType`
- `channelOrderNo`
- `items`

子项字段：
- `channelSpuId`
- `channelSkuId`
- `channelSpuOutId`
- `channelSkuOutId`
- `quantity`
- `price`

### 3. 新增统一商品解析结果模型

文件：
- `plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/cmd/OrderProductResolveResult.java`

当前字段：
- `items`
- `failItemKeys`

并提供：
- `hasFailure()`

### 4. 默认实现仅保留骨架

文件：
- `plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/impl/OrderProductFacadeServiceImpl.java`

当前行为：
- 仅打印 debug 日志
- 返回空结果
- 用 TODO 标明后续由商品域/渠道商品识别能力接入

## 当前边界

### 已明确

1. `OrderProductFacadeService` 不会长成 `resolveDouyinItems(...)`、`resolveMeituanItems(...)` 这种渠道专属方法集合。
2. 渠道适配层负责把原始协议 DTO 转成统一 `OrderProductResolveCmd`。
3. 商品门面负责统一解析。

### 暂未迁移

1. 抖音 B10 当前的 `assembleGroupbuyItems(...)`
2. 日历票 `assembleCalendarItems(...)`
3. 现有 `resolveSkuMapping(...)`

这些逻辑还在 `DouyinChannelAdapter`，本次没有贸然搬迁，避免在商品域尚未接入前打断现有创单路径。

## 后续建议

1. 下一步可先把抖音 B10/B11 的商品识别逻辑改造成：
   - 适配器组装 `OrderProductResolveCmd`
   - 商品门面内部按 `channelCode/bizType` 做过渡实现
2. 等商品域正式接入后，再替换 `OrderProductFacadeServiceImpl` 的内部实现。
