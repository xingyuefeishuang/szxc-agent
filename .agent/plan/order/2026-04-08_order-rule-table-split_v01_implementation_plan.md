# 订单规则拆表实施计划

## 背景

现有 `o_spu_rule` 同时承载码券效期、退款审核、履约类型三类规则，配置语义混杂，且 `VoucherServiceImpl`、`RefundApplyServiceImpl`、`OrderFulfillmentFacadeServiceImpl` 分别只消费其中一部分字段，继续复用单表会放大理解和维护成本。

## 实施目标

1. 将商品规则按职责拆为独立配置表：
   - `o_voucher_rule`
   - `o_refund_audit_rule`
   - `o_fulfillment_rule`
2. 将规则绑定维度统一抽象为 `scope_type + scope_id`，不再在规则表中直接平铺 `prodId/appId/spuId/skuId`。
3. 将订单域内部代码从 `SpuRule` 迁移到独立规则实体/服务。
4. 同步更新订单设计 SQL 与设计文档，避免文档继续指向旧单表模型。

## 实施步骤

1. 新增三个规则实体、Mapper、Mapper XML、Service、ServiceImpl。
2. 为规则查询增加统一作用域解析器，按 `SKU -> SPU -> APP -> PROD` 顺序回退匹配。
3. 删除旧的 `SpuRule` 相关实体与服务实现，避免新旧模型并存。
4. 修改 `VoucherServiceImpl`，改为读取 `VoucherRule`。
5. 修改 `RefundApplyServiceImpl`，改为读取 `RefundAuditRule`。
6. 修改 `OrderFulfillmentFacadeServiceImpl`，改为读取 `FulfillmentRule`。
7. 更新 `.agent/designs/order/unified_order_schema.sql` 与相关设计文档中的表名、字段和作用域说明。
8. 尝试编译 `plt-order-core` 进行回归验证，并记录环境阻塞项。

## 风险与注意事项

- 本次代码已切换到新表名，数据库必须同步执行 DDL 拆表和数据迁移，否则运行时查不到规则。
- 当前默认采用 `SKU -> SPU -> APP -> PROD` 的细粒度优先回退口径。
- 编译验证依赖本地 JDK 17 与可写 Maven 本地仓库；若环境不满足，只能完成静态改造和局部核查。
