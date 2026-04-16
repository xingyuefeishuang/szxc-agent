# 申请退款 SPI

> **更新时间**: 2026-01-05 17:36:04

## 接口说明

抖音侧请求第三方**申请退款**，允许同步返回审核结果。

*   **审核逻辑**:
    *   当退款审核结果为**接受** (`Accept`) 时：
        *   若传入的 `refund_fee_amount` (手续费) **小于等于** 平台计算的手续费，以**平台计算罚金**为准。
        *   若传入的手续费 **大于** 平台计算手续费，视为**拒绝**。
*   **免审场景**: 客服发起的退款为**免审退款**，**不会**通过此接口请求第三方，直接由抖音侧处理。
*   **补码场景**: 若 `apply_source` 为 `301` (发码失败)，必须返回补码凭证 (`vouchers`)，否则拒绝操作会失效。

## 基本信息

| 名称 | 描述 |
| :--- | :--- |
| **Action** | `scenic_spot.order.refund_apply` |
| **HTTP Method** | `POST` |
| **超时时间 (ms)** | - |
| **回调场景** | 景区申请退款 |
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
| `biz_uniq_key` | String (必填) | - | **业务唯一键**，用于审核回调（可作幂等键） |
| `apply_refund_time_unix` | Int64 (必填) | - | 申请退款时间戳（秒） |
| `apply_source` | Enum (必填) | - | **申请退款来源/类型** (详见下方枚举) |
| `refund_fee_amount` | Int64 (必填) | - | 抖音侧计算的退款手续费金额（单位：分） |
| `order_out_id` | String | - | 第三方订单 ID |
| `vouchers` | List | - | **凭证列表***(仅部分退款或特定场景下传递)* |

#### `apply_source` 枚举详解

| 值 | 常量名 | 描述 |
| :---: | :--- | :--- |
| `0` | `UNKNOWN` | 未知状态 |
| `101` | `USER` | 用户发起 |
| `102` | `MERCHANT` | 商户发起 |
| `103` | `CUSTOMER_SERVICE_STAFF` | 客服/运营操作 |
| `104` | `SYSTEM` | 系统发起 |
| `105` | `JUDGMENT` | 判责退款 |
| `201` | `PAY_TIMEOUT_CANCEL` | 支付超时取消 |
| `301` | `MERCHANT_CONFIRM_FAIL_REFUND` | **发码失败** (需返回补码凭证) |
| `302` | `EXPIRE_REFUND` | 券过期自动退 |
| `303` | `PAY_CALLBACK_BUT_CANCELED` | 支付回调时订单已取消 |
| `304` | `USER_FULFILMENT_REFUND` | 用户履约后退款 |
| `305` | `CUSTOMER_SERVICE_STAFF_FULFILMENT_REFUND` | 客服/运营履约后退款 |
| `306` | `MERCHANT_CONFIRM_REJECT_REFUND` | 商家拒单自动退款 |
| `307` | `MERCHANT_CONFIRM_TIMEOUT_REFUND` | 商家确认超时自动退款 |
| `308` | `MERCHANT_CONFIRM_CANCEL_REFUND` | 商家取消订单自动退款 |
| `309` | `MERCHANT_CONFIRM_CANCEL_REFUND_FULFILMEN` | 商家取消订单自动退款 (核销后) |
| `310` | `MERCHANT_FULFILMENT_REFUND` | 商户核销后退款 |
| `311` | `DELIVER_CANCEL_REFUND` | 外卖运单取消导致退款 |
| `312` | `MERCHANT_CLOSE_AUTO_REFUND` | 商家关店后自动退款 |
| `314` | `USER_MERCHANT_CONSENSUS` | **客商协商一致** |
| `318` | `USER_ACTIVE_CONSENSUS_REFUND` | 用户主动协商退 |
| `401` | `REFUND_TIMEOUT_ARBITRATE` | 仲裁特有 |
| `999` | `DATA_FIX` | RD 手动修数据 |

#### `vouchers` 列表项结构 (请求)

仅在部分退款时传递，包含入园项目和自定义项目信息。

| Key | 字段类型 | 描述 |
| :--- | :--- | :--- |
| `entrance` | Struct | **景区的入园项目**(若入园凭证是单独凭证，用此字段；否则可用 `projects` 传入) |
| `projects` | List | **可自定义的项目** (例：索道 A、索道 B) |

*   **`entrance` / `projects` 子项字段**:
    *   `project_id`: 项目唯一标识。
    *   `certificate_nos`: 券号列表。
    *   `credentials`: 证件列表 (含 `credential_no`, `credential_type`)。
    *   `qrcodes`: 二维码列表。
    *   `urls`: URL 列表。
    *   `id_cards`: 身份证列表。
    *   `gmcode_imgs`: 图片列表。
    *   `name`: 项目名称。
    *   `status`: 凭证状态。

### 请求示例

