# 订单履约触发阶段命名收敛实施计划

## 目标

在既有“两级履约策略”结构上，继续收敛触发维度命名：

1. 将 `OrderFulfillmentScene` 统一为 `OrderFulfillmentTriggerStage`
2. 将渠道语义的触发值统一为 `ON_DEMAND`
3. 清理子策略类名、异常码和日志文案中残留的 `ChannelIssue` 语义

## 实施项

1. 核对核心履约命令、结果对象、门面实现和抖音适配器中的触发阶段命名
2. 将发码二级子策略从 `VoucherChannelIssueAction` 收敛为更中性的 `VoucherOnDemandIssueAction`
3. 调整发码主策略中的日志和异常文案，统一使用 `triggerStage`
4. 全量检索旧命名残留，避免继续暴露渠道特定语义
5. 编译验证 `plt-order-service`
6. 运行 `.agent/plan` 严格命名校验

## 验证点

- 代码中不再存在 `OrderFulfillmentScene`
- 发码按需触发链路统一使用 `OrderFulfillmentTriggerStage.ON_DEMAND`
- `VoucherOnDemandIssueAction` 能正常被 Spring 扫描并参与二级策略路由
- `mvn clean compile -DskipTests` 通过
- `validate-plan-archive.ps1 -Mode strict` 通过
