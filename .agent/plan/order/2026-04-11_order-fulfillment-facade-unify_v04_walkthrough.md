# 订单履约触发阶段命名收敛工作总结

## 完成内容

- 履约触发维度已统一为 `OrderFulfillmentTriggerStage`
- 非支付即时触发场景已统一收敛为 `ON_DEMAND`
- 发码二级子策略已从 `VoucherChannelIssueAction` 重命名为 `VoucherOnDemandIssueAction`
- 发码主策略中的路由日志和异常文案已改为 `triggerStage` 语义
- 按需发码子策略中的异常码和日志文案已去掉渠道特定表述

## 结果

- `scene` / `channel issue` 这类容易绑定来源方的命名被收掉，模型更贴近“履约触发阶段”
- 现有 `ON_DEMAND` 可同时覆盖渠道触发、人工触发、实时触发等未来扩展，不需要在一级枚举里引入来源概念
- 两级策略结构保持不变：门面先按 `fulfillmentType` 选主策略，`VOUCHER` 主策略再按 `triggerStage` 选子策略

## 验证

- 执行：`mvn clean compile -DskipTests`
- 结果：`plt-order-service / plt-order-api / plt-order-core` 编译通过
- 执行：`powershell -ExecutionPolicy Bypass -File .agent/workflows/plan-archive/validate-plan-archive.ps1 -Mode strict`
- 结果：严格模式校验通过
- 备注：Maven 构建过程中仍存在本地仓库 tracking file 写入权限告警，但未影响本次编译成功
