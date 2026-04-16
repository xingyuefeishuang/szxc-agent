# 抖音 B10 创单修正 v02 - 工作总结

## 本次处理

### 1. 清理了 B10 修正里残留的乱码文本

文件：
- `plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/channel/douyin/adapter/DouyinChannelAdapter.java`

修正内容：
- `handleCreateOrder(...)` 中 “SKU 映射失败” 的 warn 日志恢复为正常中文。
- `buildCreateOrderRejectResponse(...)` 的错误描述恢复为 `商品已下架或SKU映射不存在`。
- `resolveSkuMapping(...)` 中 “SKU 映射未找到” 的 warn 日志恢复为正常中文。

### 2. 删除了无效的旧兜底方法

已删除：
- `parseLongOrZero(String value)`

原因：
- B10 映射逻辑已经改为必须查询 `o_channel_sku_mapping`
- 不再允许把外部 `sku_out_id/product_out_id` 强行解析成数字 ID
- 保留该方法只会误导后续继续走错误兜底

### 3. 再次核对 B10 文档语义

对照：
- `.agent/references/ota/douyin/B10-团购预下单接口V2-SPI.md`

确认结论：
- `fail_sku_id_list` 属于失败响应字段
- 文档未要求“部分 SKU 成功也继续创单”
- 当前实现收敛为：
  - 任一 SKU 映射失败
  - 直接失败返回
  - `error_code != 0`
  - `fail_sku_id_list` 返回失败 SKU

该方案在当前阶段是合理的保守实现。

## 当前 B10 状态

### 已解决

1. 不再把非数字外部 SKU ID 解析为 `0`
2. 已真正查询 `o_channel_sku_mapping`
3. 支持返回失败 SKU 列表
4. 组合子 SKU 数量不再固定写死为 `1`

### 仍是设计选择而非缺陷

1. 当前只要有失败 SKU 就整单拒绝
2. 不支持“部分 SKU 成功创单”

这是刻意收敛，避免在没有金额拆分和库存拆分设计前生成不完整订单。

## 后续建议

1. 优先继续审 B11：
   - 是否支持异步发码 `result=0`
   - `project_id` 是否建立稳定映射
2. 再继续看 B20/B22：
   - 当前异步审核 / 整单退款语义是否与抖音文档能力边界一致
