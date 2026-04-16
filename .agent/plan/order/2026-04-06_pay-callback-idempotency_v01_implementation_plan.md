# implementation_plan

## 基本信息
- 模块: `order`
- featureKey: `pay-callback-idempotency`
- 日期: `2026-04-06`

## 目标
- 修复支付回调在并发场景下因状态机条件更新失败而误报异常的问题。

## 问题描述
- 当前 `handlePayCallback` 在前置状态判断后，仍可能与并发线程竞争。
- 若另一个线程已经完成了 `PENDING -> PAID` 扭转，当前线程的 `transition(...)` 会返回 `false`。
- 旧逻辑会直接抛出 `PAY_CALLBACK_FAILED`，不能正确按幂等成功处理。

## 实施步骤
1. 保留现有前置“支付后状态直接成功返回”逻辑。
2. 在 `transition(...) == false` 时重查订单最新状态。
3. 若最新状态已越过支付红线，则按幂等成功返回。
4. 仅在重查后仍未进入支付后状态时，继续抛出异常。

## 约束
- 不改其他幂等链路。
- 不删除现有注释。
