# 订单履约与状态语义重构实施总结 v11

## 实施结果

本轮在既有履约门面重构基础上，完成了订单支付后状态段的统一收敛：

- `DELIVERING` 已退出业务语义
- 新语义切换为 `FULFILLING` 与 `FULFILLED`
- 券类立即履约链路改为 `PAID -> FULFILLING -> FULFILLED`
- 全部核销完成后仍由核销链路推进到 `COMPLETED`

## 具体改动

### 1. 状态枚举与状态机

- 修改了 `plt-order-core` 的 `OrderStatusEnum`
- 修改了 `OrderStateMachine`
- 新状态流转覆盖：
  - `PAID -> FULFILLING`
  - `FULFILLING -> FULFILLED`
  - `FULFILLED -> COMPLETED`
  - 退款中可回退到原始履约状态

### 2. 券类立即履约

- 修改 `DefaultVoucherIssueExecutor`
- 执行器现在只接受 `PAID` 作为首次发码入口
- 发码成功后顺序推进：
  - `FULFILLING`
  - `FULFILLED`
- 返回的 `OrderFulfillmentResult.orderStatusAfter` 已改为 `FULFILLED`

### 3. 退款与恢复

- 修改 `RefundApplyServiceImpl`
- 退款回调支持从 `PAID / FULFILLING / FULFILLED` 转入退款
- 审核驳回恢复逻辑不再只恢复到 `PAID`，而是按 `originalOrderStatus` 精确恢复

### 4. 支付红线与渠道红线

- 修改 `OrderServiceImpl`
- 修改 `DouyinChannelAdapter`
- 已支付红线现在统一覆盖履约中、履约完成、完成和退款相关状态

### 5. 发码服务备注

- 在 `FulfillmentVoucherServiceImpl.issueVouchers(OrderFulfillmentCmd cmd)` 增加了最小注释
- 明确了两种模式：
  - 默认整单发码
  - 明细级按需发码
- 明确了幂等策略：
  - 先复用已有券
  - 再补发缺失券

## 验证结果

### 编译

已执行：

```powershell
$env:JAVA_HOME='D:\05-Development\jdk-17'; mvn clean compile -DskipTests
```

执行目录：

```text
plt-core-service/plt-order-service
```

结果：

- `plt-order-api` 编译通过
- `plt-order-core` 编译通过
- 整体 `BUILD SUCCESS`

### 额外说明

- Maven 构建过程中仍存在本地仓库 tracking file 写入权限告警
- 告警未阻断本次编译
- 全仓搜索未发现 `DELIVERING / DELIVERED` 代码残留
