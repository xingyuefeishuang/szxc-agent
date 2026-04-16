# SPI 签名机制说明

**更新时间**: 2025-11-29 09:41:21

### 签名规则（new）

#### URL 中的参数

| 参数名称 | 参数类型 | 参数描述 | 必需 |
| :--- | :--- | :--- | :--- |
| client_key | string | 服务商的 client_key | 是 |
| timestamp | string | 时间戳，单位毫秒 | 是 |
| sign | string | 生成签名时忽略该字段 | 否 |

#### Header 中的 sign 参数

调用路径为抖音调用服务商的接口，会传递以下内容在 Header 中：

| 参数名称 | 参数类型 | 参数描述 | 必需 |
| :--- | :--- | :--- | :--- |
| x-life-clientkey | string | 服务商的 client_key | 是（仅作应用标识用） |
| x-life-sign | string | 新签名 | 是 验签用 |

**该 sign 的生成方式:**

1. 以三方服务商的 `client_secret` 开头; 然后将除 `sign` 之外的 URL 参数以 `key=value` 的形式按 key 的字典升序排列; 若为 POST 请求，还需要加上 HTTP 的 BODY, key 固定为 `http_body` (`http_body` 的内容不参与排序，加到最后)。最后所有的这些项以字符 `&` 串联起来即为待签名内容 `str1`. 发码接口的示例如下 (假设 `client_secret` 为 `yyyyyy`):
2. `str1` 的内容是 `yyyyyy&client_key=xxxxxx&timestamp=1624293280123&http_body=zzzzzz` 【注意：`client_key` 参数需从 URL 中动态获取，请勿直接固定写死，否则会导致验签失败】
3. 然后将待签名内容 `str1` 计算 SHA-256 哈希值，得到的结果即为 `sign`。
4. 抖音将用于签名生成的 `httpBody` 以 `[]byte` 类型请求服务商，服务商请不要将 `[]byte` 反序列化成 object 再序列化 string 用于签名校验。这样会导致 json 中的字段顺序与抖音不符，同时若抖音侧将 `httpBody` 进行改动，也会导致签名校验不通过。