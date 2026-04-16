# 通知支付结果 SPI

> **更新时间**: 2025-12-31 09:45:53

## 接口说明

抖音侧通知第三方支付成功。`ClientKey` 维度默认配置是：抖音侧支付成功后通知第三方创单，不额外通知支付成功。

**重要注意事项：**
*   通知类型的接口 **请勿返回业务类型的错误**（譬如订单不存在）。
*   应返回系统类型的错误，以便抖音侧进行重试。
*   如果抖音调用三方创建订单失败，则不会有支付通知。
*   如果创建订单和支付结果合并处理，则可以不对接该接口。

## 基本信息

| 名称 | 描述 |
| :--- | :--- |
| **Action** | `scenic_spot.order.pay_notify` |
| **HTTP Method** | `POST` |
| **超时时间 (ms)** | - |
| **回调场景** | 酒旅 - 景区支付结果 |
| **权限要求** | 景区日历票解决方案 - 景区支付通知 |

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
| `order_id` | String (必填) | - | 抖音订单 ID |
| `order_out_id` | String (必填) | - | 第三方订单 ID |
| `pay_time_unix` | Int64 (必填) | - | 支付时间戳（秒） |

### 请求示例

```bash
curl --location --request POST '示例地址' \
--header 'content-type: application/json' \
--header 'access-token: 0801121846735352506a356a6 ' \
--data '{
    "order_id": "ZNIBnQx5zd",
    "order_out_id": "Oz4eSeETIc",
    "pay_time_unix": 4348628689698269037
}'
```

---

## 响应参数

### 响应体 (Body)

| Key | 字段类型 | 示例 | 描述 |
| :--- | :--- | :--- | :--- |
| `data` | Struct (必填) | - | 响应数据体 |
| `description` | String (必填) | - | 错误信息 |
| `error_code` | Int32 (必填) | - | 错误码，合法范围为 `[0, 999999]`。`0` 表示成功；重试错误码（如 `100`）含义见文档「错误码」章节 |
| `confirm_info` | Struct | - | **确认接单信息***(支付后创单模式必须返回)* |

#### `confirm_info` 对象字段

| Key | 字段类型 | 枚举值/描述 |
| :--- | :--- | :--- |
| `confirm_mode` | Enum (必填) | **接单模式**`1`: 同步接单 (`Instant`) - 立即处理`2`: 异步接单 (`Async`) - 异步处理 |
| `confirm_result` | Enum | **接单结果***(同步接单时必填)*`1`: 接单 (`Accept`)`2`: 拒单 (`Reject`) |

> **注意**: 响应示例中可能包含其他字段（如 `fulfil_type`, `hotel_confirm_number` 等），具体请根据实际业务需求返回。

### 响应示例

```json
{
  "data": {
    "confirm_info": {
      "confirm_mode": 1,
      "confirm_result": 1,
      "fulfil_type": 1,
      "hotel_confirm_number": "XQwKHMtcb9"
    },
    "description": "PrxHCQA0Cy",
    "error_code": 2737856031569187000
  }
}
```

> *注：上述响应示例中的数值仅为格式演示，实际业务中 `error_code` 应为定义的错误码（0 或 100 等），`confirm_result` 应为 1 或 2。*

---

## 错误码

| 错误码 | 错误码描述 | 备注 |
| :---: | :--- | :--- |
| `0` | 成功 | 成功 |
| `100` | 抖音侧需要重试 | 抖音侧需要重试，其他错误码抖音不重试 |