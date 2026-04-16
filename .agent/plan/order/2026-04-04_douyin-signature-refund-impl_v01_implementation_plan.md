# 抖音验签与退款链路落地实施计划（v01）

## 1. 实施目标
- 在 `DouyinSpiController` 全量接入 SPI 验签，拦截无效请求。
- 在 `DouyinChannelAdapter` 将退款审核/退款通知由占位逻辑改为可执行流程。
- 在 `RefundApplyService` 增加“按订单完成退款终态”能力，支撑通知回落。

## 2. 具体改动
1. `DouyinSpiController`
- 增加 `verifySignature` 统一验签入口。
- 按 `x-life-clientkey` 查询 `o_channel_config(appId)` 取 `appSecret`。
- 用 `DouyinSignVerifyUtil` 校验新签名（`x-life-sign`）并兼容旧签名。
- 所有 `/spi/douyin/*` 方法进入业务前先验签。

2. `DouyinChannelAdapter`
- `handleRefundApply`：
  - 接入 `biz_uniq_key` 幂等缓存（Redis，1天）。
  - 已核销券直接拒绝退款（`audit_refund_result=2`）。
  - 可退款时创建内部退款申请并返回等待审核（`audit_refund_result=3`）。
- `handleRefundNotify`：
  - 接入通知幂等缓存（Redis，1天）。
  - 调用 `refundApplyService.completeRefundByOrderNo` 推进内部终态。
  - 失败返回 `error_code=100` 让抖音重试。

3. `RefundApplyService` / `RefundApplyServiceImpl`
- 新增 `completeRefundByOrderNo(orderNo, remark)`。
- 将最新退款单推进到 `SUCCESS`。
- 凭证从 `USABLE/LOCKED` 收敛为 `INVALID`（保留 `VERIFIED/INVALID`）。
- 订单状态按状态机推进至 `REFUNDED`（幂等处理）。

## 3. 边界与保留
- 商品映射能力未接入：继续保持 TODO。
- 库存能力未接入：继续保持 TODO。
- 回写抖音 OpenAPI 仍保留 TODO（本次聚焦入站验签与退款闭环）。

## 4. 验证
- 编译命令：
  - `mvn -pl plt-core-service/plt-order-service -am -q compile -DskipTests -s 'D:\05-Development Tools\apache-maven-3.5.4\conf\settings.xml'`
- 结果：通过。
