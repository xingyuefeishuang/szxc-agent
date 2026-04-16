# 订单履约执行器命名收敛实施计划

## 目标

在已统一 `VoucherFulfillmentExecutor` 接口语义的基础上，继续将发码二级实现类的命名从 `...Action` 全量收敛为 `...Executor`。

## 实施项

1. 将 `VoucherPaidAutoIssueAction` 重命名为 `VoucherPaidAutoIssueExecutor`
2. 将 `VoucherPaidDeferredIssueAction` 重命名为 `VoucherPaidDeferredIssueExecutor`
3. 将 `VoucherOnDemandIssueAction` 重命名为 `VoucherOnDemandIssueExecutor`
4. 清理实现类中的历史乱码注释和日志文案
5. 编译验证 `plt-order-service`

## 验证点

- 发码二级实现类不再存在 `Action` 命名
- 所有发码二级实现类统一实现 `VoucherFulfillmentExecutor`
- `mvn clean compile -DskipTests` 通过
