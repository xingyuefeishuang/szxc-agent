# plt-order-core 下一阶段实施计划（v01）

## 1. 现状判断（基于当前代码）
- 已完成：订单核心实体/Mapper/Service 骨架、状态机基线、抖音 SPI 主入口（A10/A11/A12/A14/A21/A30/A31/A33/B10/B11/B20/B22）与部分协议对齐。
- 未完成：退款审核实链路、渠道 SKU 映射真实落库、库存/延迟关单、订单详情聚合与分页、凭证效期规则、验签与外部回写。

## 2. 下一步实施优先级
1. P0 退款闭环先打通（最影响业务正确性）
2. P0 渠道映射改为真实查询（最影响数据正确性）
3. P1 下单稳定性与履约一致性（库存锁、延迟关单、核销后完结）
4. P1 对外安全与可用性（验签、幂等、回写重试）
5. P2 查询与运营能力（分页、详情聚合、延期）

## 3. 分阶段执行清单

### 阶段A（P0）：退款链路闭环
- 文件：`RefundApplyServiceImpl`、`DouyinChannelAdapter`
- 目标：
  - `handleRefundApply` 不再固定“同意”，改为真实调用 `refundApplyService.applyRefund`。
  - 按 `voucher` 状态返回接受/拒绝/待审核，填充 `refund_fee_amount`。
  - `handleRefundNotify` 落内部终态（退款单/订单/凭证状态一致）。
  - A30 `AfterPay` 与退款链路打通，避免仅日志落地。
- 验收：
  - 已核销票必须拒退。
  - 未核销票退款后凭证应进入 `INVALID`，订单进入 `REFUNDED` 或部分退款态（按规则）。

### 阶段B（P0）：渠道商品映射真实化
- 文件：`DouyinChannelAdapter.resolveSkuMapping`
- 目标：
  - 启用 `o_channel_sku_mapping` 查询，失败直接按协议返回不可售，不再外部 ID 兜底转 Long。
  - 同步校验 `channel_code + channel_sku_id (+ app_id/client_key)` 的唯一性约束。
- 验收：
  - 错配/缺配 SKU 时不应创建内部订单。

### 阶段C（P1）：下单与履约一致性
- 文件：`OrderServiceImpl`、`VoucherServiceImpl`、`VoucherController`
- 目标：
  - 下单加库存锁与扣减、取消单释放库存。
  - 投递延迟关单消息并补消费端（至少预留可靠接口）。
  - 发券补齐 `voucherValidityType` 规则；核销后判断“是否全部核销完成”并推进 `COMPLETED`。
  - 实现 `/voucher/delay` 真正延期逻辑。
- 验收：
  - 同单并发回调不重复发券、不重复扣减。

### 阶段D（P1）：安全与可靠性
- 文件：`DouyinSpiController`、`DouyinChannelAdapter`
- 目标：
  - 接入 `x-life-sign` 验签。
  - 退款/通知加幂等键（`bizUniqKey`）防重。
  - 核销/退款回写失败进入重试队列（RocketMQ 延迟重试）。
- 验收：
  - 相同通知重放不产生重复副作用。

### 阶段E（P2）：查询与运营补齐
- 文件：`OrderServiceImpl.getOrderDetail/pageQuery`
- 目标：
  - `getOrderDetail` 聚合子单+凭证列表。
  - `pageQuery` 支持多维条件（orderNo/channel/status/user/time 区间）。
  - 输出字段与 `OrderQueryDO/OrderBO` 一致。
- 验收：
  - 支持运营分页检索与详情链路排障。

## 4. 建议交付顺序
1. A 退款闭环
2. B 映射真实化
3. C 履约一致性
4. D 安全可靠
5. E 查询补齐

## 5. 风险与前置依赖
- 需要确认：部分退款状态是否新增 `PARTIAL_REFUNDED`（当前枚举未落地）。
- 需要确认：库存来源服务与消息主题命名（RocketMQ topic/tag）。
- 需要确认：抖音回写 API 凭据与签名材料。
