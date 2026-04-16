# 实施计划

## 任务

为 `o_fulfillment_item.fulfillment_status` 引入统一枚举，替换 `FulfillmentVoucherServiceImpl` 中的硬编码状态值。

## 实施步骤

1. 检查 `FulfillmentVoucherServiceImpl` 中 `setFulfillmentStatus(...)` 的现有赋值方式。
2. 对照订单设计文档中 `o_fulfillment_item.fulfillment_status` 的状态集合，新增统一枚举类。
3. 用枚举替换当前硬编码的 `"ISSUED"`。
4. 检查订单模块内 `FulfillmentStatusEnum` 的引用与状态赋值是否已收口。
5. 归档本次实施计划与工作总结。

## 风险与关注点

- 当前只替换了已发现的硬编码写入点，后续若新增状态流转逻辑，应继续统一使用该枚举。
- 本次不扩展实现履约项状态机，仅完成状态常量收敛。
