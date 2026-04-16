# 景区退款结果通知

**更新时间**: 2025-08-19 15:24:34

## 接口说明

*   POST 请求
*   抖音侧异步发起退款状态/取消结果通知，通知 SaaS 服务商退款完成信息，服务商接收消息后返回结果。

## 基本信息

| 项目 | 描述 |
| :--- | :--- |
| **Scope** | `life.capacity.trip_order_after_sale_refund_notify` |
| **权限要求** | 景区行业解决方案 - 景区退款结果通知 |
| **回调场景** | 抖音侧通知第三方景区退款结果 |

## 请求参数

| 参数名称 | 参数类型 | 是否必填 | 是否加密 | 参数描述 |
| :--- | :--- | :--- | :--- | :--- |
| `order_id` | string | 是 | 否 | 抖音侧订单 ID |
| `out_order_id` | string | 否 | 否 | 第三方订单 ID |
| `biz_uniq_key` | string | 是 | 否 | 业务唯一键，用于审核回调 |
| `refund_amount` | int64 | 是 | 否 | 实际退款金额，分 |
| `refund_time_unix` | int64 | 是 | 否 | 退款时间戳，秒 |
| `refund_scene` | int64 | 否 | 否 | 退款场景客服退 50（其他不用关心） |
| `refund_count` | int64 | 否 | 否 | 退款份数 |
| `vouchers` | list | 否 | 否 | 退款订单对应的凭证列表 |
| `vouchers[].projects` | list | 否 | 否 | 可自定义的项目（例：景区项目索道 A、索道 B 等） |
| `vouchers[].projects[].project_id` | string | 是 | 否 | 项目唯一标识 |

## 响应参数

| 参数名称 | 参数类型 | 是否必填 | 参数描述 |
| :--- | :--- | :--- | :--- |
| `data` | struct | 是 | - |
| `data.error_code` | int64 | 是 | 失败错误码 |
| `data.description` | string | 是 | 失败原因 |