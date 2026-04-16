# 景区团购预下单接口 V2 SPI

**更新时间**: 2025-12-26 14:53:39  
**接口场景**: 抖音侧通知第三方创建景区订单（景区团购期票 V2 版本）

---

## 1. 接口说明

本接口用于抖音侧在用户支付前，通知服务商/商家创建景区订单。

### 核心逻辑与注意事项
1.  **触发时机**: 默认配置为 **抖音侧支付前** 通知第三方创单。
    *   此阶段**不**额外通知支付成功，支付成功由后续流程保障。
2.  **超时处理机制**:
    *   抖音请求第三方超时时间默认为 **5000ms**。
    *   **重要**: 若超时，抖音侧默认视为 **创单成功**，将继续走后续支付链路并进行发码操作。
    *   **服务商义务**: 必须做好 **幂等处理**。需妥善处理 **发码请求可能先于创单请求到达** 的极端情况，确保数据一致性。
3.  **权限要求**: 需具备 `景区行业解决方案 - 景区团购能力 V2 版本` 权限。

### 基本信息

| 项目 | 描述 |
| :--- | :--- |
| **Action** | `scenic_spot.order.promissory_create_order` |
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
| `x-life-sign` | String | 是 | 请求签名（签名算法请参考开放平台签名文档） |

### 请求体 (Body)

