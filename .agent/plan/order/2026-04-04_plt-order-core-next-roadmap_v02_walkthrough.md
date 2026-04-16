# plt-order-core 下一阶段计划梳理总结（v02）

## 1. 本次调整依据
- 依据你的最新约束，重排计划优先级：
  - 先不做商品映射对接。
  - 先不做库存扣减/回补。
  - 先聚焦退款闭环、验签、回写能力。

## 2. `PARTIAL_REFUNDED` 结论
- 它是“部分退款完成但订单未完全结束”的主单状态概念。
- 当前代码未定义该枚举，本轮不强行引入，先在退款处理逻辑中以 TODO 明确后续扩展点。

## 3. 抖音文档与现状核对
- 已核对仓库内抖音资料：
  - `.agent/references/ota/douyin/SPI签名机制.md`
  - `.agent/references/ota/douyin/A14-支付通知SPI(可选对接).md`
  - `.agent/references/ota/douyin/A31-申请退款审核SPI.md`
  - `.agent/references/ota/douyin/A33-退款结果通知SPI.md`
  - `.agent/references/ota/douyin/B20-退款审核SPI.md`
- 现状判断：
  - `DouyinSignVerifyUtil` 已具备签名算法实现，但控制器尚未接入。
  - 回写 API 目前仍是占位日志。
  - SDK 依赖已声明，但本地仓库未成功下载（仅 `.lastUpdated`）。

## 4. 产出
- 形成 v02 实施计划，主线变更为：
  - 退款闭环 > 验签接入 > 回写能力 > 映射/库存 TODO 延后
- 维持与 v01 同 featureKey，版本升级为 `v02`。
