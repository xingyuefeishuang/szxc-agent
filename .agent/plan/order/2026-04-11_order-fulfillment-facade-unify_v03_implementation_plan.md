# 订单履约两级策略拆分实施计划

## 目标

将履约路由改为两级：

1. 门面先按 `fulfillmentType` 选择主策略
2. 命中 `VOUCHER` 后，再在发码履约内部选择子策略

## 实施项

1. 调整 `OrderFulfillmentStrategy` 为主策略接口，仅按 `fulfillmentType` 匹配
2. 新增 `VoucherFulfillmentAction` 子策略接口
3. 将原有发码履约拆为：
   - 自有渠道支付后即时发券
   - OTA 支付后延迟发券
   - 渠道回调触发发券
4. 将 `OrderFulfillmentFacadeServiceImpl` 改回只按履约类型路由
5. 删除门面层对 `scene/channel` 的直接策略选择
6. 编译验证 `plt-order-service`

## 验证点

- 门面不再按 `scene/channel` 直接选择最终策略
- `VOUCHER` 主策略内部可根据场景继续二次分发
- 抖音发码链路保持可用
- `mvn clean compile -DskipTests` 通过

## 默认假设

- `NONE` 当前仍只有一个最小语义策略
- 未来 `DELIVERY` 等新履约类型，直接新增新的主策略即可
