# 景区订单状态查询 SPI

> **更新时间**: 2025-12-26 17:09:59

## 接口说明

抖音在某些场景下需要主动查询商家/第三方的日历票订单核销状态。对接方返回查询订单的核销状态，进而做下一步订单流转处理。

## 基本信息

| 名称 | 描述 |
| :--- | :--- |
| **Action** | `scenic_spot.order.query_order` |
| **HTTP Method** | `POST` |
| **超时时间 (ms)** | `8000` |
| **回调场景** | 酒旅 - 景区订单状态查询 |
| **权限要求** | 景区日历票解决方案 - 景区订单状态查询 |

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
| `out_order_id` | String | - | 第三方订单 ID |

### 请求示例

```bash
curl --location --request POST '示例地址' \
--header 'content-type: application/json' \
--header 'access-token: 0801121846735352506a356a6 ' \
--data '{
    "order_id": "T28gvg0TTL",
    "out_order_id": "yKF97UQ3hf"
}'
```

---

## 响应参数

### 响应体 (Body)

| Key | 字段类型 | 示例 | 描述 |
| :--- | :--- | :--- | :--- |
| `data` | Struct (必填) | - | 响应数据体 |
| `description` | String (必填) | - | 错误信息 |
| `error_code` | Int32 (必填) | - | 错误码 |
| `order_out_id` | String (必填) | - | 第三方订单 ID |
| `total_voucher_quantity` | Int32 (必填) | - | 第三方凭证总数量 |
| `used_voucher_quantity` | Int32 (必填) | - | 第三方凭证已使用数量。*(如果返回结果带 `vouchers`，则该字段表示 `vouchers` 中状态为 1 的数量)* |
| `vouchers` | List | - | 凭证列表（部分退需要） |

#### `vouchers` 列表项结构

| Key | 字段类型 | 描述 |
| :--- | :--- | :--- |
| `entrance` | Struct (必填) | **入园项目凭证状态**景区的入园项目（若入园凭证是单独的凭证，则使用此字段用来传入园凭证。若不是单独的凭证，可使用自定义项目的字段传入） |
| `projects` | List (必填) | **自定义项目凭证状态列表**如景区项目索道 A、索道 B 等 |

##### `entrance` 对象字段

| Key | 字段类型 | 描述 |
| :--- | :--- | :--- |
| `project_id` | String (必填) | 入园项目的唯一标识，与 `projects` 中不能重复（核销时需要） |
| `status` | Int32 (必填) | **凭证状态**`0`: 未使用`1`: 已使用*(状态为 1 的票会被核销掉)* |

##### `projects` 列表项字段

| Key | 字段类型 | 描述 |
| :--- | :--- | :--- |
| `project_id` | String (必填) | 园内项目的唯一标识，与 `projects` 中不能重复（核销时需要） |
| `status` | Int32 (必填) | **凭证状态**`0`: 未使用`1`: 已使用*(状态为 1 的票会被核销掉)* |

### 响应示例

```json
{
  "data": {
    "description": "v0DCTK72gz",
    "error_code": 3341154437982403600,
    "order_out_id": "IPWphqHAdM",
    "total_voucher_quantity": 3165789238392558600,
    "used_voucher_quantity": 4361351152460634000,
    "vouchers": [
      {
        "entrance": {
          "project_id": "T3IGXZRmAD",
          "status": 333919389293489340
        },
        "projects": [
          {
            "project_id": "orrs9Av7Ap",
            "status": 2012597078181142500
          }
        ]
      }
    ]
  }
}
```

> *注：上述响应示例中的数值仅为格式演示，实际业务中 `status` 应为 0 或 1，`error_code` 应为定义的错误码。*

---

## 错误码

| 错误码 | 错误码描述 | 备注 |
| :---: | :--- | :--- |
| `0` | 成功 | 成功 |
| `1` | 其他异常 | 其他异常 |
| `2` | 三方没有该订单 | 三方没有该订单 |
| `100` | 抖音侧需要重试 | 抖音侧需要重试，其他错误码抖音不重试 |