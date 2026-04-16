# 景区团购发码 V2 SPI

**更新时间**: 2025-12-24 16:10:42  
**接口场景**: 景区团购三方码发券 SPI（抖音通知三方发码）

---

## 1. 接口说明

本接口用于抖音侧在用户支付成功后，通知服务商/商家进行**发码**操作。

### 核心逻辑与注意事项
1.  **发码模式**:
    *   **同步发码**: 接口直接返回第三方生成的凭证码（Code/URL/二维码）。
        *   **超时限制**: 同步请求必须在 **5000ms** 内返回。
        *   **退单机制**: 若同步发码在 **10分钟** 内无法获取有效凭证码，系统将自动触发**退单并退款**。
    *   **异步发码**: 接口仅返回“发码中”状态。
        *   后续需通过**发码通知回调**接口，根据凭证单映射关系异步推送具体的凭证码给抖音。
2.  **生效条件**:
    *   对接方需保证：只有当凭证信息**成功回调给抖音**后，该凭证才可用，用户方可入园使用。
3.  **重试机制**:
    *   若返回非成功错误码（未知错误或系统异常），抖音侧会进行重试。
    *   **重试策略**: 间隔 `10s` -> `30s` -> `60s` -> `120s` -> `120s` -> `240s`，最多重试 **6次**。
4.  **权限要求**: 需具备 `景区行业解决方案 - 景区团购能力 V2 版本` 权限。

### 基本信息

| 项目 | 描述 |
| :--- | :--- |
| **Action** | `scenic_spot.order.promissory_gen_code` |
| **HTTP Method** | `POST` |
| **超时时间** | 5000 ms |
| **Content-Type** | `application/json` |

---

## 2. 请求参数

### 请求头 (Headers)

| Key | 类型 | 必填 | 描述 |
| :--- | :--- | :--- | :--- |
| `Content-Type` | String | 是 | 固定值 `application/json` |
| `X-Bytedance-Logid` | String | 是 | 请求 LogId，用于排查问题 |
| `x-life-clientkey` | String | 是 | 服务商应用的 `client_key` |
| `x-life-sign` | String | 是 | 请求签名 |

### 请求体 (Body)

