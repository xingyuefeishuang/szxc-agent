# 生成 client-token

**更新时间**: 2025-07-31 21:42:04

## 接口说明

该接口用于获取接口调用的凭证 `client_token`。该接口适用于抖音授权。

## 业务场景

`client_token` 用于**不需要用户授权**就可以调用的接口（服务端自主调用）。

## 注意事项

1.  **有效期与互斥**：
    *   `client_token` 的有效时间为 **2 个小时**。
    *   重复获取 `client_token` 后会使上次的 `client_token` 失效。
    *   **缓冲机制**：有 5 分钟的缓冲时间，连续多次获取 `client_token` 只会保留最新的两个 `client_token`。
2.  **频控限制**：
    *   禁止频繁调用 access-token 接口。
    *   **规则**：5 分钟内超过 500 次接口调用，接口将报错（错误码 `10020`）。
3.  **环境隔离**：
    *   **正式上线后**，测试环境**不能**使用正式的 `client_key` 和 `client_secret` 获取 token。
    *   否则会导致线上正式环境的 token 失效，严重影响线上业务。

## 基本信息

| 名称 | 描述 |
| :--- | :--- |
| **HTTP URL** | `https://open.douyin.com/oauth/client_token/` |
| **HTTP Method** | `POST` |

## 请求参数

### 请求头 (Headers)

| Key | 字段类型 | 示例 | 描述 |
| :--- | :--- | :--- | :--- |
| `content-type` | String | `application/json` | **必填**。固定值 `"application/json"` |

### 请求体 (Body)

| Key | 字段类型 | 示例 | 描述 |
| :--- | :--- | :--- | :--- |
| `client_key` | String | `ttxxxxxx` | **必填**。应用唯一标识。获取方式：- 小程序：通用参数- 移动网站应用：通用参数 |
| `client_secret` | String | `7802f4e6f243e659d51135445fe******` | **必填**。应用的密钥，用于获取接口调用凭证。获取方式：- 小程序：通用参数- 移动网站应用：通用参数 |
| `grant_type` | String | `client_credential` | **必填**。固定值 `"client_credential"` |

## 请求示例

### Java

```java
import com.aliyun.tea.TeaException;
import com.douyin.openapi.client.Client;
import com.douyin.openapi.client.models.*;
import com.douyin.openapi.credential.models.Config;

public class Main {
    public static void main(String[] args) {
        try {
            // 配置 client_key 和 client_secret
            Config config = new Config().setClientKey("tt******").setClientSecret("cbs***"); 
            Client client = new Client(config);

            /* 
             * 构建请求参数说明：
             * token: 
             *   1. 若用户自行维护 token，将用户维护的 token 赋值给该参数即可
             *   2. SDK 包中有获取 token 的函数，请根据接口 path 在《OpenAPI SDK 总览》文档中查找获取 token 函数的名字
             *      (在使用过程中，请注意 token 互刷问题)
             * header:
             *   sdk 中默认填充 content-type 请求头，若不需要填充除 content-type 之外的请求头，删除该参数即可
             */
            
            OauthClientTokenRequest sdkRequest = new OauthClientTokenRequest();
            sdkRequest.setClientKey("dmcq1BNiRb");
            sdkRequest.setClientSecret("g2KvF6teqX");
            sdkRequest.setGrantType("LAq7Rw3LsX"); // 实际应为 "client_credential"，示例中为占位符
            
            OauthClientTokenResponse sdkResponse = client.OauthClientToken(sdkRequest);
            
            // 处理响应...
            
        } catch (TeaException e) {
            System.out.println(e.getMessage());
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }
}
```

## 响应参数

### 响应体 (Body)

| Key | 字段类型 | 示例 | 描述 |
| :--- | :--- | :--- | :--- |
| `data` | Struct | `-` | 数据主体 |
| └─ `access_token` | String | `clt.5a14a88ef6ebcdc4688224YC8dCJKLPZ******` | **client_token 接口调用凭证** |
| └─ `description` | String | `-` | 错误描述（成功时通常为空） |
| └─ `error_code` | Int64 | `-` | 错误码（0 表示成功） |
| └─ `expires_in` | Int64 | `86400` | **client_token 接口调用凭证超时时间**，单位（秒）*(注：实际有效时间通常为 7200 秒，具体以返回为准)* |
| `message` | String | `success` | 请求响应消息 |

## 响应示例

### 正常响应示例

```json
{
  "data": {
    "access_token": "clt.75c380db41e815978a733994d96f5d23RqilUxH48iobyWhbIOQFo******",
    "description": "",
    "error_code": 0,
    "expires_in": 7200
  },
  "message": "success"
}
```

### 异常响应示例
*(此处省略具体 JSON，请参考下方错误码表)*

## 错误码

| HTTP 状态码 | 错误码 | 错误码描述 | 排查建议 |
| :---: | :---: | :--- | :--- |
| 200 | `10002` | 参数错误 | 检查参数是否漏传或格式不正确 |
| 200 | `10003` | client_key 不存在 | 检查 `client_key` 参数是否正确，确认应用已创建 |
| 200 | `10013` | client_key 或者 client_secret 报错 | 检查 `client_key` 和 `client_secret` 是否匹配且正确 |