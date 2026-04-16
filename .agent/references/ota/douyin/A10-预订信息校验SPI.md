# 预订信息校验 SPI

**更新时间**: 2025-12-30 14:58:32

---

## 接口说明

景区预订信息校验

用于消费者预订前的信息校验，包括库存和限购规则等，保障消费者提交订单后不会因为库存不足或其他业务规则被拒单

---

## 基本信息

| 名称 | 描述 |
|------|------|
| **Action** | `scenic_spot.order.can_buy` |
| **HTTP Method** | POST |
| **超时时间(ms)** | 2000 |
| **回调场景** | 景区预订信息校验 |
| **权限要求** | - 景区日历票解决方案-景区预订信息校验<br>- 景区在线预约解决方案-景区预订信息校验 |

---

## 请求参数

### 请求头

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| Content-Type | String | 是 | 示例：`application/json` |
| X-Bytedance-Logid | String | 是 | 请求LogId，用于排查问题 |
| x-life-clientkey | String | 是 | 服务商应用的client_key |
| x-life-sign | String | 是 | 请求签名 |

### Body

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| account_id | String | 否 | 抖音商家 ID |
| amount | Struct | 否 | 金额信息，见下表 |
| appointment_cancel_rule | Struct | 否 | 取消预约规则(团购线上预约返回)，见下表 |
| appointment_rule | Struct | 否 | 预约规则(团购线上预约返回)，见下表 |
| biz_type | Enum | 否 | 业务类型，见枚举值 |
| book_end_day | String | 否 | 预定结束日期，yyyy-MM-dd |
| book_start_day | String | 否 | 预定开始日期，yyyy-MM-dd |
| buyer | Struct | 否 | 购买人信息，见下表 |
| count | Int32 | 否 | 购买份数 |
| poi_id | String | 否 | 用户下单 POI（门店ID） |
| product_id | String | 否 | 抖音侧商品 ID |
| product_out_id | String | 否 | 第三方商品 ID |
| refund_rule | Struct | 否 | 退改规则，见下表 |
| sku_id | String | 否 | 抖音侧票种规格 ID |
| sku_out_id | String | 否 | 第三方票种规格 ID，下单时请求有该数据 |
| ticket_rule | Struct | 否 | 票务规则，包含凭证方式、券码类型、券码服务商，见下表 |
| ticket_specification | Struct | 否 | 票种规格说明（日历票下单参数），见下表 |
| tourists | List | 否 | 出行人信息，结构同 buyer |
| traveler_info | Struct | 否 | 出行人信息，见下表 |

#### amount 结构

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| origin_amount | Int64 | 是 | 原始金额，分 |
| pay_amount | Int64 | 是 | 支付金额，分 |
| currency | String | 否 | 币种，默认 CNY |
| merchant_discount_amount | Int64 | 否 | 商家优惠金额，分 |

#### appointment_cancel_rule 结构

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| cancel_detail_list | List | 否 | 取消规则明细列表，见下表 |
| cancel_type | Int32 | 否 | 取消类型：2 不可取消，4 限时取消（按规则），5 未用随时取消 |

**cancel_detail_list 结构**

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| max_cancel_time | Struct | 否 | 最晚取消时间，包含 day(天)、hour(小时)、minute(分钟) |

#### appointment_rule 结构

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| ahead_day | Int32 | 否 | 需要提前X天电话预约 |
| ahead_sec | Int64 | 否 | 预约提前时间（单位：秒），例：20:00点前预约，值为 72000 |
| open_time_period | Struct | 否 | 预约时段，包含 start_time(起始时间)、end_time(结束时间) |
| part_appointment | Bool | 否 | 是否支持部分预约 |

#### buyer 结构

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| name | String | 是 | 姓名，加密 |
| phone | String | 是 | 联系电话，加密 |

#### refund_rule 结构

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| refund_type | Enum | 是 | 退改类型，见枚举值 |
| auto_refund_time | Int64 | 否 | 自动退，离园日 24 时往后推的秒数 |
| auto_verify_timestamp | Int64 | 否 | 自动核销时间，绝对值 |
| can_refund_partly | Bool | 否 | 是否支持部分退 |
| refund_details | List | 否 | 退改详情，支持多个阶梯退，见下表 |

**refund_details 结构**

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| refund_fee | Int64 | 是 | 退款手续费：金额类型单位为分；比例类型单位为万分位 |
| refund_fee_type | Enum | 是 | 退改手续费类型，见枚举值 |
| refund_time | Int64 | 是 | 入园日 24 时往前倒推的秒数 |

