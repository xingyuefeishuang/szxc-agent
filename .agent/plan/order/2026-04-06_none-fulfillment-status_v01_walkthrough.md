# NONE 履约类型状态语义补充总结

## 本次结论
- `NONE` 履约类型当前不新增状态。
- 支付成功后保持在 `PAID`，不进入 `DELIVERING`。

## 原因
- 当前状态机没有“待人工履约/待发货”之类的新状态。
- 直接把 `NONE` 类型推进到 `DELIVERING` 会把“未开始履约”和“已进入履约”混成一个语义。

## 本次落地
- 在 `NoopOrderFulfillmentStrategy` 注释中明确了保持 `PAID` 的行为。
- 在履约类型设计文档中补充了 `NONE` 和 `VOUCHER` 的当前状态语义。
