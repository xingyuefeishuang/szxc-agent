# 订单规则拆表工作总结

## 本次改动

### 代码层

- 删除旧的 `SpuRule` 单表模型及其 Mapper/Service。
- 新增三套独立规则模型：
  - `VoucherRule` / `VoucherRuleService`
  - `RefundAuditRule` / `RefundAuditRuleService`
  - `FulfillmentRule` / `FulfillmentRuleService`
- 三张规则表统一改为 `scope_type + scope_id` 作用域模型，不再平铺 `prodId/appId/spuId/skuId`。
- 新增统一作用域解析器，查询顺序固定为 `SKU -> SPU -> APP -> PROD`。
- `VoucherServiceImpl` 改为只读取码券规则表中的效期配置。
- `RefundApplyServiceImpl` 改为只读取退款审核规则表中的审核配置。
- `OrderFulfillmentFacadeServiceImpl` 改为只读取履约规则表中的履约类型配置。

### 文档层

- `unified_order_schema.sql` 已将 `o_spu_rule` 拆成三张表的 DDL。
- `UNIFIED_ORDER_FULL_SPEC.md` 已同步拆表后的实体清单、状态说明和规则读取说明。
- `ORDER_FULFILLMENT_TYPE_RULE_2026-04-06.md` 已改为引用 `o_fulfillment_rule`。

## 验证结果

- 已尝试执行：
  - `mvn -pl plt-core-service/plt-order-service/plt-order-core -am -DskipTests compile`
- 第一次失败原因：
  - 默认 `JAVA_HOME` 指向 JDK 8，无法编译目标发行版 17。
- 第二次在显式切换到 `D:\05-Development\jdk-17` 后继续编译：
  - 构建在上游模块 `plt-framework-web-starter` 失败，未进入 `plt-order-core`。
  - 同时存在 Maven 本地仓库 `D:\05-Development Tools\apache-maven-repo` 写权限警告。

## 后续动作

1. 先在数据库执行拆表 DDL，并把旧 `o_spu_rule` 数据迁移到三张新表。
2. 修复或绕过当前上游模块 `plt-framework-web-starter` 的编译错误后，再做一次完整编译回归。
3. 若后续后台需要独立配置页，可直接围绕三张新表分别建 CRUD，而不再复用“大杂烩”规则表。
