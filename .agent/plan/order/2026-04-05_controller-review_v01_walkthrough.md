# walkthrough

## 工作概览
- 已阅读仓库规范文档，包括 `AGENTS.md`、`PROJECT_STRUCTURE.md`、`AI_BEHAVIOR_RULES.md` 与 `PLAN_ARCHIVE_NAMING_STANDARD.md`。
- 已审查 `plt-order-core` 主控制器 `OrderController`、`RefundController`、`VerifyController`、`VoucherController`，并补充检查 `DouyinSpiController`。
- 已追踪对应 `OrderServiceImpl`、`RefundApplyServiceImpl`、`VoucherServiceImpl`、`OrderStateMachine`、相关 `DO/VO/Cmd` 与订单设计文档，确认接口语义与实际实现之间的偏差。

## 本次 review 关注点
- 回调接口是否满足重复通知场景下的幂等要求。
- 控制器路由是否真正约束调用语义，而不是把关键行为交给客户端自由传参。
- 对外 SPI 是否按协议做安全校验。
- 暴露出来的接口是否仍是占位实现。
- 请求模型是否支持的能力与 service 实际实现是否一致。

## 结论摘要
- 发现多处需要尽快修复的接口问题，主要集中在:
  - 抖音 SPI 预下单接口未验签。
  - 支付回调对重复通知不幂等。
  - 退款申请接口暴露了“按子单退款”的输入能力，但实现实际按整单处理。
  - 核销接口的路由语义未落地，`verifyChannel` 仍由客户端决定。
  - 价格试算接口已对外暴露，但 service 仍为空实现。

## 输出方式
- 以正式 review 结果返回，按严重度列出 findings，并附绝对路径与行号引用。
