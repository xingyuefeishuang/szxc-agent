# 抖音 B10 创单修正 v02 - 实施计划

## 背景

在继续审查抖音团购 B 类 SPI 时，回读了 `DouyinChannelAdapter` 里前一轮 B10 修正代码，发现仍有两类遗留问题：

1. 新增的日志和提示文案出现乱码。
2. B10 已不再使用的 `parseLongOrZero` 仍残留在适配器中，容易误导后续实现。

同时再次对照 `B10-团购预下单接口V2-SPI.md`，确认 `fail_sku_id_list` 属于失败响应字段，当前“任一 SKU 映射失败则整单拒绝并返回失败 SKU 列表”的收敛方案符合文档语义。

## 本次目标

1. 清理本轮 B10 修正里引入的乱码日志/提示。
2. 删除 `resolveSkuMapping` 旧兜底逻辑残留的死代码。
3. 再次核对 B10 文档，确认当前实现与 `fail_sku_id_list`、错误响应语义保持一致。

## 实施步骤

1. 回读 `DouyinChannelAdapter.handleCreateOrder`、`assembleGroupbuyItems`、`resolveSkuMapping`、`buildCreateOrderRejectResponse`。
2. 用结构化补丁修正乱码日志和错误描述。
3. 删除已无调用的 `parseLongOrZero` 方法。
4. 复核 B10 文档中 `fail_sku_id_list` 和错误码描述，确认当前行为是否需要继续调整。

## 结论预期

1. B10 当前保持“保守拒单”策略：
   - 任一 SKU 映射失败
   - 直接返回失败
   - `fail_sku_id_list` 带失败 SKU
2. 不实现“部分 SKU 成功创单”，避免在没有金额/库存拆分设计前引入脏单。
3. 后续优先继续审 B11 的同步/异步发码和 `project_id` 体系。
