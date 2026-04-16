# 统一商品解析命令骨架 v01 - 实施计划

## 背景

在继续审查抖音 B 类 SPI 时，确认了一个中期结构问题：

- `DouyinChannelAdapter` 里已经开始承接商品识别逻辑
- 但商品相关能力的长期归属应该是 `OrderProductFacadeService`
- 同时又不能让 `OrderProductFacadeService` 暴露一堆渠道专属方法，例如 `resolveDouyinItems(...)`

因此，需要先在订单商品门面上建立“统一商品解析命令 -> 统一解析结果”的稳定边界。

## 本次目标

1. 为 `OrderProductFacadeService` 增加统一商品解析方法。
2. 新增统一输入/输出模型：
   - `OrderProductResolveCmd`
   - `OrderProductResolveResult`
3. 只落骨架，不改变当前抖音创单主流程行为。

## 实施步骤

1. 扩展 `OrderProductFacadeService` 接口。
2. 新增统一商品解析命令对象，容纳渠道通用字段。
3. 新增统一解析结果对象，返回标准下单项和失败项。
4. 在 `OrderProductFacadeServiceImpl` 中补默认空实现和 TODO 注释。

## 本次不做

1. 不把 B10 当前解析逻辑强行迁到商品门面。
2. 不接商品域或 `o_channel_sku_mapping` 正式能力。
3. 不改现有抖音创单行为，避免一次改动过大。
