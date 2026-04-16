# implementation_plan

## 基本信息
- 模块: `order`
- featureKey: `controller-fixes`
- 日期: `2026-04-05`
- 任务类型: 缺陷修复

## 目标
- 修复 `plt-order-core` 中用户确认的两个问题:
  - 抖音 `groupbuy/createOrder` SPI 缺少验签前置
  - `handlePayCallback` 对重复支付通知幂等不足

## 约束
- 不删除用户已有注释。
- 不处理仍在讨论中的退款接口语义问题。

## 实施步骤
1. 在 `DouyinSpiController.groupbuyCreateOrder` 中复用现有 `verifySignature(...)`。
2. 在 `OrderServiceImpl.handlePayCallback` 中扩展重复回调幂等判定范围。
3. 增加局部私有辅助方法，避免修改现有状态机定义。
4. 复查改动行，确认注释保留、结构未破坏。

## 预期结果
- 抖音预下单 SPI 与其他 SPI 入口保持一致的验签行为。
- 对已经越过支付红线的订单，重复支付通知直接按成功处理，不再因状态机回退失败抛异常。
