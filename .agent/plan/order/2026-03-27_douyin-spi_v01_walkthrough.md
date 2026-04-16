# 抖音渠道 SPI 对接 — 完成总结

> **日期**: 2026-03-27  
> **编译验证**: ✅ BUILD SUCCESS (65 源文件, 9.8s)

## 完成内容

### Phase A: DTO 层 (8 个新文件)

| 文件 | 职责 |
|------|------|
| `DouyinBaseResponse` | 通用 `{data:{error_code,...}}` 包装，`success()/fail()/retry()` 工厂方法 |
| `DouyinCreateOrderRequest` | 统一创单入参 — 团购(B10 `order_item_list`+`sku_info_list`) 和日历票(A11 单 SKU) |
| `DouyinIssueVoucherRequest` | 统一发码入参 — 团购(B11 `certificate_info_list` 纳秒时间) 和日历票(A21 `copies`) |
| `DouyinRefundApplyRequest` | 退款审核入参 — B20/A31 共用 |
| `DouyinRefundNotifyRequest` | 退款结果通知入参 — B22/A33 共用 |
| `DouyinCancelOrderRequest` | 取消订单通知 (A30) |
| `DouyinQueryOrderRequest` | 订单状态查询 (A12) |
| `DouyinCanBuyRequest` | 预订信息校验 (A10) |

### Phase B: DouyinSpiController (11 端点)

路径从 `/api/order/douyin/spi/*` 改为 **`/spi/douyin/*`**：

- `/spi/douyin/groupbuy/` — 4 个团购端点 (createOrder, issueVoucher, refundApply, refundNotify)
- `/spi/douyin/calendar/` — 7 个日历票端点 (canBuy, createOrder, queryOrder, issueVoucher, cancelOrder, refundApply, refundNotify)

### Phase C: DouyinChannelAdapter (9 个业务方法)

- `handleCreateOrder()` — 自适应团购/日历票，SKU 映射 → `StandardOrderCreateCmd`
- `handleGroupbuyIssueVoucher()` / `handleCalendarIssueVoucher()` — 发码并组装不同格式响应
- `handleRefundApply()` — 退款审核
- `handleRefundNotify()` / `handleCancelOrder()` — 通知类接口
- `handleQueryOrder()` / `handleCanBuy()` — 查询类接口

## 关键设计决策

1. **统一 DTO 而非分拆**：团购和日历票的创单/发码请求字段有 80% 重叠，通过 `biz_type` 区分
2. **通知类接口始终返回成功**：`cancelOrder`/`refundNotify` 即使异常也返回 `error_code=0`
3. **验签预留**：每个 SPI 方法接收 `x-life-sign` header，当前标 TODO

## 已知 TODO

- [ ] `DouyinSignVerifyUtil` 集成到 SPI 验签流程
- [ ] 幂等机制（根据 `channelOrderNo`/`bizUniqKey`）
- [ ] `handleCanBuy` 库存/限购校验逻辑
- [ ] 抖音 OpenAPI 回写（核销/退款异步回调）
- [ ] 发码回调接口（异步发码场景）
