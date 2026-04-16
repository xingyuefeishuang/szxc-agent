# deprecate-o-voucher implementation_plan

## 背景

上一轮已经把 Java 运行时表映射切换到 `o_fulfillment_item` 与 `o_fulfillment_voucher`。本轮继续完成旧表废弃：给现有数据库提供可执行迁移脚本，避免只改代码但线上仍保留 `o_voucher` 作为事实表。

## 实施步骤

1. 扫描订单域代码、schema 和设计文档中的 `o_voucher` 引用。
2. 确认运行时代码已不再映射 `o_voucher`，保留 `o_voucher_rule` 规则表不变。
3. 新增迁移 SQL：
   - 补齐 `o_order_item` 渠道快照字段。
   - 创建 `o_fulfillment_item`。
   - 创建 `o_fulfillment_voucher`。
   - 如果旧 `o_voucher` 存在，则按 `order_item_id + sub_sku_id` 聚合生成履约项。
   - 将旧码券逐条迁移到 `o_fulfillment_voucher`。
   - 迁移完成后 drop `o_voucher`。
4. 做关键文本校验，确认运行时代码无旧表引用。
5. 归档本次计划与总结。

