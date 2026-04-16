# 实施计划：voucher-project-id

## 背景

- 抖音 B11/B20/B22/B30 链路需要稳定的 `project_id`。
- 当前未接商品域/项目域，无法提供真实项目主数据。
- 现阶段业务约定：一个凭证对应一个项目，占位规则采用 `project_id = certificate_id`。

## 本次实施目标

1. 在凭证模型中正式引入 `project_id` 字段。
2. B11 发码时将抖音 `certificate_id` 持久化到凭证 `project_id`。
3. 查询券信息时统一从凭证 `project_id` 回传，避免继续使用 `proj_n` 或 `voucherId` 临时占位。
4. 跑一轮 `plt-order-service` 编译，确认本次改动未打断订单模块。

## 具体改动

### 1. 模型与表结构

- `Voucher` 新增 `projectId`
- `VoucherBO` 新增 `projectId`
- 设计 SQL 中 `o_voucher` 新增 `project_id varchar(128)`

### 2. 凭证服务

- `VoucherService` 新增 `bindProjectIds(orderNo, projectIds)`
- `VoucherServiceImpl` 实现按订单号批量绑定项目标识
- 绑定策略：按凭证创建顺序与外部 `certificate_id` 一一对应

### 3. 抖音 B11 发码

- `handleGroupbuyIssueVoucher(...)`
  - 发码后绑定 `project_id`
  - 组装响应时优先使用凭证已落库的 `project_id`
- 查询券信息时统一回传凭证上的 `project_id`

## 边界与约束

- 当前 `project_id` 仍是阶段性占位，不是商品域真实项目主键。
- 当前约定仅适用于“一个凭证对应一个项目”的阶段性模型。
- 未实现 B11 异步发码 `result=0`。

## 验证

- 使用 Maven compile skill 对 `plt-order-service` 执行 `mvn compile -DskipTests`
- 验证 `plt-order-api` 与 `plt-order-core` 均编译通过
