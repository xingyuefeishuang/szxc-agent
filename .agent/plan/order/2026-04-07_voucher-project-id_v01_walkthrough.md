# 工作总结：voucher-project-id

## 已完成

### 1. 凭证正式引入 `project_id`

- 在 `Voucher` / `VoucherBO` 中新增 `projectId`
- 在设计 SQL 的 `o_voucher` 中新增 `project_id varchar(128)`

### 2. B11 发码与凭证项目标识绑定

- 新增 `VoucherService.bindProjectIds(orderNo, projectIds)`
- 抖音 B11 发码完成后，将 `certificate_info_list[].certificate_id` 绑定到订单下凭证
- 当前占位规则：
  - 一个凭证对应一个项目
  - `project_id = certificate_id`

### 3. 统一查询/回写口径

- B11 响应 `project_id` 不再使用 `proj_n`
- 查询券信息时优先返回凭证已落库的 `project_id`
- 这样后续 B20/B22/B30 可以围绕同一占位字段继续演进

### 4. 编译校验通过

- `plt-order-service` 执行了增量编译
- `plt-order-api` 成功
- `plt-order-core` 成功
- `BUILD SUCCESS`

## 当前结论

- 在未接商品域/项目域的阶段，`project_id` 采用 `certificate_id` 作为占位是可行的。
- 这版已经比之前的 `proj_1/proj_2` 临时拼接稳定。
- 当前 B11 的主要剩余问题不再是 `project_id` 落库，而是：
  1. 是否支持异步发码 `result=0`
  2. 是否需要更细的项目/凭证分配模型

## 未做

- 未接真实项目域
- 未实现 B11 异步发码
- 未补真实数据库迁移执行

## 备注

- Maven 本地仓库仍有 metadata lock/权限警告，但这次未影响编译成功。
