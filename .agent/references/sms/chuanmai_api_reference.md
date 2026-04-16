# 川迈短信平台接口规范 (SMS HTTP v1.6)

> 源文档: [chuanmai_sms_http_1.6.docx](file:///d:/08-Work/01-博思/10-平台2.0/.agent/references/sms/chuanmai_sms_http_1.6.docx)
> 接口验证测试: [SmsApiTest.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-msg-service/plt-msg-core/src/test/java/cn/com/bsszxc/plt/msg/sms/SmsApiTest.java)

## 通用规则

- **协议**: HTTP POST，JSON 格式，UTF-8 编码
- **Header**: `Content-Type: application/json;charset=utf-8`
- **基础路径**: `http://{address:port}/sms`
- **签名算法**: `sign = MD5(userName + timestamp + MD5(password))`，32位小写

---

## 接口列表

### 1. 批量发送 `/sms/api/sendMessageMass`

**请求参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| userName | String | 是 | 帐号用户名 |
| content | String | 是* | 短信内容，与templateId二选一 |
| templateId | Integer | 是* | 短信模板ID，与content二选一 (v1.6新增) |
| params | {Object} | 否 | 模板变量，格式: `{"变量名":"值"}` |
| phoneList | [Array] | 是 | 手机号数组，最大10000个 |
| timestamp | Long | 是 | 毫秒时间戳 |
| sign | String | 是 | MD5签名 |
| sendTime | String | 否 | 定时发送，格式: yyyy-MM-dd HH:mm:ss，限15天内 |
| extcode | String | 否 | 通道扩展码 |
| callData | String | 否 | 回传数据，最大64字符 |

**响应**: `code`(Integer) + `message`(String) + `msgId`(Long) + `smsCount`(Integer)

---

### 2. 一对一发送 `/sms/api/sendMessageOne`

**请求参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| userName | String | 是 | 帐号用户名 |
| messageList | [Array] | 是 | 消息对象数组，最大1000个 |
| timestamp | Long | 是 | 毫秒时间戳 |
| sign | String | 是 | MD5签名 |
| sendTime | String | 否 | 定时发送 |

**messageList 子对象**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | String | 是 | 手机号 |
| content | String | 是* | 短信内容，与templateId二选一 |
| templateId | Integer | 是* | 模板ID，与content二选一 |
| params | {Object} | 否 | 模板变量 |
| extcode | String | 否 | 扩展码 |
| callData | String | 否 | 回传数据 |

**响应**: `code` + `message` + `smsCount` + `data`(数组: code/message/phone/msgId/smsCount)

---

### 3. 回执状态推送 (被动接收)

由平台主动 POST 推送到客户提交的回调地址，JSON数组格式，每次≤2000条。

| 参数 | 类型 | 说明 |
|------|------|------|
| msgId | Long | 消息id |
| phone | String | 手机号 |
| status | String | DELIVRD=成功，其他=失败 |
| receiveTime | String | yyyy-MM-dd HH:mm:ss |
| smsCount | Integer | 计费条数 |
| callData | String | 回传数据(可选) |
| diffStatus | [Array] | 长短信拆分后各片段状态(可选) |

**响应**: HTTP 200 即可

---

### 4. 上行回复推送 (被动接收)

由平台主动 POST 推送，JSON数组格式，每次≤2000条。

| 参数 | 类型 | 说明 |
|------|------|------|
| content | String | 回复内容 |
| phone | String | 手机号 |
| receiveTime | String | yyyy-MM-dd HH:mm:ss |
| destId | String | 通道端口号(可选) |
| msgId | Long | 消息id(可选) |
| callData | String | 回传数据(可选) |

---

### 5. 获取回执状态 `/sms/api/getReport`

**请求**: userName + timestamp + sign + limit(可选,默认2000,范围10~10000)

**响应**: `code` + `message` + `data`(数组，字段同"回执状态推送")

> 请求间隔≥30秒，已获取数据不会重复返回

---

### 6. 获取上行回复 `/sms/api/getUpstream`

**请求**: userName + timestamp + sign + limit(可选)

**响应**: `code` + `message` + `data`(数组，字段同"上行回复推送")

> 请求间隔≥30秒

---

### 7. 查询余额 `/sms/api/getBalance`

**请求**: userName + timestamp + sign

**响应**: `code` + `message` + `balance`(Long, 短信余额)

---

### 8. 提交模板 `/sms/api/createTemplate`

**请求**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| userName | String | 是 | |
| timestamp | Long | 是 | |
| sign | String | 是 | |
| content | String | 是 | 模板内容，变量符: `{%变量%}` |
| type | Integer | 否 | 1=精准(默认), 2=模糊 |
| matchPercent | Integer | 否 | type=2时必填，60-100 |
| expireDate | String | 否 | 失效日期 yyyy-MM-dd |

**响应**: `code` + `message` + `templateId`(Integer)

---

### 9. 查询模板 `/sms/api/queryTemplates`

**请求**: userName + timestamp + sign + templateId(可选)

**响应**: `code` + `message` + `data`(数组: templateId/content/type/matchPercent)

> 请求间隔≥60秒

---

### 10. 报备签名 `/sms/api/addSignature`

**请求**: userName + timestamp + sign + signatureList(Array, 含【】符号)

**响应**: `code` + `message`

---

### 11. 查询签名 `/sms/api/querySignature`

**请求**: userName + timestamp + sign

**响应**: `code` + `message` + `data`(签名字符串数组)

> 请求间隔≥30秒

---

## 状态码

| 码 | 说明 | 码 | 说明 |
|----|------|----|------|
| 0 | 处理成功 | 11 | 24小时发送时间段限制 |
| 1 | 帐号名为空 | 12 | 定时发送时间错误或超过15天 |
| 2 | 帐号名或密码鉴权错误 | 13 | 请求过于频繁(间隔<30秒) |
| 3 | 帐号已被锁定 | 14 | 错误的用户扩展码 |
| 4 | 此帐号业务未开通 | 16 | 时间戳差异>5分钟 |
| 5 | 帐号余额不足 | 18 | 帐号未实名认证 |
| 6 | 缺少发送号码 | 19 | 帐号未开放回执状态 |
| 7 | 超过最大发送号码数 | 22 | 缺少必填参数 |
| 8 | 发送消息内容为空 | 23 | 用户帐号名重复 |
| 9 | 无效的RCS模板ID | 24 | 用户无签名限制 |
| 10 | 非法IP地址 | 25 | 签名需要包含【】符 |
| 50 | 缺少模板标题 | 97 | 不支持GET请求 |
| 51 | 缺少模板内容 | 98 | Content-Type错误 |
| 52 | 模板内容不全 | 99 | 错误的请求JSON |
| 53 | 不支持的模板帧类型 | 500 | 系统异常 |
| 54 | 不支持的文件类型 | | |
