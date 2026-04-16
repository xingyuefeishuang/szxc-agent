# 通知取消订单 SPI

> **更新时间**: 2025-12-30 16:09:18

## 接口说明

抖音侧通知第三方**取消订单**。
*   **适用范围**: 仅针对**未核销**的订单。
*   **触发场景**: 当用户在抖音侧发起退款或取消订单时，抖音会调用此接口通知服务商。
*   **错误处理原则**:
    *   通知类型的接口 **请勿返回业务类型的错误**（例如：订单不存在、状态不符等）。
    *   若遇到系统异常，应返回**系统类型的错误码**（如 `100`），以便抖音侧进行重试。

## 基本信息

| 名称 | 描述 |
| :--- | :--- |
| **Action** | `scenic_spot.order.cancel_notify` |
| **HTTP Method** | `POST` |
| **超时时间 (ms)** | - |
| **回调场景** | 酒旅 - 景区取消订单通知 |
| **权限要求** |  |

---

## 请求参数

### 请求头 (Headers)

| Key | 字段类型 | 示例 | 描述 |
| :--- | :--- | :--- | :--- |
| `Content-Type` | String (必填) | `application/json` | - |
| `X-Bytedance-Logid` | String (必填) | - | 请求 LogId，用于排查问题 |
| `x-life-clientkey` | String (必填) | - | 服务商应用的 `client_key` |
| `x-life-sign` | String (必填) | - | 请求签名 |

### 请求体 (Body)

| Key | 字段类型 | 示例 | 描述 |
| :--- | :--- | :--- | :--- |
| `order_id` | String (必填) | - | 抖音侧订单 ID |
| `cancel_order_time_unix` | Int64 (必填) | - | 取消订单的时间戳（秒） |
| `cancel_type` | Enum (必填) | - | **取消类型**：`1`: 抖音侧支付前取消 (`BeforePay`)`2`: 抖音侧支付后取消 (`AfterPay`)`3`: 第三方创单失败 (`External`) |
| `order_out_id` | String | - | 第三方订单 ID |

#### `cancel_type` 枚举详解

| 值 | 常量名 | 描述 |
| :---: | :--- | :--- |
| `1` | `BeforePay` | 抖音侧支付前取消 |
| `2` | `AfterPay` | 抖音侧支付后取消 |
| `3` | `External` | 第三方原因（如：创单失败） |

### 请求示例

```bash
curl --location --request POST '示例地址' \
--header 'content-type: application/json' \
--header 'access-token: 0801121846735352506a356a6 ' \
--data '{
    "cancel_order_time_unix": 8842253099680411503,
    "cancel_type": 1,
    "order_id": "cpQYtOMqdJ",
    "order_out_id": "8jrYZrKhmR"
}'
```

---

## 响应参数

### 响应体 (Body)

| Key | 字段类型 | 示例 | 描述 |
| :--- | :--- | :--- | :--- |
| `data` | Struct | - | 响应数据体 |
| `error_code` | Int32 (必填) | - | **错误码**合法范围 `[0, 999999]`。`0`: 表示成功。`100`: 表示需要重试（详见错误码章节）。 |
| `description` | String | - | 错误信息描述 |

### 响应示例

```json
{
  "data": {
    "description": "YWuprctA5Q",
    "error_code": 1664409354721523700
  }
}
```
> *注：示例中的 `error_code` 仅为格式演示，实际成功时应返回 `0`，需重试时返回 `100`。*

---

## 错误码

| 错误码 | 错误码描述 | 备注 |
| :---: | :--- | :--- |
| `0` | 成功 | 处理成功 |
| `100` | 抖音侧需要重试 | **重要**: 返回此码抖音侧会重试；返回其他非 0 错误码，抖音侧**不会**重试。 |