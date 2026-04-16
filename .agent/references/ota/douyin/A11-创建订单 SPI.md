# 创建订单 SPI

**更新时间**: 2025-12-30 14:58:27

---

## 接口说明

抖音侧通知第三方创建景区订单

1. ClientKey 维度默认配置是 抖音侧支付成功后 通知第三方创单，不额外通知支付成功。  
2. 抖音请求第三方超时，如支付前创单则默认创单成功，抖音会走后续链路支付订单；如支付后创单，重试仍超时，则会拒单  
3. 接口中存在加密字段，解密请参考文档：[加密字段解密方法]

---

## 基本信息

| 名称 | 描述 |
|------|------|
| **Action** | `scenic_spot.order.create_order` |
| **HTTP Method** | POST |
| **超时时间(ms)** | - |
| **回调场景** | 酒旅-景区创建订单 |
| **权限要求** | 景区行业解决方案-景区创建订单 |

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
| amount | Struct | 是 | 金额信息，见下表 |
| buyer | Struct | 是 | 购买人信息，见下表 |
| count | Int32 | 是 | 购买份数（等于「发放凭证」接口的 copies） |
| create_order_time_unix | Int64 | 是 | 创建订单时间戳，秒 |
| custom_spi_req_extra | String | 是 | 非标请求信息 |
| item_order_infos | List | 是 | 子单信息，见下表 |
| order_id | String | 是 | 抖音侧订单 ID（可作幂等键） |
| remark_info | Struct | 是 | 订单备注，见下表 |
| sku_id | String | 是 | 抖音侧票种规格 ID |
| account_id | String | 否 | 抖音商家 ID |
| appointment_cancel_rule | Struct | 否 | 取消预约规则，见下表 |
| appointment_rule | Struct | 否 | 预约规则，见下表 |
| biz_type | Enum | 否 | 业务类型，见枚举值 |
| book_end_day | String | 否 | 预定结束日期，yyyy-MM-dd |
| book_start_day | String | 否 | 预定开始日期，yyyy-MM-dd |
| order_type | Enum | 否 | 业务类型：1-券订单，2-预约订单，见枚举值 |
| poi_id | String | 否 | 用户下单 POI（即门店id） |
| product_id | String | 否 | 抖音侧商品 ID |
| product_out_id | String | 否 | 第三方商品 ID |
| refund_rule | Struct | 否 | 退改规则，见下表 |
| remark | String | 否 | 备注要求 |
| sku_out_id | String | 否 | 第三方票种规格 ID |
| source_order_id | String | 否 | 抖音侧关联第一笔订单 ID |
| ticket_rule | Struct | 否 | 票务规则，见下表 |
| ticket_specification | Struct | 否 | 票种规格说明，见下表 |
| tourists | List | 否 | 游玩人（出行人）信息，结构同 buyer |
| traveler_info | Struct | 否 | 出行人群信息，见下表 |

#### amount 结构

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| origin_amount | Int64 | 是 | 原始金额，分 |
| pay_amount | Int64 | 是 | 支付金额，分 |
| currency | String | 否 | 币种，默认 CNY |
| merchant_discount_amount | Int64 | 否 | 商家优惠金额，分 |

#### buyer 结构

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| name | String | 是 | 姓名，加密 |
| phone | String | 是 | 联系电话，加密 |

#### item_order_infos 结构

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| item_order_id | String | 是 | 子单号 |

#### remark_info 结构

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| question_and_answer_list | List | 否 | 问答信息，用户下单时填写，见下表 |

**question_and_answer_list 结构**

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| answers | List | 否 | 回答，1个问题可以有多个回答 |
| question | String | 否 | 问题 |

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
| 3 | 期票预售券（团购在线预约） |

#### order_type

