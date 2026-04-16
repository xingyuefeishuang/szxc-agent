# 工作总结：退款后履约项状态分析

## 结论

退款后，履约项状态应该改。

更准确地说：

- 若履约项下全部未核销凭证都完成退款，应从已发放/待核销相关状态流转到 `REFUNDED`
- 若仅部分凭证退款，应流转到 `PARTIAL_REFUNDED`
- 若退款审核中，凭证至少应先冻结，防止继续核销

## 依据

### 需求文档

`[OTA_BUSINESS_REQUIREMENTS.md](D:/08-Work/01-博思/10-平台2.0/.agent/requirements/ota/OTA_BUSINESS_REQUIREMENTS.md)`

其中明确要求：

- 退款后对应凭证须立即失效，防止退款后核销
- 一单多票支持部分退款
- 订单状态机会流转到 `退款中 / 已退款 / 部分退款`

### 设计与枚举

设计和代码都已经定义了履约项退款状态：

- `FulfillmentStatusEnum.PARTIAL_REFUNDED`
- `FulfillmentStatusEnum.REFUNDED`

对应文件：

- `[FulfillmentStatusEnum.java](D:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/constant/FulfillmentStatusEnum.java)`

这说明领域模型本身已经认可“履约项状态需要体现退款结果”。

## 当前实现现状

当前代码里：

- 退款申请/退款回调会修改凭证状态：
  - `USABLE -> LOCKED`
  - `LOCKED -> INVALID`
- 会修改订单状态：
  - `REFUNDING`
  - `REFUNDED`

但没有看到任何退款后同步更新 `FulfillmentItem.fulfillmentStatus` 的实现。

已核对到的唯一赋值点是发券时直接设为：

- `FulfillmentStatusEnum.ISSUED`

对应文件：

- `[FulfillmentVoucherServiceImpl.java](D:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/impl/FulfillmentVoucherServiceImpl.java)`
- `[RefundApplyServiceImpl.java](D:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/impl/RefundApplyServiceImpl.java)`

## 判断

因此这件事分成两层：

- 业务上：要改
- 当前实现上：还没改到履约项状态，属于实现缺口

如果后续要补实现，建议以履约项维度统计其下凭证状态，再统一回写：

- 全部退款 -> `REFUNDED`
- 部分退款 -> `PARTIAL_REFUNDED`
- 全部核销 -> `VERIFIED`
- 部分核销 -> `PARTIAL_VERIFIED`
