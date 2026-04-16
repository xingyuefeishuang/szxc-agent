# 统一商品解析命令骨架 v02 - 工作总结

## 本次改动

### 1. 抖音 B10 已真正接入统一商品门面

文件：
- `plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/channel/douyin/adapter/DouyinChannelAdapter.java`

变更：
- `DouyinChannelAdapter` 新增注入 `OrderProductFacadeService`
- `handleCreateOrder(...)` 中，B10 路径不再直接调用 `assembleGroupbuyItems(...)`
- 改为：
  1. 组装 `OrderProductResolveCmd`
  2. 调 `orderProductFacadeService.resolveCreateItems(...)`
  3. 从结果里拿：
     - `items`
     - `failItemKeys`

### 2. 新增了 B10 的统一命令组装

新增方法：
- `buildGroupbuyResolveCmd(DouyinCreateOrderRequest request)`

作用：
- 把抖音 `sku_info_list + order_item_list` 转成统一 `OrderProductResolveCmd`
- 当前仍在适配层做协议字段展开和数量统计

### 3. 商品门面默认实现已接入 DOUYIN + B10 过渡解析

文件：
- `plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/impl/OrderProductFacadeServiceImpl.java`

新增逻辑：
- `resolveCreateItems(...)` 里先识别：
  - `channelCode = DOUYIN`
  - `bizType = B10`
- 命中后走：
  - `resolveDouyinGroupbuyItems(...)`

当前解析规则：
- `sku_out_id` 优先承载内部 `skuId`
- `product_out_id` 优先承载内部 `spuId`
- 否则回退到 `sku_id/product_id`
- 解析失败则进 `failItemKeys`

## 当前边界

### 已达成

1. `OrderProductFacadeService.resolveCreateItems(...)` 不再是空定义未使用
2. B10 已开始按“适配层转统一命令 -> 商品门面统一解析”的结构工作

### 仍保留

1. A11 仍走旧逻辑
2. `assembleGroupbuyItems(...)` 等旧方法暂时仍在类里，作为迁移期残留
3. 真正商品域和库存域仍未接入

## 结论

这一步已经验证了统一商品门面的设计方向是可落地的：

- 适配层负责协议转换
- 商品门面负责商品识别

但目前只迁移了抖音 B10，一次只动一条链路，风险更可控。
