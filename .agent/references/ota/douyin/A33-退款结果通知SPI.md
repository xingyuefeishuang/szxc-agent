# 通知退款结果 SPI

> **更新时间**: 2026-01-05 17:35:57  

## 接口说明

抖音侧在完成退款操作后，调用此接口**通知第三方实际退款结果**。

*   **触发时机**: 抖音侧资金退款完成后。
*   **错误处理原则**:
    *   此为**通知类型**接口。
    *   **请勿返回业务类型的错误**（例如：订单不存在、状态不符等）。即使本地订单状态异常，也应返回成功 (`0`)，以免抖音侧停止重试导致状态不一致。
    *   若遇到系统异常（如数据库宕机），应返回**系统错误码** (`100`)，以便抖音侧稍后重试。

## 基本信息

| 名称 | 描述 |
| :--- | :--- |
| **Action** | `scenic_spot.order.refund_notify` |
| **HTTP Method** | `POST` |
| **超时时间 (ms)** | - |
| **回调场景** | 酒旅 - 景区退款结果通知 |
| **权限要求** | 需开通以下任意一个解决方案的能力：• 景区团购解决方案 - 景区退款结果通知• 景区日历票解决方案 - 景区退款结果通知• 景区在线预约解决方案 - 景区退款结果通知 |

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
| `biz_uniq_key` | String (必填) | - | **业务唯一键**，用于审核回调及幂等控制 |
| `refund_amount` | Int64 (必填) | - | **实际退款金额** (单位：分) |
| `refund_time_unix` | Int64 (必填) | - | 退款完成的时间戳 (秒) |
| `refund_scene` | Enum (必填) | - | **退款场景** (详见下方枚举) |
| `order_out_id` | String | - | 第三方订单 ID |
| `refund_count` | Int64 | - | 退款份数 |
| `vouchers` | List | - | **退款凭证列表** (部分退款或特定场景下传递) |

#### `refund_scene` 枚举详解

| 值 | 常量名 | 描述 |
| :---: | :--- | :--- |
| `1` | `USER_APPLY` | 用户发起 |
| `2` | `USER_MERCHANT_CONSENSUS` | **客商协商一致***(注：订单核销后用户联系商家发起的仅退款不会通知；订单未核销的退货退款会通知)* |
| `3` | `USER_ACTIVE_CONSENSUS` | 用户主动协商 |
| `50` | `CUSTOMER_SERVICE_STAFF_APPLY` | 客服 & 平台发起 |
| `100` | `MERCHANT_APPLY` | 商家发起 |
| `101` | `CANCEL_ORDER` | 商家取消订单 (原外卖商家发起，通常无需关注) |
| `150` | `EXPIRE` | 系统 - 券过期退 |
| `151` | `CONFIRM_TIMEOUT` | 超时未接单 |
| `152` | `PAY_TIMEOUT_CALLBACK` | 超付退 |
| `153` | `REJECT_ORDER` | 拒单 |
| `154` | `CLOSE_SHOP` | 闭店 |
| `155` | `GENERATE_CODE_FAIL` | 发码失败 |
| `156` | `DELIVER_CANCEL` | 运单取消 |
| `158` | `GROUPON_UPGRADE_TIMES_CARD` | 团购升级次卡 |
| `159` | `OFFLINE_FULFILLED` | 线下核销 |
| `160` | `GROUP_BUY_FAIL` | 拼团失败 |
| `161` | - | 尾款支付超时自动退定金 |
| `170` | `BIZ_CANCEL` | 业务取消 |

#### `vouchers` 列表项结构

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
    "biz_uniq_key": "PtyGImP4EI",
    "order_id": "gSTS94i0uw",
    "order_out_id": "5gVEw5MAtp",
    "refund_amount": 7913968124960373287,
    "refund_time_unix": 1621914138479840662,
    "refund_scene": 1,
    "refund_count": 9037769083772306079,
    "vouchers": [
        {
            "entrance": {
                "project_id": "CaLAOHfxFw",
                "name": "PwGIe1mZEz",
                "certificate_nos": ["0TnJU9yI1F"],
                "credentials": [{"credential_no": "QonBTLHl0m", "credential_type": 1}],
                "qrcodes": ["0oT9VFfz92"],
                "status": 1
            },
            "projects": [
                {
                    "project_id": "Te0WkLW5do",
                    "name": "3yt3gzJhHZ",
                    "certificate_nos": ["0iotgHxjMS"],
                    "credentials": [{"credential_no": "QBG62UyPlB", "credential_type": 1}]
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
| `error_code` | Int32 | - | **错误码**合法范围 `[0, 999999]`。`0`: 表示成功。`100`: 表示需要重试。 |
| `description` | String | - | 错误信息描述 |

### 响应示例

```json
{
  "data": {
    "description": "x4Zq7KWsjx",
    "error_code": 0
  }
}
```
> *注：示例中的 `error_code` 应为 `0` 表示接收通知成功。若返回非 0 且非 100，抖音将不再重试。*

---

## 错误码

| 错误码 | 错误码描述 | 备注 |
| :---: | :--- | :--- |
| `0` | 成功 | 通知接收成功。**建议无论业务逻辑如何，只要收到请求都尽量返回 0**。 |
| `100` | 抖音侧需要重试 | **系统异常**。返回此码抖音侧会按照策略重试；返回其他非 0 错误码，抖音侧**不会**重试。 |

> **最佳实践**:
> 由于这是最终结果通知，为了保证数据一致性，建议在代码中捕获所有业务异常（如“订单找不到”），记录日志后依然返回 `error_code: 0`。仅在发生真正的系统故障（如网络断开、数据库不可用）时返回 `100`。