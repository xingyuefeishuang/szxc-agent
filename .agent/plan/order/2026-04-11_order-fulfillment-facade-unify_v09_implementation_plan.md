# 订单履约主策略匹配方法命名收敛实施计划

## 目标

将顶层 `OrderFulfillmentStrategy` 的路由判断方法从 `supports(...)` 收敛为 `matches(...)`，与二级执行器层保持一致的“匹配 + 执行”表达。

## 实施项

1. 调整 `OrderFulfillmentStrategy` 接口方法签名为 `matches(OrderFulfillmentType fulfillmentType)`
2. 同步修改 `NoopOrderFulfillmentStrategy`、`VoucherOrderFulfillmentStrategy`
3. 修改 `OrderFulfillmentFacadeServiceImpl` 中的主策略路由调用
4. 清理顶层接口和门面实现中的历史乱码注释/日志
5. 编译验证 `plt-order-service`

## 验证点

- `OrderFulfillmentStrategy` 暴露 `matches(...)`
- `OrderFulfillmentFacadeServiceImpl` 通过 `item.matches(fulfillmentType)` 路由主策略
- 顶层策略不再暴露 `supports(...)`
- `mvn clean compile -DskipTests` 通过
