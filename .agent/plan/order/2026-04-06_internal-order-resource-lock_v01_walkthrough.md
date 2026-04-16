# 内部订单资源锁统一工作总结

## 本次修改

- 新增统一内部订单资源锁前缀：
  - `PLT:ORDER:LOCKER:`
- `cancel/payCallback/apply` 三个入口改为共用同一个 `orderNo` 锁

## 当前效果

- 同一订单的：
  - 取消
  - 支付回调
  - 退款申请
  现在会在 Controller 入口层按同一把资源锁串行

## 当前边界

- `audit/callback` 仍未接入同锁
- 原因是这两个入口当前不稳定直接携带 `orderNo`