| 值 | 描述 |
|----|------|
| 1 | 券订单 |
| 2 | 预约订单 |

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
| 0 | 不需要留资的缺省值 |
| 1 | 身份证 |
| 2 | 港澳通行证 |
| 3 | 台湾通行证 |
| 4 | 回乡证 |
| 5 | 台胞证 |
| 6 | 护照 |
| 7 | 外籍护照 |
| 8 | 外国人永久居留证 |

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
    "account_id": "pjk6PULd33",
    "amount": {
        "currency": "8o90qd8oYo",
        "merchant_discount_amount": 495560544447558318,
        "origin_amount": 3609434795103322793,
        "pay_amount": 6733799778232109046
    },
    "appointment_cancel_rule": {
        "cancel_detail_list": [
            {
                "max_cancel_time": {
                    "day": 8413044253624471654,
                    "hour": 1918271037377487064,
                    "minute": 4217727426622293672
                }
            }
        ],
        "cancel_type": 2394756656683341996
    },
    "appointment_rule": {
        "ahead_day": 1790403770332943223,
        "ahead_sec": 2612974171689918600,
        "open_time_period": {
            "end_time": "zXXoXZC9ma",
            "start_time": "7yGvo3zBUJ"
        },
        "part_appointment": false
    },
    "biz_type": 1,
    "book_end_day": "GN1BlRqsoH",
    "book_start_day": "hfOp2WvXqU",
    "buyer": {
        "age": 3535247377272555830,
        "birthday": "grTvy2BnC8",
        "crowd_type": 1,
        "email": "MOYwYnOmhk",
        "en_first_name": "AtnBWhgoIj",
        "en_last_name": "IA66jA6zLo",
        "first_name": "RMhUlyXA5V",
        "last_name": "WxCuvsAUHD",
        "license_id": "tBiZfgxBkU",
        "license_type": 1,
        "license_validity": "ZkwCcFI7pN",
        "marital_status": 101596542867531423,
        "name": "gP536cObmi",
        "phone": "4OiCAc8vNf",
        "room_index": 4102516810313261778,
        "sex": 585562545164803971
    },
    "count": 4697819334744040456,
    "create_order_time_unix": 5166626147570759942,
    "custom_spi_req_extra": "Iyr5BBKpmq",
    "item_order_infos": [
        {
            "item_order_id": "rJMkri7K8l"
        }
    ],
    "order_id": "Qyoxf8j8Ch",
    "order_type": 1,
    "poi_id": "fUkI4jJ8Cr",
    "product_id": "BE9xNkRRWj",
    "product_out_id": "Cy7KYtjeoI",
    "refund_rule": {
        "auto_refund_time": 4976174771204238718,
        "auto_verify_timestamp": 1080691939503253804,
        "can_refund_partly": false,
        "refund_details": [
            {
                "refund_fee": 6130862396652446531,
                "refund_fee_type": 1,
                "refund_time": 5603400134861663365
            }
        ],
        "refund_type": 1
    },
    "remark": "QwGS38HVX9",
    "remark_info": {
        "question_and_answer_list": [
            {
                "answers": ["u0Ss92bkBQ"],
                "question": "K4OYZTVkam"
            }
        ]
    },
    "sku_id": "gGCmshWVAa",
    "sku_out_id": "WRFJpZxLko",
    "source_order_id": "3YFmmlXQDE",
    "ticket_rule": {
        "code_sending_info": [1],
        "code_type": 1,
        "url_type": 1
    },
    "ticket_specification": {
        "ticket_area": "xcJlpz6KZ5",
        "ticket_seat": "0V79XbWDjq",
        "ticket_session": {
            "ticket_session_name": "amsZyCezFu",
            "ticket_session_time": "vGOd45meFi"
        }
    },
    "tourists": [
        {
            "age": 7464244003800344359,
            "birthday": "2Af0W84ih1",
            "crowd_type": 1,
            "email": "1fJUCMVxxs",
            "en_first_name": "PcCeIxVn8E",
            "en_last_name": "gfWSQYEApb",
            "first_name": "RJVjuQdMLu",
            "last_name": "T3VkqZ9eqr",
            "license_id": "NoH3SkaTLp",
            "license_type": 1,
            "license_validity": "xQyk5OCJyD",
            "marital_status": 3542852323108725341,
            "name": "h0OaO3nFNg",
            "phone": "Rd01kkxaJ0",
            "room_index": 6216108291943234507,
            "sex": 5047792592958847141
        }
    ],
    "traveler_info": {
        "crowd_list": [
            {
                "crowd_type": 1,
                "traveler_num": 9147639061771389339
            }
        ],
        "diff_target_crowd": false,
        "total_num": 8071719933243139447
    }
}'
```

## 响应参数

### Body

| 参数 | 类型 | 描述 |
|------|------|------|
| data | Struct | 响应数据体，包含 error_code、description、order_out_id、confirm_info 等字段 |

#### data 结构

| 参数 | 类型 | 描述 |
|------|------|------|
| confirm_info | Struct | 确认信息，包含 confirm_mode、confirm_result、fulfil_type、hotel_confirm_number |
| description | String | 错误描述 |
| error_code | Int | 错误码 |
| order_out_id | String | 第三方订单 ID |

---

### 响应示例

```json
{
  "data": {
    "confirm_info": {
      "confirm_mode": 1,
      "confirm_result": 1,
      "fulfil_type": 1,
      "hotel_confirm_number": "CbHrqneVrF"
    },
    "description": "MxclRFgkEc",
    "error_code": 2494561191208208400,
    "order_out_id": "prQToaaHml"
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