# plt-order-core 核心功能完善 — 工作总结 (v03)

## 完成内容

本轮共实现 9 项核心功能，涵盖前置准备、核心服务层、状态机增强和抖音适配层。

### 新建文件（4个）

1. **OrderStatusLog Entity/Mapper/Service/ServiceImpl** — 订单状态变更日志全套，继承 `TenantSuperModel` + `SuperMapper` + `IBaseService` + `BaseServiceImpl`

2. **OrderItemBO** — 子订单展示对象（放置在 plt-order-api 模块）

### 修改文件（8个）

1. **SpuRule** — 新增 `voucherValidityDays` 字段（效期类型=指定天数时使用）

2. **OrderBO** — 新增 `items`（List<OrderItemBO>）和 `vouchers`（List<VoucherBO>）字段

3. **OrderServiceImpl**
   - `getOrderDetail`: 查询子订单列表 + 凭证列表，填充到 OrderBO
   - `pageQuery`: 多维条件分页（orderNo/channelCode/status/userId 等）

4. **VoucherServiceImpl**
   - `issueVouchers`: 根据 SpuRule.voucherValidityType 计算有效期（当日/N天/默认30天）
   - `verify`: 全部凭证核销后自动触发 OrderStateMachine → COMPLETED
   - 新增 `extendValidity` 延期方法
   - 新增 `calculateEndTime` 内部方法

5. **VoucherService** — 新增 `extendValidity` 接口方法

6. **VoucherController** — `/delay` 端点实现凭证延期

7. **RefundApplyServiceImpl**
   - 新增 `shouldAutoApproveRefund`: 读取 SpuRule.needRefundAudit，0=自动审批
   - 新增 `isAllItemsRefunded`: 检查订单下所有凭证是否全部 INVALID → 全退=REFUNDED，部分退=保持当前状态
   - 退款申请流程中自动触发审批

8. **OrderStateMachine** — 注入 `OrderStatusLogService`，每次状态流转后调用 `log()` 持久化

9. **DouyinChannelAdapter.handleCanBuy** — SKU 映射校验 + 购买数量校验 + 兜底放行机制

## 编译验证

- plt-order-api: `mvn clean install -DskipTests` ✅
- plt-order-core: `mvn clean compile -DskipTests -o` ✅

## 已知遗留

| 项目 | 状态 |
|------|------|
| DDL: `o_order_status_log` 建表 | 🔲 需手动执行 |
| DDL: `o_spu_rule` 新增 `voucher_validity_days` 列 | 🔲 需手动执行 |
| 库存扣减/释放 | 🔲 等待库存域 |
| 抖音 OpenAPI 真实回写 | 🔲 等待 SDK 可用 |
| 分布式锁（订单创建） | 🔲 等待 Redis 基础设施 |
| MQ 延时消息（超时取消） | 🔲 等待 MQ 基础设施 |
