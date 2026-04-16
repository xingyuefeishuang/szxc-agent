# 发放凭证 SPI

**更新时间**: 2026-01-14 11:30:43

---

## 接口说明

- 三方码发券 SPI，抖音通知三方发码。如果为同步发码则返回三方码，异步发码则根据发码通知的凭证单的映射关系异步发放三方码。
- 对接方需保证，当凭证回调给抖音成功后才可用，用户才能入园。
- 抖音侧服务商接单成功后向服务商发起发放凭证申请。
- 同步发码在 10min 请求不到服务商的码则会自动退货并发起退款流程。
    - 如果同步无法完成发码，可接入异步链路。

---

## 基本信息

| 名称 | 描述 |
|------|------|
| **HTTP URL** | 地址由服务商提供 |
| **HTTP Method** | POST（抖音侧向开发者侧发起请求，超时时间 8s） |
| **权限要求** | - 需要申请权限，路径：抖音开放平台-服务商平台 > 控制台 > 应用详情 > 解决方案需要 url 配置<br>- 路径：联系抖音对接技术人员，做配置需要商家授权，路径：抖音来客 > 店铺管理 > 第三方应用授权 |

---

## 请求头

| 参数 | 类型 | 描述 |
|------|------|------|
| Content-Type | String | `application/json` |
| X-Bytedance-Logid | String | 请求 logid，用于问题排查 |
| x-life-clientkey | String | 服务商应用的 client_key |
| X-life-sign | String | 请求签名，[签名规则] |

---

## 请求体

| 参数 | 类型 | 必填 | 是否加密 | 描述 |
|------|------|------|----------|------|
| order_id | string | 是 | 否 | 抖音侧的订单号 |
| count | int | 是 | 否 | 每份出行人数，商品多个适用人群的 crowd_num 总和。比如家庭票一份包含了多个人，非家庭票只有一个出行人 |
| start_time | int | 是 | 否 | 预约开始时间，时间戳，秒 |
| expire_time | int | 是 | 否 | 预约截至时间，时间戳，秒 |
| sku | object | 是 | 否 | 商品信息 |
| amount | struct | 否 | 否 | 金额信息 |
| ticket_rule | object | 否 | 否 | 票务规则 |
| tourists | list(object) | 否 | 否 | 出行人信息 |
| copies | int | 否 | 否 | 购买份数，一单买 3 份传 3，与回传的 vouchers 集合 size 对应 |

### sku 结构

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| sku_name | string | 是 | 抖音商品名 |
| sku_id | string | 是 | 抖音的商品 ID |
| third_sku_id | string | 是 | 三方服务商侧的商品 ID |

### amount 结构

| 参数 | 类型 | 描述 |
|------|------|------|
| original_amount | int | 原始金额，单位分 |
| pay_amount | int | 用户实付金额，单位分 |
| ticket_amount | int | 平台营销金额，单位分 |
| merchant_ticket_amount | int | 商家营销金额，单位分 |
| merchant_ticket_amount_details | list(object) | 商家营销金额明细 |
| .funder_type | int | 出资类型：1=货款出资，2=商家钱包 |
| .amount | int | 明细金额，单位分 |
| fee_amount | int | 支付手续费，单位分 |
| commission_amount | int | 达人分佣金额，单位分 |
| payment_discount_amount | int | 支付优惠金额，单位分（平台补贴的一种） |
| coupon_pay_amount | int | 券实付金额（=用户实付金额+支付优惠金额），单位分 |

**金额说明：**
- 商家实收（抽佣前）= 原始金额 - 商家营销金额
- 商家实收（抽佣后）此接口不提供
- 平台营销金额：平台补贴的金额
- 支付优惠金额：使用平台支付优惠的平台补贴金额

### ticket_rule 结构

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| code_sending_info | list(int) | 是 | 凭证发放方式，多选：1=身份证，2=券号，3=券码，6=链接 URL |
| code_type | int | 否 | 券码类型；2=三方码 |
| url_type | int | 否 | 外部链接内容，code_sending_info 包含 6 时：1=静态二维码，2=其他 |

### tourists 结构

| 参数 | 类型 | 描述 |
|------|------|------|
| name | string | 姓名 |
| phone | string | 联系电话 |
| id_card | string | 身份证号码 |
| credential_type | int | 证件类型：1 身份证，2 港澳通行证，3 台湾通行证，4 回乡证，5 台胞证，6 护照，7 外籍护照，8 外国人永久居留证 |

---

## 请求示例

### 全部游玩人（商品属性 reserved_type = 3，tourists 个数等于 copies × count）

```json
{
    "order_id": "12345678",
    "count": 1,
    "sku_id": "23456",
    "third_sku_id": "345678",
    "sku": {
        "sku_id": "23456",
        "sku_name": "虹口漂流多人票",
        "third_sku_id": "23785"
    },
    "amount": {
        "original_amount": 10000,
        "pay_amount": 8000,
        "ticket_amount": 1000,
        "merchant_ticket_amount": 1000,
        "payment_discount_amount": 1000,
        "coupon_pay_amount": 1000
    },
    "tourists": [
        {
            "name": "张三",
            "phone": "13800000000",
            "id_card": "310115199807013370"
        },
        {
            "name": "李四",
            "phone": "13900000000",
            "id_card": "310115199912130020"
        }
    ],
    "start_time": 1664553600,
    "expire_time": 1665158399,
    "copies": 2
}
```

