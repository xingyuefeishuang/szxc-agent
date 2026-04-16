# 订单履约二级执行方法命名收敛实施计划

## 目标

将发码二级执行器的方法名从 `fulfill(...)` 统一收敛为 `execute(...)`，与顶层 `OrderFulfillmentStrategy.fulfill(...)` 做职责区分。

## 实施项

1. 调整 `VoucherFulfillmentExecutor` 接口方法签名为 `execute(...)`
2. 同步修改三个发码二级执行器实现
3. 修改 `VoucherOrderFulfillmentStrategy` 中的调用入口
4. 清理二级执行器接口和主策略中的历史乱码注释/日志
5. 编译验证 `plt-order-service`

## 验证点

- `VoucherFulfillmentExecutor` 暴露 `execute(...)`
- `VoucherOrderFulfillmentStrategy` 内部通过 `executor.execute(...)` 路由
- 顶层 `OrderFulfillmentStrategy` 仍保持 `fulfill(...)`
- `mvn clean compile -DskipTests` 通过
