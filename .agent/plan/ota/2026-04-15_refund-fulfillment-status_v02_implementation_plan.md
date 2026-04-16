# 实施计划：补齐退款与核销后的履约项状态回写

## 任务信息

- 模块：`ota`
- 日期：`2026-04-15`
- featureKey：`refund-fulfillment-status`
- 类型：`implementation_plan`

## 目标

补齐 `plt-order-service` 中“凭证状态变化未同步到履约项状态”的实现缺口，确保：

- 核销后履约项状态可从凭证状态推导更新
- 退款冻结/解冻/作废后履约项状态可同步更新

## 实施方案

1. 以 `FulfillmentVoucherServiceImpl` 为唯一收敛点实现履约项状态回算方法。
2. 按履约项维度查询其下全部凭证，并根据凭证状态计算目标履约项状态：
   - 全部 `INVALID` -> `REFUNDED`
   - 部分 `INVALID` -> `PARTIAL_REFUNDED`
   - 全部 `VERIFIED` -> `VERIFIED`
   - 部分 `VERIFIED` -> `PARTIAL_VERIFIED`
   - 其他 -> `ISSUED`
3. 在以下凭证状态变化路径后触发回算：
   - 核销成功
   - 冻结
   - 解冻
   - 作废
4. 保持现有订单状态机与退款流程不变，不扩散改动到设计文档。

## 验证计划

1. 源码级核对调用链，确保核销/退款路径都能命中回算逻辑。
2. 尝试执行 Maven 编译做最小验证。
3. 若编译失败，明确区分：
   - 代码改动问题
   - 本地环境/JDK 问题
