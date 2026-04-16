# OrderController 复审实施计划

## 范围
- 聚焦 `plt-order-core` 中 `OrderController` 暴露的对外接口。
- 只审查接口契约、参数校验、服务语义映射和已暴露但未完成的能力。

## 审查步骤
1. 阅读 `OrderController` 的所有入口方法。
2. 对照 `OrderService` 与 `OrderServiceImpl`，确认 controller 暴露语义是否与实现一致。
3. 检查请求对象校验是否足以支撑 controller 对外契约。
4. 输出按严重级别排序的问题清单。

## 约束
- 本次仅做静态代码审查，不改代码。
- 本次不展开到退款、核销等其他 controller。