#### ticket_rule 结构

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| url_type | Enum | 是 | URL凭证类型，见枚举值 |
| code_sending_info | List | 否 | 凭证发放方式（多选），见枚举值 |
| code_type | Enum | 否 | 券码类型，见枚举值 |

#### ticket_specification 结构

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| ticket_area | String | 否 | 区域 |
| ticket_seat | String | 否 | 坐席 |
| ticket_session | Struct | 否 | 场次，包含 ticket_session_name(名称，必填)、ticket_session_time(时间) |

#### traveler_info 结构

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| diff_target_crowd | Bool | 是 | 是否区分人群 |
| total_num | Int32 | 是 | 出行总人数 |
| crowd_list | List | 否 | 人群列表，见下表 |

**crowd_list 结构**

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| crowd_type | Enum | 否 | 人群类型，见枚举值 |
| traveler_num | Int32 | 否 | 出行人数 |

---

### 枚举值定义

#### biz_type

| 值 | 描述 |
|----|------|
| 1 | 团购 |
| 2 | 日历票 |
| 3 | 团购(在线预约) |

#### refund_type

| 值 | 描述 |
|----|------|
| 1 | 未使用随时退 |
| 2 | 不可退 |
| 3 | 有条件退 |

#### refund_fee_type

| 值 | 描述 |
|----|------|
| 1 | 金额 |
| 2 | 比例 |

#### url_type

| 值 | 描述 |
|----|------|
| 1 | 静态链接,如二维码 |
| 2 | 其他 |

#### code_sending_info

| 值 | 描述 |
|----|------|
| 1 | 身份证 |
| 2 | 券号 |
| 3 | 券码 |
| 6 | URL（商品模板中4-5已被占用，为保持一致性） |

#### code_type

| 值 | 描述 |
|----|------|
| 1 | SYSTEM |
| 2 | THIRD |
| 3 | THIRD_RESERVE |
| 5 | 营销券 |

#### license_type

| 值 | 描述 |
|----|------|
| 1 | 身份证 |
| 2 | 港澳通行证 |
| 3 | 台湾通行证 |
| 4 | 回乡证 |
| 5 | 台胞证 |
| 6 | 护照 |
| 7 | 外籍护照 |

#### crowd_type

| 值 | 描述 |
|----|------|
| 1 | 儿童 |
| 2 | 成人 |
| 3 | 老人 |
| 4 | 学生 |
| 5 | 特殊人群 |
| 6 | 男士 |
| 7 | 女士 |
| 8 | 团体 |
| 9 | 情侣 |
| 10 | 军人 |
| 11 | 教师 |
| 12 | 残疾人 |
| 13 | 婴儿 |
| 14 | 成人+儿童 |

---

### 请求示例

