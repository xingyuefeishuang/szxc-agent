# 订单履约二级匹配方法命名收敛实施计划

## 目标

将发码二级执行器的匹配方法从 `supports(...)` 收敛为 `matches(...)`，让该层接口形成“匹配 + 执行”的一致语义。

## 实施项

1. 调整 `VoucherFulfillmentExecutor` 接口方法签名为 `matches(...)`
2. 同步修改三个发码执行器实现
3. 修改 `VoucherOrderFulfillmentStrategy` 中的筛选调用
4. 清理二级接口和主策略中的历史乱码文案
5. 编译验证 `plt-order-service`

## 验证点

- `VoucherFulfillmentExecutor` 暴露 `matches(...)`
- `VoucherOrderFulfillmentStrategy` 通过 `item.matches(cmd, order)` 做二级路由
- 发码二级执行器不再暴露 `supports(...)`
- `mvn clean compile -DskipTests` 通过
