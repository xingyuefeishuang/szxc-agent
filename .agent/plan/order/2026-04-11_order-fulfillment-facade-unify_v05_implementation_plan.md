# 订单履约命名收敛实施计划

## 目标

继续统一履约策略层和发码二级执行层的命名，避免同时混用 `strategy / action / executor`：

1. 将 `FulfillmentVoucherOrderFulfillmentStrategy` 收敛为 `VoucherOrderFulfillmentStrategy`
2. 将 `VoucherFulfillmentAction` 收敛为 `VoucherFulfillmentExecutor`
3. 将注入集合字段统一为 `voucherFulfillmentExecutors`

## 实施项

1. 重命名发码顶层主策略类及其引用
2. 重命名发码二级接口及其实现类引用
3. 同步调整异常码和日志措辞中的 `ACTION` 语义
4. 全量检索旧命名残留
5. 编译验证 `plt-order-service`

## 验证点

- 代码中不再存在 `FulfillmentVoucherOrderFulfillmentStrategy`
- 代码中不再存在 `VoucherFulfillmentAction`
- 发码主策略通过 `voucherFulfillmentExecutors` 路由二级执行器
- `mvn clean compile -DskipTests` 通过