### 一单一人（tourists 个数等于 1）

```json
{
"order_id": "12345678",
"count": 2,
"sku_id": "23456",
"third_sku_id": "345678",
"amount": {
"original_amount": 10000,
"pay_amount": 8000,
"ticket_amount": 1000,
"merchant_ticket_amount": 1000,
"payment_discount_amount": 1000,
"coupon_pay_amount": 1000
},
"tourists": [
{
"name": "张三",
"phone": "13800000000",
"id_card": "310115199807013370"
}
],
"start_time": 1664553600,
"expire_time": 1665158399,
"copies": 3
}
```

## 响应参数

| 字段名称 | 字段类型 | 必填 | 描述 |
|----------|----------|------|------|
| data | object | 是 | 响应数据体 |

### data 结构

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| error_code | int64 | 是 | 接口错误码 |
| description | string | 是 | 接口错误描述 |
| result | int | 是 | 发码结果：0 发码中，1 成功，2 失败 |
| fail_reason | string | 否 | 失败原因 |
| vouchers | list | 否 | 凭证列表（result=1 时必填） |

#### vouchers 结构

| 参数 | 类型 | 描述 |
|------|------|------|
| entrance | struct | 景区的入园项目（若入园凭证是单独的凭证，则使用此字段；若不是，可使用自定义项目字段） |
| projects | list(object) | 可自定义的项目（例：景区项目索道 A、索道 B 等） |

##### entrance / projects 元素结构

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| project_id | string | 是 | 项目的唯一标识，同一个订单下不能重复（核销时需要） |
| name | string | 仅 projects 中需要 | 自定义的项目名称（例：景区 XXXX 索道） |
| id_cards | list(string) | 否（废弃） | 身份证号码，最多 100 个 |
| qrcodes | list(string) | 否 | 二维码凭证内容，会生成二维码展示，每个字符串长度不超过 512 |
| certificate_nos | list(string) | 否 | 券号凭证，最多 100 个 |
| gmcode_imgs | list(string) | 否 | GM 码数据流 base64 字符串列表，单个图片大小 ≤ 1M（若使用图片数据流，则不支持使用 qrcodes） |
| urls | list(string) | 否 | 链接凭证，在 C 端直接展示此链接 |
| credentials | list(object) | 否 | 证件列表（推荐使用，替代 id_cards） |
| .credential_type | int | 否 | 凭证类型：1 身份证，2 港澳通行证，3 台湾通行证，4 回乡证，5 台胞证，6 护照，7 外籍护照，8 外国人永久居留证 |
| .credential_no | string | 否 | 凭证号 |

---

    1.发码结果

    a.发码中，则必须十分钟内通过凭证回调接口回调抖音侧告知结果，否则会自动取消预约

    b.发码成功，则必须在响应中直接返回正确的凭证 (后面不需要回调)

    c.发码失败，

    i.接口请求成功时务必确保 error_code=0, 发放券码的结果通过 data.result 字段返回。

    ii.若 error_code 不为 0，不处理 data 中的数据，抖音会十分钟内多次重试发券请求。

    2.凭证

    a.entrance和projects不能同时都为空

    b.id_cards、qrcodes、certificate_nos不能同时都为空，与商品的code_sending_info属性对应

    c.code_sending_info必须要配置才能回传，凭证方式可以全部配置，无需回传所有凭证，至少回传任一凭证即可，但是不允许出现如未配置身份证，但是回传了身份证这种case

    d.id_cards、qrcodes、certificate_nos返回的各自集合长度不能超过请求的count

    e.如果请求带了tourists，则返回的id_cards集合身份证信息必须包含在tourists中

    f.vouchers的size需要与发码请求的copies大小一致，copies代表一单买了几份

    g.注意copies和count是2个不同的概念

    h.订单维度project_id需要唯一，不能重复

    i.gmcode_imgs 仅需要数据部分，如：“iVBORw...Jggg==”，无需前置格式信息（如：“data:image/jpeg;base64,”）。

    j.id_cards 字段已废弃，使用credential_type、credentials传输证件类型和证件号

### 响应示例

#### 发码中

```json
{
  "data": {
    "error_code": 0,
    "description": "success",
    "result": 0
  }
}
```

#### 发码成功

- 1单1份（每份1个出行人，只包含门票，凭证类型为身份证）

```json
{
  "data": {
    "error_code": 0,
    "description": "success",
    "result": 1,
    "vouchers": [
      {
        "entrance": {
          "project_id": "1",
          "credentials": [
          {
              "credential_type": 1,
              "credential_no":"310115199807013370"
          }
          ]
        }
      }
    ]
  }
}
```

- 1单1份（每份1个出行人，只包含门票，凭证类型为身份证+券码）

