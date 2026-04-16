# 订单履约门面统一命令收敛工作总结

## 完成内容

- 新增统一履约模型：
  - `OrderFulfillmentCmd`
  - `OrderFulfillmentScene`
  - `OrderFulfillmentResult`
- 重构履约门面和策略接口，门面现在支持统一 `fulfill(cmd)` 入口
- 将券类履约拆成三类策略：
  - 自有渠道支付即发券
  - OTA 支付后延迟发券
  - 渠道回调触发发券
- 保留 `NONE` 履约策略，支付后不立即履约
- 抖音 `handleGroupbuyIssueVoucher` / `handleCalendarIssueVoucher` 已改为调用履约门面

## 关键结果

- 渠道层继续负责协议转换，核心层不直接依赖抖音 DTO
- 履约门面现在按 `履约类型 -> 场景/渠道` 路由，避免继续在单个策略里堆 `if channel == xxx`
- 支付回调链路与渠道发码链路被显式区分，后续扩展美团等渠道时可继续复用统一命令入口

## 验证

- 在 `plt-core-service\\plt-order-service` 下执行：
  - `mvn clean compile -DskipTests`
- 结果：
  - 编译通过
  - Maven 过程中仍存在本地仓库跟踪文件写入权限告警，但未阻断本次构建

## 后续建议

- 后续新增渠道优先新增 `scene` 或新增标准子载荷，不要把渠道 DTO 直接塞进门面
- 若 OTA 渠道出现“支付后不应立即进入 DELIVERING”的新规则，再补充更细的履约场景或配置维度