```bash
curl --location --request POST '示例地址' \
--header 'content-type: application/json' \
--header 'access-token: 0801121846735352506a356a6 ' \
--data '{
    "apply_refund_time_unix": 3784647765072564145,
    "apply_source": 1,
    "biz_uniq_key": "mCJcTjPK6M",
    "order_id": "HpbdGWkNrW",
    "order_out_id": "ca4dhbuMbY",
    "refund_fee_amount": 3228334274875033289,
    "vouchers": [
        {
            "entrance": {
                "project_id": "Q4u6BtpUeY",
                "certificate_nos": ["8Cv5NoA5lP"],
                "credentials": [{"credential_no": "ZvjrsSupiI", "credential_type": 1}],
                "qrcodes": ["urUrpYOefA"],
                "urls": ["pHfBgGVHWB"]
            },
            "projects": [
                {
                    "project_id": "U0vKxjz5Yx",
                    "name": "y3qppXburL",
                    "certificate_nos": ["mUOJ8SEhY2"],
                    "credentials": [{"credential_no": "mRxycmVhUH", "credential_type": 1}]
                }
            ]
        }
    ]
}'
```
*(注：示例中省略了部分非核心字段以保持简洁，实际调用请参照完整参数定义)*

---

## 响应参数

### 响应体 (Body)

| Key | 字段类型 | 示例 | 描述 |
| :--- | :--- | :--- | :--- |
| `data` | Struct | - | 响应数据体 |
| `error_code` | Int32 (必填) | - | **错误码**`0`: 成功 (若有明确审核结果必须传 0)`100`: 需要重试其他: 抖音不重试 |
| `description` | String | - | 错误信息 |
| `audit_refund_result` | Enum | - | **审核退款结果***(处理成功时必须返回)*`1`: 接受 (`Accept`)`2`: 拒绝 (`Reject`)`3`: 等待审核 (`Waiting`) |
| `refund_fee_amount` | Int64 | - | **退款手续费金额** (单位：分)*(审核结果为“接受”时必须返回)* |
| `vouchers` | List | - | **凭证列表***(补码场景需要，如发码失败退款)* |

#### `audit_refund_result` 枚举

| 值 | 常量名 | 描述 |
| :---: | :--- | :--- |
| `1` | `Accept` | 接受退款 |
| `2` | `Reject` | 拒绝退款 |
| `3` | `Waiting` | 等待审核 (异步处理) |

#### `vouchers` 列表项结构 (响应 - 补码用)

若因发码失败导致退款且需要补码，需返回此字段。结构与请求类似，但增加了 `status` 等详细状态。

| Key | 字段类型 | 描述 |
| :--- | :--- | :--- |
| `entrance` | Struct | 入园项目凭证详情 |
| `projects` | List | 自定义项目凭证详情 |

*   **凭证详情字段 (`entrance` / `projects` 子项)**:
    *   `certificate_nos`: 券号凭证 (List, 最多 100 个)
    *   `credentials`: 证件列表
        *   `credential_no`: 凭证号
        *   `credential_type`: 证件类型 (`1`:身份证, `2`:港澳通, `3`:台湾通, `4`:回乡证, `5`:台胞证, `6`:护照, `7`:外籍护照, `8`:永居证)
    *   `qrcodes`: 二维码凭证 (List, 单条长度<=512)
    *   `urls`: URL 电子凭证 (List)
    *   `id_cards`: 身份证号码 (List)
    *   `gmcode_imgs`: 图片码
    *   `project_id`: 项目唯一标识
    *   `name`: 项目名称
    *   `status`: **凭证状态**
        *   `0`: 未使用 (`UnUsed`)
        *   `1`: 已使用 (`Used`)
        *   `2`: 已退票
        *   `3`: 已废弃 (门票未消费但凭证作废)

### 响应示例

```json
{
  "data": {
    "audit_refund_result": 1,
    "description": "TxuKiThu53",
    "error_code": 0,
    "refund_fee_amount": 3876598302908732000,
    "vouchers": [
      {
        "entrance": {
          "project_id": "3uSM0qPJ91",
          "name": "RkKF7T3hSx",
          "certificate_nos": ["P3XepS3LhV"],
          "credentials": [
            {
              "credential_no": "acPJC7vWyD",
              "credential_type": 1
            }
          ],
          "qrcodes": ["qntwaLg7lA"],
          "urls": ["2Vwyu92kaC"],
          "status": 1
        },
        "projects": [
          {
            "project_id": "B01t76XVHj",
            "name": "YYnWyMzfCE",
            "certificate_nos": ["PSq6ka0qxm"],
            "credentials": [
              {
                "credential_no": "cRJuJuHEiH",
                "credential_type": 1
              }
            ],
            "qrcodes": ["FgBmahHbPU"],
            "status": 1
          }
        ]
      }
    ]
  }
}
```

---

## 错误码

| 错误码 | 错误码描述 | 备注 |
| :---: | :--- | :--- |
| `0` | 成功 | **成功**。只要有明确的审核结果（接受/拒绝），必须返回 0。 |
| `100` | 重试 | **抖音侧需要重试**。若系统异常无法立即处理，返回此码。 |
| 其他 | - | 其他错误码抖音**不会**重试，通常视为最终失败。 |

> **注意**:
> 1. 若返回 `audit_refund_result`，则 `error_code` **必须** 为 `0`。
> 2. 若需要抖音稍后重试（例如系统繁忙），请返回 `error_code: 100`，此时不应包含 `audit_refund_result`。