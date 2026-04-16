# fulfillment-voucher-rename implementation_plan

## 背景

上一轮已经废弃旧 `o_voucher` 表并引入 `o_fulfillment_voucher`，但为了降低改动面保留了部分 `Voucher*` Java 类名。本轮继续收敛内部命名，使实际履约码相关类与新表语义一致。

## 实施步骤

1. 扫描订单域代码中 `Voucher` 类名、mapper、service、controller、BO/DO、发码命令、状态枚举和票型枚举引用。
2. 将实际履约码相关内部类统一改为 `FulfillmentVoucher*`：
   - Entity、Mapper、Mapper XML。
   - Service、ServiceImpl、Controller。
   - API/BO/DO。
   - 发码命令、状态枚举、票型枚举、码生成器。
   - 履约策略类。
3. 保留不应改名的概念：
   - `VoucherRule` / `o_voucher_rule`：仍表示码券规则配置表。
   - `DouyinIssueVoucherRequest`：第三方抖音协议 DTO 名称。
   - `voucherCode` / `voucher_id` 等字段：数据库与接口字段语义仍是“实际码券/票码”。
4. 修复批量命名中的误替换。
5. 使用 Maven skill 编译 `plt-order-core` 及依赖模块。