| Key | 类型 | 必填 | 描述 |
| :--- | :--- | :--- | :--- |
| `biz_type` | Enum | 是 | 业务类型：`1`: 团购 (Groupon)`2`: 预售 (CalendarTicket)`3`: 期票预售券/团购在线预约 (GrouponOnline) |
| `create_order_time` | Int64 | 是 | 订单创建时间戳（秒） |
| `currency_code` | String | 是 | 货币类型，默认 `CNY` (人民币) |
| `open_id` | String | 是 | 登录账户抖音 UID |
| `order_id` | String | 是 | 抖音订单 ID |
| `original_amount` | Int64 | 是 | 订单原价，单位：**分** |
| `order_item_list` | List | 是 | 订单份数维度订单项列表。结构见下方 [订单项结构](#订单项结构)。 |
| `sku_info_list` | List | 是 | 商品信息字典列表。结构见下方 [商品信息结构](#商品信息结构)。 |
| `contact_list` | List | 否 | 联系人信息列表（**加密数据**）。结构见下方 [联系人/留资人结构](#联系人留资人结构)。 |
| `reserve_info_list` | List | 否 | 留资人信息列表。结构同 `contact_list`。 |
| `remark_info` | Struct | 否 | 订单备注信息。包含 `question_and_answer_list` (问答信息)。 |

#### 订单项结构 (`order_item_list` Item)

| Key | 类型 | 必填 | 描述 |
| :--- | :--- | :--- | :--- |
| `order_item_id` | String | 是 | 订单项 ID |
| `sku_id` | String | 是 | SKU ID（若是组合品，则为组合品主商品 SKU ID） |
| `package_id` | String | 否 | 组合 ID |
| `sub_sku_id` | String | 否 | 组合品子商品 ID |

#### 商品信息结构 (`sku_info_list` Item)

| Key | 类型 | 必填 | 描述 |
| :--- | :--- | :--- | :--- |
| `product_id` | String | 是 | 商品 ID |
| `sku_id` | String | 是 | 商品 SKU ID |
| `product_out_id` | String | 否 | 外部商品 ID |
| `sku_out_id` | String | 是 | **外部 SKU ID** (必传) |
| `sub_sku_info_list` | List | 否 | 子商品信息列表（递归结构，同本结构） |

#### 联系人/留资人结构 (`contact_list` / `reserve_info_list` Item)

> ⚠️ **注意**: `contact_list` 中的敏感字段（如手机号、证件号）通常为加密密文，需先解密使用。

| Key | 类型 | 必填 | 描述 |
| :--- | :--- | :--- | :--- |
| `name` | String | 否 | 姓名 |
| `en_name` | String | 否 | 英文名 |
| `first_name` | String | 否 | 英文名的名 |
| `last_name` | String | 否 | 英文名的姓 |
| `phone` | String | 否 | 联系电话 |
| `email` | String | 否 | 邮箱 |
| `credential_type` | Enum | 否 | 证件类型：`1`: 身份证`2`: 港澳通行证`3`: 台湾通行证`4`: 回乡证`5`: 台胞证`6`: 护照`7`: 外籍护照 |
| `credential_no` | String | 否 | 证件号 |
| `credential_validity` | String | 否 | 证件有效期 |
| `order_item_id` | String | 否 | 关联的订单项 ID |
| `sku_id` | String | 否 | 关联的 SKU ID |
| `package_id` | String | 否 | 组合 ID |

#### 备注信息结构 (`remark_info`)

| Key | 类型 | 描述 |
| :--- | :--- | :--- |
| `question_and_answer_list` | List | 用户下单时填写的问答信息。包含 `question` (问题) 和 `answers` (回答列表)。 |

---

## 3. 请求示例

### cURL 示例

```bash
curl --location --request POST 'https://your-domain.com/scenic_spot/order/promissory_create_order' \
--header 'Content-Type: application/json' \
--header 'X-Bytedance-Logid: 20251226145339ABC...' \
--header 'x-life-clientkey: clt.xxxxxxxxx' \
--header 'x-life-sign: signature_string_here' \
--data '{
    "biz_type": 1,
    "create_order_time": 1735199999,
    "currency_code": "CNY",
    "open_id": "ou_xxxxxxxxx",
    "order_id": "dy_order_123456789",
    "original_amount": 19900,
    "order_item_list": [
        {
            "order_item_id": "item_001",
            "sku_id": "sku_main_001",
            "package_id": "pkg_001",
            "sub_sku_id": "sub_sku_001"
        }
    ],
    "sku_info_list": [
        {
            "product_id": "prod_001",
            "sku_id": "sku_main_001",
            "sku_out_id": "ext_sku_001",
            "sub_sku_info_list": [
                {
                    "product_id": "prod_sub_001",
                    "sku_id": "sub_sku_001",
                    "sku_out_id": "ext_sub_sku_001"
                }
            ]
        }
    ],
    "contact_list": [
        {
            "name": "张三",
            "phone": "Enc.encrypted_phone_string",
            "credential_type": 1,
            "credential_no": "Enc.encrypted_id_card",
            "sku_id": "sku_main_001"
        }
    ],
    "reserve_info_list": [],
    "remark_info": {
        "question_and_answer_list": [
            {
                "question": "是否需要发票？",
                "answers": ["不需要"]
            }
        ]
    }
}'
```

### 业务场景示例 JSON

#### 场景 A: 普通团购（多 SKU）
```json
{
  "biz_type": 1,
  "original_amount": 19900,
  "currency_code": "CNY",
  "open_id": "douyin_user_openid_abcdef123456",
  "order_id": "dy_order_789123456001",
  "create_order_time": 1678886400,
  "order_item_list": [
    { "order_item_id": "item_001", "sku_id": "sku_A123" },
    { "order_item_id": "item_002", "sku_id": "sku_B456_sub1" }
  ],
  "sku_info_list": [
    { "sku_id": "sku_A123", "sku_out_id": "ext_sku_A123_main" },
    { "sku_id": "sku_B456", "sku_out_id": "ext_sku_B456_parent" }
  ],
  "reserve_info_list": [
    {
      "name": "成人 1",
      "phone": "13800138000",
      "credential_type": 1,
      "credential_no": "110101199001011234",
      "credential_validity": "2126-05-22",
      "sku_id": "sku_A123"
    }
  ]
}
```

#### 场景 B: 组合品团购
```json
{
  "biz_type": 1,
  "original_amount": 19900,
  "currency_code": "CNY",
  "open_id": "douyin_user_openid_abcdef123456",
  "order_id": "dy_order_789123456001",
  "create_order_time": 1678886400,
  "order_item_list": [
    {
      "order_item_id": "item_001",
      "sku_id": "sku_id_main",
      "sub_sku_id": "sub_sku_id_1",
      "package_id": "package_id_1"
    }
  ],
  "sku_info_list": [
    {
      "sku_id": "sku_id_main",
      "sku_out_id": "sku_out_id_main",
      "sub_sku_info_list": [
        {
          "product_id": "product_id_sub1",
          "sku_id": "sub_sku_id_1",
          "sku_out_id": "sku_out_id_sub_1"
        }
      ]
    }
  ],
  "reserve_info_list": [
    {
      "name": "成人 1",
      "phone": "13800138000",
      "credential_type": 1,
      "credential_no": "110101199001011234",
      "pacakage_id": "package_id_1" 
    }
  ]
}
```

---

## 4. 响应参数

| Key | 类型 | 必填 | 描述 |
| :--- | :--- | :--- | :--- |
| `data` | Struct | 是 | 响应数据主体 |
| └─ `error_code` | Int32 | 是 | **错误码**。`0` 表示成功，非 `0` 表示失败。 |
| └─ `order_id` | String | 是 | 抖音订单 ID（回传） |
| └─ `description` | String | 否 | 错误信息描述（当 `error_code` != 0 时提供） |
| └─ `ext_order_id` | String | 否 | 外部订单号（商家系统生成的订单号） |
| └─ `fail_sku_id_list` | List | 否 | 失败的 SKU ID 列表。因库存或价格原因创建失败时返回，成功则为空。 |

### 响应示例

#### 成功响应
```json
{
  "data": {
    "error_code": 0,
    "order_id": "dy_order_789123456001",
    "ext_order_id": "merchant_order_998877",
    "description": "",
    "fail_sku_id_list": []
  }
}
```

#### 失败响应 (部分 SKU 失败)
```json
{
  "data": {
    "error_code": 1,
    "order_id": "dy_order_789123456001",
    "description": "库存不足",
    "ext_order_id": "merchant_order_998877",
    "fail_sku_id_list": ["sku_B456_sub1"]
  }
}
```

---

## 5. 错误码列表

| 错误码 | 错误码描述 | 备注/建议 |
| :---: | :--- | :--- |
| `0` | 成功 | - |
| `1` | 库存不足 | 检查库存并返回具体失败 SKU |
| `2` | 商品已下架 | - |
| `3` | 当前出行人已购票 | 限购规则校验 |
| `4` | 当前出行日期已购票 | 限购规则校验 |
| `5` | 年龄不符合 | 仅限指定年龄用户购买 |
| `6` | 性别不符合 | 仅限指定性别用户购买 |
| `7` | 已持有该门票或超出购买限制 | - |
| `10` | 用户地区不符合 | 仅限特定地区用户购买 |
| `13` | 缺少证件信息 | - |
| `15` | 出行人数和份数不匹配 | - |
| `19` | 手机号格式问题 | - |
| `20` | 证件号格式问题 | - |
| `21` | 姓名格式问题 | - |
| `22` | 商家账户余额不足 | 仅服务商场景 |
| `23` | 价格不一致 | 请求价格与当前售价不符 |
| `100` | 商家系统内部异常 | **抖音侧会重试**，请确保幂等 |
| `999999` | 其他错误 | 商家自定义错误 |

> **提示**: 对于错误码 `100` (系统内部异常)，抖音侧会进行重试调用，请务必保证接口的**幂等性**，避免重复创单。