| Key | 类型 | 必填 | 描述 |
| :--- | :--- | :--- | :--- |
| `certificate_info_list` | List | 是 | 凭证信息列表（可能包含多个子项，如组合品）。结构见下方 [凭证信息结构](#凭证信息结构)。 |
| `open_id` | String | 是 | 用户对外 UID |
| `order_id` | String | 否 | 抖音订单 ID |
| `out_order_id` | String | 否 | 第三方侧的订单号 |

#### 凭证信息结构 (`certificate_info_list` Item)

| Key | 类型 | 必填 | 描述 |
| :--- | :--- | :--- | :--- |
| `certificate_id` | String | 是 | **抖音凭证 ID** (唯一标识) |
| `sku_id` | String | 是 | 商品 SKU ID |
| `start_time` | Int64 | 是 | 有效期开始时间戳 (**纳秒**) |
| `expire_time` | Int64 | 是 | 有效期截止时间戳 (**纳秒**) |
| `order_item_id` | String | 否 | 订单项 ID |
| `package_id` | String | 否 | 组合 ID (购买组合品时有值) |
| `sub_sku_id` | String | 否 | 组合品子商品 SKU ID (购买组合品时有值) |

---

## 3. 请求示例

```bash
curl --location --request POST 'https://your-domain.com/scenic_spot/order/promissory_gen_code' \
--header 'Content-Type: application/json' \
--header 'X-Bytedance-Logid: 20251224161042ABC...' \
--header 'x-life-clientkey: clt.xxxxxxxxx' \
--header 'x-life-sign: signature_string_here' \
--data '{
    "certificate_info_list": [
        {
            "certificate_id": "cert_123456789",
            "sku_id": "sku_scenic_001",
            "start_time": 1735689600000000000,
            "expire_time": 1735776000000000000,
            "order_item_id": "item_001",
            "package_id": "pkg_001",
            "sub_sku_id": "sub_sku_001"
        }
    ],
    "open_id": "ou_xxxxxxxxx",
    "order_id": "dy_order_123456789",
    "out_order_id": "merchant_order_998877"
}'
```

---

## 4. 响应参数

| Key | 类型 | 必填 | 描述 |
| :--- | :--- | :--- | :--- |
| `data` | Struct | 是 | 响应数据主体 |
| └─ `result` | Int32 | 是 | **发码结果状态**：`0`: 发码中 (异步处理)`1`: 发码成功 (同步返回码)`2`: 发码失败 |
| └─ `error_code` | Int32 | 否 | 错误码。`0` 表示成功，其他表示错误。若非 0 且为未知错误，将触发重试。 |
| └─ `description` | String | 否 | 错误信息描述 |
| └─ `order_id` | String | 否 | 抖音订单 ID |
| └─ `certificate_info` | List | 否 | **券码信息列表** (仅当 `result=1` 时返回)。结构见下方 [返回券码结构](#返回券码结构)。 |

#### 返回券码结构 (`certificate_info` Item)

| Key | 类型 | 必填 | 描述 |
| :--- | :--- | :--- | :--- |
| `certificate_id` | String | 是 | 抖音内部券 ID (需与请求中的 ID 对应) |
| `project_list` | List | 是 | 项目/景点列表 (一个凭证可能包含多个项目)。结构见下方 [项目结构](#项目结构)。 |

#### 项目结构 (`project_list` Item)

| Key | 类型 | 必填 | 描述 |
| :--- | :--- | :--- | :--- |
| `project_id` | String | 是 | 项目 ID |
| `name` | String | 是 | 项目名称 |
| `certificate` | List | 否 | 凭证码列表。**若仅凭证件入园，可传空数组 `[]`**。结构见下方 [凭证码结构](#凭证码结构)。 |
| `credential` | List | 否 | 证件信息列表 (若需要核验证件)。结构见下方 [证件结构](#证件结构)。 |

#### 凭证码结构 (`certificate` Item)

| Key | 类型 | 必填 | 描述 |
| :--- | :--- | :--- | :--- |
| `certificate_no` | String | 是 | **凭证号/码/URL**。长度限制：**64字符**以内。 |
| `certificate_type` | Int32 | 是 | 凭证类型：`1`: 二维码内容 (QR Code Content)`2`: URL 链接`3`: 纯代码 (Code) |

#### 证件结构 (`credential` Item)

| Key | 类型 | 必填 | 描述 |
| :--- | :--- | :--- | :--- |
| `credential_no` | String | 是 | 证件号 |
| `credential_type` | Int64 | 是 | 证件类型：`1`: 身份证`2`: 港澳通行证`3`: 台湾通行证`4`: 回乡证`5`: 台胞证`6`: 护照`7`: 外籍护照 |

---

## 5. 响应示例

### 场景 A: 同步发码成功 (Result = 1)

```json
{
  "data": {
    "result": 1,
    "error_code": 0,
    "description": "",
    "order_id": "dy_order_123456789",
    "certificate_info": [
      {
        "certificate_id": "cert_123456789",
        "project_list": [
          {
            "project_id": "proj_scenic_01",
            "name": "某某风景区大门票",
            "certificate": [
              {
                "certificate_no": "https://m.douyin.com/code/xyz123",
                "certificate_type": 2
              }
            ],
            "credential": [
              {
                "credential_no": "110101199001011234",
                "credential_type": 1
              }
            ]
          }
        ]
      }
    ]
  }
}
```

### 场景 B: 异步发码 (Result = 0)
*此时不返回 certificate_info，后续需通过回调接口推送码*

```json
{
  "data": {
    "result": 0,
    "error_code": 0,
    "description": "Processing asynchronously",
    "order_id": "dy_order_123456789"
  }
}
```

### 场景 C: 发码失败 (Result = 2)

```json
{
  "data": {
    "result": 2,
    "error_code": 999,
    "description": "库存不足或系统异常",
    "order_id": "dy_order_123456789"
  }
}
```

---

## 6. 错误码列表

| 错误码 | 错误码描述 | 备注/处理建议 |
| :---: | :--- | :--- |
| `0` | 成功 | - |
| `999` | 未知错误 | **会触发重试**。请检查系统日志，确保幂等性。 |
| *其他非0值* | 业务错误 | 根据 `description` 排查。若为确定性业务错误（如商品下架），建议直接返回失败，避免无效重试。 |

> **重要提示**:
> 1. 对于 `result=0` (发码中) 的情况，务必在业务处理完成后，主动调用抖音的**发码结果回调接口**告知最终结果。
> 2. 对于 `result=2` (发码失败) 或超时未响应，若导致订单取消，请确保本地订单状态同步更新。