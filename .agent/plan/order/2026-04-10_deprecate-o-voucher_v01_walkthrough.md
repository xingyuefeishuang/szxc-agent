# deprecate-o-voucher walkthrough

## 完成内容

新增迁移脚本：

- `.agent/designs/order/2026-04-10_deprecate-o-voucher-migration.sql`

脚本职责：

- `o_order_item` 增加 `channel_order_no`、`channel_item_id`、`channel_sub_sku_list`、`sku_type`。
- 创建 `o_fulfillment_item`，并加入 `uk_order_item_subsku(order_item_id, sub_sku_id)`，用于旧数据迁移和后续履约项复用。
- 创建 `o_fulfillment_voucher`，使用 `uk_channel_voucher_id(channel_code, channel_voucher_id)` 存渠道侧码 ID。
- 检测旧 `o_voucher` 是否存在；存在则迁移，迁移完成后 `DROP TABLE o_voucher`。

## 验证

已做文本校验：

- Java 运行时代码没有 `@TableName("o_voucher")`。
- Java 运行时代码没有旧 `voucher_status` 自定义 SQL。
- `unified_order_schema.sql` 不再包含 `CREATE TABLE o_voucher`。
- plan archive validator compatible 模式通过。

未直接执行迁移 SQL：当前环境没有连接目标 MySQL 实例。

## 注意

迁移脚本使用 `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`，适合 MySQL 8.x。若目标库版本不支持该语法，需要按脚本注释先查 `information_schema.columns` 后手动拆分执行 `ALTER TABLE ADD COLUMN`。

