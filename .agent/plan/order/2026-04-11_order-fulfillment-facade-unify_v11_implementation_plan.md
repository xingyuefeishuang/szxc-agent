# 订单履约与状态语义重构实施计划 v11

## 背景

在前序履约门面统一改造基础上，订单状态语义仍然沿用了 `DELIVERING` 的旧定义，无法同时支撑券类履约、实体发货和后续其他交付方式。当前需要把支付后的状态段重构为统一的履约语义，并让券类立即履约链路与退款链路对齐新状态机。

## 目标

1. 将订单状态统一收敛为：
   - `PAID`
   - `FULFILLING`
   - `FULFILLED`
   - `COMPLETED`
2. 券类立即履约走 `PAID -> FULFILLING -> FULFILLED`。
3. 全部核销完成后再推进到 `COMPLETED`。
4. 退款申请/回调支持从 `PAID / FULFILLING / FULFILLED` 进入退款，并在驳回时恢复原状态。
5. 支付红线、渠道红线和状态机判断同步切换到新状态语义。

## 计划改动

### 1. 状态枚举与状态机

- 修改 `OrderStatusEnum`
  - 移除 `DELIVERING`
  - 将 `DELIVERED` 语义收敛为 `FULFILLED`
  - 引入 `FULFILLING`
- 重建 `OrderStateMachine` 合法流转：
  - `PENDING -> PAID / CANCELED`
  - `PAID -> FULFILLING / REFUNDING`
  - `FULFILLING -> FULFILLED / REFUNDING`
  - `FULFILLED -> COMPLETED / REFUNDING`
  - `REFUNDING -> REFUNDED / PAID / FULFILLING / FULFILLED`

### 2. 券类立即履约

- 调整 `DefaultVoucherIssueExecutor`
  - 首次发码仅允许从 `PAID` 进入
  - 发码成功后先推 `FULFILLING`
  - 再推 `FULFILLED`
  - 返回结果状态为 `FULFILLED`

### 3. 退款链路

- 修改 `RefundApplyServiceImpl`
  - 退款回调允许 `PAID / FULFILLING / FULFILLED` 进入退款
  - 驳回时按 `originalOrderStatus` 恢复 `PAID / FULFILLING / FULFILLED`

### 4. 支付与渠道红线

- 修改 `OrderServiceImpl.hasCrossedPaidRedLine(...)`
- 修改 `DouyinChannelAdapter.hasCrossedPaidRedLine(...)`
- 红线状态统一覆盖：
  - `PAID`
  - `FULFILLING`
  - `FULFILLED`
  - `COMPLETED`
  - `REFUNDING`
  - `REFUNDED`

### 5. 发码服务备注增强

- 为 `FulfillmentVoucherServiceImpl.issueVouchers(OrderFulfillmentCmd cmd)` 增加最小备注
  - 默认整单发码
  - 明细级发码
  - 先复用已有码，再补发缺失券

## 验证计划

1. 全仓搜索确认无 `DELIVERING / DELIVERED` 代码残留。
2. 编译 `plt-core-service/plt-order-service`：
   - `mvn clean compile -DskipTests`
3. 校验 `.agent/plan` 命名规范：
   - `powershell -ExecutionPolicy Bypass -File .agent/workflows/plan-archive/validate-plan-archive.ps1 -Mode strict`
