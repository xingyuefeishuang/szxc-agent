# plt-order-core 核心功能完善 — 实施计划 (v03)

## 背景

在 v02 路线图（审计+规划）基础上，本轮执行了 9 项待实现功能的编码实现。

## 变更范围

### 前置准备（新建文件）

| 操作 | 文件 | 说明 |
|------|------|------|
| [NEW] | `db/model/OrderStatusLog.java` | 订单状态变更日志 Entity |
| [NEW] | `db/mapper/OrderStatusLogMapper.java` | Mapper |
| [NEW] | `service/OrderStatusLogService.java` | 服务接口 |
| [NEW] | `service/impl/OrderStatusLogServiceImpl.java` | 服务实现 |
| [NEW] | `module/order/pojo/OrderItemBO.java` (plt-order-api) | 子订单展示对象 |
| [MODIFY] | `db/model/SpuRule.java` | 新增 `voucherValidityDays` 字段 |
| [MODIFY] | `module/order/pojo/OrderBO.java` (plt-order-api) | 新增 items + vouchers 列表 |

### 阶段 1：核心层完善

| 编号 | 文件 | 变更内容 |
|------|------|----------|
| 1.1 | `OrderServiceImpl.getOrderDetail` | 填充子订单列表 + 凭证列表到 BO |
| 1.2 | `OrderServiceImpl.pageQuery` | 多维条件分页查询 |
| 1.3 | `VoucherServiceImpl.verify` | 全部核销后自动推进 COMPLETED |
| 1.4 | `VoucherServiceImpl.issueVouchers` | 根据 SpuRule 计算凭证有效期 |
| 1.5 | `VoucherService` + `VoucherController` | 凭证延期接口 extendValidity |
| 1.6 | `RefundApplyServiceImpl` | 自动审批 + 部分退/全退判断 |

### 阶段 2：状态机增强

| 编号 | 文件 | 变更内容 |
|------|------|----------|
| 2.1 | `OrderStateMachine` | 每次状态流转持久化到 o_order_status_log |

### 阶段 3：抖音适配层

| 编号 | 文件 | 变更内容 |
|------|------|----------|
| 3.1 | `DouyinChannelAdapter.handleCanBuy` | SKU 映射校验 + 购买数量校验 |

## 延期项

- 库存扣减/释放（等待库存域对接）
- 商品映射真实对接
- 价格试算
- 抖音 OpenAPI 回写（SDK 可用后）
- DDL: `o_order_status_log` 表（需手动执行建表）
- DDL: `o_spu_rule` 新增 `voucher_validity_days` 列

## 验证

- Maven 编译通过（plt-order-api + plt-order-core）
