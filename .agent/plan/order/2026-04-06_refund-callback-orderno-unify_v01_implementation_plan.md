# 退款回调按订单号兼容统一实施计划

## 目标

- 将退款成功回写统一收敛到 `handleRefundCallback(...)`
- 支持当前整单退款阶段按 `orderNo` 兼容定位退款单
- 去掉单独的 `completeRefundByOrderNo(...)` 公开入口

## 实施步骤

1. 给 `RefundCallbackDO` 增加 `orderNo`
2. 增加 `refundNo/orderNo` 二选一校验
3. `handleRefundCallback(...)` 支持按 `refundNo` 优先、`orderNo` 兼容定位
4. 删除 `completeRefundByOrderNo(...)` 的公开接口与实现
5. 抖音退款通知直接构造 `RefundCallbackDO` 调用 `handleRefundCallback(...)`

## 边界

- 当前按 `orderNo` 定位仅适用于“只支持整单退款”的阶段性设计
- 后续若支持部分退款或同订单多笔退款，应重新收敛为按 `refundNo` 精确定位
