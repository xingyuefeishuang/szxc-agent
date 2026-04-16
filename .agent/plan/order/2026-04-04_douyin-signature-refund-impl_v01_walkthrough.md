# 抖音验签与退款链路落地总结（v01）

## 1. 完成内容
- 已在 `DouyinSpiController` 为全部抖音 SPI 入口增加统一验签。
- 已将 `DouyinChannelAdapter` 的退款审核与退款通知从 TODO 改为可执行逻辑。
- 已在 `RefundApplyServiceImpl` 增加渠道通知驱动的退款终态收敛方法。
- 已接入 Redis 幂等键，避免 `biz_uniq_key` 重放重复处理。

## 2. 关键行为变化
- 验签失败将直接拦截并返回签名错误，不再进入业务。
- 退款审核不再固定“同意”，会依据凭证状态决定拒绝/等待审核。
- 退款通知可真实推进内部退款单、凭证、订单状态，且支持幂等重入。

## 3. 验证结果
- `plt-order-service` 模块在 JDK17 下编译通过（`-DskipTests`）。

## 4. 后续建议
- 下一步可继续接出站回写（`notifyVerifyResult/notifyRefundResult`）并落重试队列。
- 商品映射与库存待外部能力对接后再落地，当前保留 TODO 边界是合理的。
