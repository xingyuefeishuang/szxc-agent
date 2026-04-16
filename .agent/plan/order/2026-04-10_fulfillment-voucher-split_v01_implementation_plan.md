# fulfillment-voucher-split implementation_plan

## 背景

订单中心需要把原 `o_voucher` 拆为“订单项履约记录”和“实际码券记录”两层：

- `o_fulfillment_item`：描述某个订单项/子 SKU 粒度的应履约对象。
- `o_fulfillment_voucher`：描述实际生成的一张码券。

同时 `o_order_item` 需要保留渠道侧订单项信息，支持抖音按 `certificate_info_list` 逐个生成内部码，而不是按 `item * quantity` 固定生成。

## 实施步骤

1. 更新 schema 设计：
   - `o_order_item` 增加 `channel_order_no`、`channel_item_id`、`channel_sub_sku_list`、`sku_type`。
   - `o_fulfillment_item` 补齐 `spu_id` 并修正索引依赖字段。
   - `o_fulfillment_voucher` 增加 `order_no`、`spu_id`、`project_id`，修正 `order_id` 类型与 `uk_channel_voucher_id`。
   - 移除旧 `o_voucher` 建表，保留 drop 清理入口。
2. 新增履约项代码模型：
   - Entity、Mapper、Service、Mapper XML。
3. 迁移实际码券模型：
   - Java `Voucher` 保留类名和服务接口名，底层表切到 `o_fulfillment_voucher`。
   - 删除旧 `o_voucher` 相关自定义 mapper SQL。
4. 调整订单项链路：
   - 下单命令、订单项实体、BO、mapper XML 全链路补齐渠道订单项字段。
   - 抖音商品解析时记录渠道订单项、渠道组合子 SKU JSON、SKU 类型。
5. 调整发码链路：
   - 发码前先创建/复用 `o_fulfillment_item`。
   - 按三方传入的 `certificate_info_list` 明细生成内部码。
   - 记录渠道侧 `certificate_id` 到 `channel_voucher_id`。
6. 使用 Maven skill 编译 `plt-order-core` 及依赖模块。

