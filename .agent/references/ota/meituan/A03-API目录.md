### 产品 API

**API 列表**

| API 接口名称 | 类型 | 描述 |
| :--- | :--- | :--- |
| 拉取价格日历 | `meituan.trip.product.price.get` | 美团->供应商<br>美团主动拉取价格日历 |
| 拉取多层价格日历 V2 | `meituan.trip.product.levelprice.get.v2` | 美团->供应商<br>美团主动拉取多层价格日历 |
| 多层价格日历变化通知 V2 | `meituan.trip.product.level.price.notice.v2` | 供应商->美团<br>多层价格日历变化通知 V2 |

---

### 交易 API

**API 列表**

| API 接口名称 | 类型 | 描述 |
| :--- | :--- | :--- |
| 订单关闭消息 | `meituan.trip.order.close` | 美团->供应商<br>美团给商家发送订单关闭消息 |
| 订单消费通知 | `meituan.trip.order.consume.notice` | 供应商->美团<br>合作方主动通知美团订单已消费接口 |
| 订单创建 | `meituan.trip.order.create` | 美团->供应商<br>美团请求合作方创建订单，对应合作方预约功能，但尚未支付 |
| 订单出票 | `meituan.trip.order.pay` | 美团->供应商<br>美团请求合作方出票 |
| 订单查询 | `meituan.trip.order.query` | 美团->供应商<br>美团主动查询合作方订单状况，包括订单状况与凭证码使用状况 |
| 订单退款 | `meituan.trip.order.refund` | 美团->供应商<br>美团向合作方发起退款请求，用于正常流程的用户退款，非客服强制退款 |
| 订单退款通知 | `meituan.trip.order.refund.notice` | 供应商->美团<br>商家完成商家侧退款审核后，使用该接口通知美团该退款完成 |
| 已退款消息 | `meituan.trip.order.refunded.info` | 美团->供应商<br>美团给商家发送已退款信息 |
| 订单出票通知 | `meituan.trip.order.pay.notice` | 供应商->美团<br>合作方主动通知美团订单出票情况 |
| 订单改签 | `meituan.trip.order.reschedule` | 美团->供应商<br>美团给商家发送订单改签请求 |
| 订单改签通知 | `meituan.trip.order.reschedule.notice` | 供应商->美团<br>商家给美团发送订单改签结果通知 |

---

### 辅助 API

**API 列表**

| API 接口名称 | 类型 | 描述 |
| :--- | :--- | :--- |
| 查询账户余额 | `meituan.trip.support.balance.query` | 美团->供应商<br>美团查询商家账户余额，对余额不足情况提前预警，避免账户资金问题导致用户下单失败 |

### 接口类型 ID

**更新时间：** 2026-03-09

| 描述 | 接口类型 ID (msgType) |
| :--- | :--- |
| 拉取价格日历 | 6610017 |
| 拉取多层价格日历 V2 | 6610021 |
| 订单关闭消息 | 6610023 |
| 订单创建 V2 | 6610025 |
| 订单出票 | 6610027 |
| 订单查询 | 6610029 |
| 订单退款 | 6610031 |
| 已退款消息 | 6610033 |
| 订单改签 | 6610035 |
| 查询账户余额 | 6610037 |