```curl
curl --location --request POST '示例地址' \
--header 'content-type: application/json' \
--header 'access-token: 0801121846735352506a356a6 ' \
--data '{
    "account_id": "GoV6qnv4xX",
    "amount": {
        "currency": "DC1ZKk2rb0",
        "merchant_discount_amount": 3440708988397936301,
        "origin_amount": 6787434079299330420,
        "pay_amount": 8970795871740188813
    },
    "appointment_cancel_rule": {
        "cancel_detail_list": [
            {
                "max_cancel_time": {
                    "day": 8311966158041928255,
                    "hour": 2836829000667327938,
                    "minute": 6906485218349946822
                }
            }
        ],
        "cancel_type": 469946624436786200
    },
    "appointment_rule": {
        "ahead_day": 8280309966210459508,
        "ahead_sec": 5991038888072069610,
        "open_time_period": {
            "end_time": "e0bh0fzx6O",
            "start_time": "MQ9g3T4oFw"
        },
        "part_appointment": false
    },
    "biz_type": 1,
    "book_end_day": "3A42EDWyTJ",
    "book_start_day": "HnMdkKbCJ6",
    "buyer": {
        "age": 6693620944364462686,
        "birthday": "WZo5cm5Dar",
        "crowd_type": 1,
        "email": "YGKgbHBwbq",
        "en_first_name": "YAwnKz321A",
        "en_last_name": "LNsW5jydSD",
        "first_name": "HSl0WoJh1C",
        "last_name": "3z8v5gSi4L",
        "license_id": "PMT6RJQN1M",
        "license_type": 1,
        "license_validity": "EwCH0A5e4D",
        "marital_status": 9096286413882743345,
        "name": "ZGmEhHdyva",
        "phone": "knwnPhjKRL",
        "room_index": 9210640845304303251,
        "sex": 6677608059687804087
    },
    "count": 775173495617603114,
    "poi_id": "Uz3B9CZ6vP",
    "product_id": "atpJIMNp2T",
    "product_out_id": "A8R4JnQ8BQ",
    "refund_rule": {
        "auto_refund_time": 9190738091615699234,
        "auto_verify_timestamp": 2242298254347577996,
        "can_refund_partly": false,
        "refund_details": [
            {
                "refund_fee": 5457058560804355768,
                "refund_fee_type": 1,
                "refund_time": 5547471341607665501
            }
        ],
        "refund_type": 1
    },
    "sku_id": "laZfcx9nPP",
    "sku_out_id": "j5D26hROtT",
    "ticket_rule": {
        "code_sending_info": [1],
        "code_type": 1,
        "url_type": 1
    },
    "ticket_specification": {
        "ticket_area": "OngJfTwwmX",
        "ticket_seat": "e14TVhrTg9",
        "ticket_session": {
            "ticket_session_name": "N3TOFieRzu",
            "ticket_session_time": "Oi2i1VVhim"
        }
    },
    "tourists": [
        {
            "age": 7474813870858405568,
            "birthday": "jeAzsyJpvH",
            "crowd_type": 1,
            "email": "OmHU4NaBEN",
            "en_first_name": "qID8qim4oE",
            "en_last_name": "7mqabTjPdc",
            "first_name": "UhHhKA28wb",
            "last_name": "m2clJd4Jcd",
            "license_id": "WFN45U9WHi",
            "license_type": 1,
            "license_validity": "0K5Zf8PRKE",
            "marital_status": 1976674809009230908,
            "name": "38MVNHZWC1",
            "phone": "R9n3CY0uBj",
            "room_index": 5231089506790025021,
            "sex": 1576021255886024735
        }
    ],
    "traveler_info": {
        "crowd_list": [
            {
                "crowd_type": 1,
                "traveler_num": 4188511217951641153
            }
        ],
        "diff_target_crowd": false,
        "total_num": 257922651732880741
    }
}'
```

## 响应参数

### Body

| 参数 | 类型 | 描述 |
|------|------|------|
| data | Struct | 响应数据体，包含 error_code(错误码)、description(错误描述) |

### 响应示例

```json
{
  "data": {
    "description": "ueXoPu09Eq",
    "error_code": 8552983503041389000
  }
}
```

## 错误码

| 错误码 | 错误码描述 | 备注 |
|--------|------------|------|
| 0 | 成功 | 成功 |
| 1 | 库存不足 | 库存不足 |
| 2 | 商品已下架 | 商品已下架 |
| 3 | 当前出行人已购票 | 当前出行人已购票 |
| 4 | 当前日期不可预订 | 当前日期不可预订 |
| 5 | 年龄不符合，仅限指定年龄的用户购买 | 年龄不符合，仅限指定年龄的用户购买 |
| 6 | 性别不符合，仅限指定性别的用户购买 | 性别不符合，仅限指定性别的用户购买 |
| 7 | 身份证限购，用户已达购买上限 | 身份证限购，用户已达购买上限 |
| 8 | 手机号限购，用户已达购买上限 | 手机号限购，用户已达购买上限 |
| 9 | 订单购买数量超过上限 | 订单购买数量超过上限 |
| 10 | 用户地区不符合，仅限特定地区的用户购买 | 用户地区不符合，仅限特定地区的用户购买 |
| 11 | 其他原因限购（请返回具体原因） | 其他原因限购（请返回具体原因） |
| 12 | 缺少手机号信息 | 缺少手机号信息 |
| 13 | 缺少证件信息 | 缺少证件信息 |
| 14 | 缺少出行人姓名 | 缺少出行人姓名 |
| 15 | 出行人数和份数不匹配 | 出行人数和份数不匹配 |
| 19 | 手机号格式问题 | 手机号格式问题 |
| 20 | 证件号格式问题 | 证件号格式问题 |
| 21 | 姓名格式问题 | 姓名格式问题 |
| 22 | 商家账户余额不足，无法下单（服务商场景使用） | 商家账户余额不足，无法下单（服务商场景使用） |
| 23 | 价格不一致 | 价格不一致 |
| 100 | 商家系统内部异常，需要抖音侧重试调用 | 商家系统内部异常，需要抖音侧重试调用 |
| 999999 | 其他原因不可预订，请返回具体原因（抖音不重试调用） | 其他原因不可预订，请返回具体原因（抖音不重试调用） |