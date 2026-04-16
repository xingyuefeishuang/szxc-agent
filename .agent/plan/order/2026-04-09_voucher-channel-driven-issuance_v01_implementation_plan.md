# 实施计划

## 目标

把抖音团购发券从“按订单数量内推”调整为“按 `certificate_info_list` 逐券驱动”，同时保留履约门面的统一流程职责。

## 实施项

1. 扩展 `VoucherService`
   - 保留 `issueVouchers(orderId)` 作为内部默认发券入口。
   - 新增按外部券明细发券入口，支持逐条指定 `orderItemId`、`subSkuId`、有效期等参数。

2. 调整 `VoucherServiceImpl`
   - 保留内部默认发券逻辑。
   - 新增逐券发券实现，一张券一行落库。
   - 默认把 `project_id` 回填为内部 `voucherId`。

3. 调整履约策略
   - `VOUCHER` 履约策略对抖音改为“渠道驱动发券”，支付后只推进统一履约流程，不直接内推发券。
   - 其他渠道仍沿用内部默认发券。

4. 调整抖音 B11
   - 使用 `certificate_info_list` 构造逐券发券指令。
   - 按 `sku_id/sub_sku_id` 映射内部 `OrderItem`。
   - 响应中的 `project_id` 改为内部 `voucherId`。

5. 兼容修正
   - 修正 `VoucherMapper.xml` 列清单，包含 `project_id`。

## 验证

- 编译 `plt-order-core`
- 验证抖音 B11 重复回调幂等
- 验证 `project_id = voucherId`
