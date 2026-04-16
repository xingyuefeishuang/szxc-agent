# Order Fulfillment Facade Unify v10 Implementation Plan

## Background

继续收敛订单履约模型，去掉 `triggerStage` 语义，改成：

- 顶层 `OrderFulfillmentStrategy` 表达 `delivery_type`
- `FulfillmentPolicy` 表达 `IMMEDIATE / DEFERRED`
- 券类交付统一由单一 `VoucherIssueExecutor` 负责发码

同时补齐抖音适配层和发码幂等链路，确保编译通过。

## Changes

1. 履约模型重构
   - 删除 `OrderFulfillmentTriggerStage`
   - 新增 `FulfillmentPolicy`
   - `OrderFulfillmentCmd` 改为持有 `fulfillmentPolicy` 与 `voucherItems`
   - `OrderFulfillmentResult` 改为回传 `fulfillmentPolicy`

2. 履约门面与策略分层
   - `OrderFulfillmentFacadeService` 增加 `fulfill(OrderFulfillmentCmd)`
   - `fulfillAfterPaid(Order, FulfillmentPolicy)` 显式由入口传 policy
   - `OrderFulfillmentFacadeServiceImpl` 只按 `OrderFulfillmentType` 选择主策略
   - `VoucherOrderFulfillmentStrategy` 内部只判断 `IMMEDIATE / DEFERRED`

3. 券类交付执行
   - 删除按场景拆开的多个券执行器
   - 新增 `VoucherIssueExecutor` / `DefaultVoucherIssueExecutor`
   - `IMMEDIATE` 必须发码并推进订单到 `DELIVERING`
   - `DEFERRED` 支付回调阶段不做交付动作
   - 显式发码请求统一复用 `VoucherIssueExecutor`

4. 发码幂等修正
   - `FulfillmentVoucherService.issueVouchers(OrderFulfillmentCmd)` 支持两种模式：
     - `voucherItems` 为空：按整单默认发码
     - `voucherItems` 非空：按明细匹配已发券并补齐剩余券
   - 去掉按整单已有任意券就直接短路返回的粗粒度逻辑

5. 抖音适配层对齐
   - B10 发码请求改为构建 `OrderFulfillmentCmd + voucherItems`
   - A21 发码请求改为直接调用统一券发码执行器
   - 修正 `DouyinCreateOrderRequest` 的 DTO 取值，使用真实字段：
     - B10 取 `skuInfoList`
     - A11 取顶层 `sku/product/count`

6. API DTO 修复
   - 修正部分 API POJO 在当前编译链下生成异常签名的问题
   - 对 `OrderBO / OrderItemBO / FulfillmentVoucherBO / RefundAddDO / RefundBO / VerifyResultVO` 的 `Date / BigDecimal / List` 使用显式限定名
   - 为 `OrderBO` 显式补充 `items / vouchers` getter/setter，确保核心模块可见

## Verification

- 执行：

```powershell
$env:JAVA_HOME = 'D:\05-Development\jdk-17'
mvn clean compile -DskipTests
```

- 工作目录：

```text
plt-core-service/plt-order-service
```

- 结果：编译通过
- 已知告警：本地 Maven 仓库 tracking file 写入权限告警仍存在，但未阻断本次编译
