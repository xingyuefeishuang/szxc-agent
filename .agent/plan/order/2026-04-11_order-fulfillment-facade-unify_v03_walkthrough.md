# 订单履约两级策略拆分工作总结

## 完成内容

- `OrderFulfillmentStrategy` 已收敛为主策略接口，只负责履约类型匹配
- 新增 `VoucherFulfillmentAction` 作为发码履约子策略接口
- `FulfillmentVoucherOrderFulfillmentStrategy` 已改为发码履约主策略，内部二次路由到：
  - `VoucherPaidAutoIssueAction`
  - `VoucherPaidDeferredIssueAction`
  - `VoucherChannelIssueAction`
- 删除了之前直接挂在门面层的：
  - `DeferredVoucherOrderFulfillmentStrategy`
  - `ChannelIssueVoucherOrderFulfillmentStrategy`
- `NoopOrderFulfillmentStrategy` 保留为 `NONE` 主策略

## 结果

- 门面职责更单一，只回答“这单属于哪种履约类型”
- 发码履约复杂度被收敛到 `VOUCHER` 域内
- 后续新增发货履约时，不会和发码场景判断混在一层

## 验证

- 执行：
  - `mvn clean compile -DskipTests`
- 结果：
  - `plt-order-service / plt-order-api / plt-order-core` 编译通过
  - Maven 本地仓库 tracking file 权限告警仍存在，但未影响构建成功