```json
{
  "data": {
    "error_code": 0,
    "description": "success",
    "result": 1,
    "vouchers": [
      {
        "entrance": {
          "project_id": "1",
          "credentials": [
            {
              "credential_type": 1,
              "credential_no":"310115199807013370"
            }
          ],
          "qrcodes": [
            "qr_code1_096700560961"
          ]
        }
      }
    ]
  }
}
```

- 1单1份（每份1个出行人，只包含门票）

```json
{
  "data": {
    "error_code": 0,
    "description": "success",
    "result": 1,
    "vouchers": [
      {
        "entrance": {
          "project_id": "1",
          "credentials": [
            {
              "credential_type": 1,
              "credential_no":"310115199807013370"
            }
          ],
          "qrcodes": [
            "qr_code1_096700560961"
          ],
          "certificate_nos": [
            "a_096700560961"
          ]
        }
      }
    ]
  }
}
```

- 1单1份（每份1个出行人，包含门票+园内项目）

```json
{
  "data": {
    "error_code": 0,
    "description": "success",
    "result": 1,
    "vouchers": [
      {
        "entrance": {
          "project_id": "1",
          "credentials": [
            {
              "credential_type": 1,
              "credential_no":"310115199807013370"
            }
          ],
          "qrcodes": [
            "qr_code1_096700560961"
          ],
          "certificate_nos": [
            "a_096700560961"
          ]
        },
        "projects": [
          {
            "name": "园内项目A",
            "project_id": "2",
            "credentials": [
              {
                "credential_type": 1,
                "credential_no":"310115199807013370"
              }
            ],
            "qrcodes": [
              "qr_code2_806011925184"
            ],
            "certificate_nos": [
              "b_806011925184"
            ]
          }
        ]
      }
    ]
  }
}
```

- 1单2份（每份1个出行人，包含门票+园内项目）

```json
{
  "data": {
    "error_code": 0,
    "description": "success",
    "result": 1,
    "vouchers": [
      {
        "entrance": {
          "project_id": "1",
          "credentials": [
            {
              "credential_type": 1,
              "credential_no":"310115199807013370"
            }
          ],
          "qrcodes": [
            "qr_code1_096700560961"
          ],
          "certificate_nos": [
            "a_096700560961"
          ]
        },
        "projects": [
          {
            "name": "园内项目A",
            "project_id": "2",
            "credentials": [
              {
                "credential_type": 1,
                "credential_no":"310115199807013370"
              }
            ],
            "qrcodes": [
              "qr_code2_806011925184"
            ],
            "certificate_nos": [
              "b_806011925184"
            ]
          }
        ]
      },
      {
        "entrance": {
          "project_id": "3",
          "credentials": [
            {
              "credential_type": 1,
              "credential_no":"310115199807013371"
            }
          ],
          "qrcodes": [
            "qr_code1_096700560962"
          ],
          "certificate_nos": [
            "a_096700560962"
          ]
        },
        "projects": [
          {
            "name": "园内项目A",
            "project_id": "4",
            "credentials": [
              {
                "credential_type": 1,
                "credential_no":"310115199807013372"
              }
            ],
            "qrcodes": [
              "qr_code2_806011925182"
            ],
            "certificate_nos": [
              "b_806011925182"
            ]
          }
        ]
      }
    ]
  }
}
```

- 1单1份（每份3个出行人，包含门票+园内项目）

```json
{
  "data": {
    "error_code": 0,
    "description": "success",
    "result": 1,
    "vouchers": [
      {
        "entrance": {
          "project_id": "1",
          "credentials": [
            {
              "credential_type": 1,
              "credential_no": "310115199807013370"
            },
            {
              "credential_type": 1,
              "credential_no": "310115199807013371"
            },
            {
              "credential_type": 1,
              "credential_no": "310115199807013372"
            }
          ],
          "qrcodes": [
            "qr_code1_096700560961",
            "qr_code1_096700560962",
            "qr_code1_096700560963"
          ],
          "certificate_nos": [
            "a_096700560961",
            "a_096700560962",
            "a_096700560963"
          ]
        },
        "projects": [
          {
            "name": "xx景区A项目",
            "project_id": "2",
            "credentials": [
              {
                "credential_type": 1,
                "credential_no": "310115199807013370"
              },
              {
                "credential_type": 1,
                "credential_no": "310115199807013371"
              },
              {
                "credential_type": 1,
                "credential_no": "310115199807013372"
              }
            ],
            "qrcodes": [
              "qr_code2_806011925184",
              "qr_code2_806011925133",
              "qr_code2_806011925136"
            ],
            "certificate_nos": [
              "b_806011925184",
              "b_806011925123",
              "b_806011925125"
            ]
          }
        ]
      }
    ]
  }
}
```

- 部分退商品&留资有身份证（身份证必传）

```json
{
  "data": {
    "error_code": 0,
    "description": "success",
    "result": 1,
    "vouchers": [
      {
        "entrance": {
          "project_id": "1",
          "credentials": [
            {
              "credential_type": 1,
              "credential_no":"310115199807013370"
            }
          ]
        }
      }
    ]
  }
}
```