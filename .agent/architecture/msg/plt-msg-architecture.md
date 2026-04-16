# plt-msg 模块架构文档

## 模块概述

plt-msg 是平台核心服务（plt-core-service）中的消息模块，负责统一消息发送功能，包括：
- 统一待办接口
- 统一消息接口（短信、站内信、小程序、公众号消息）

## 模块结构

```
plt-msg-service/
├── plt-msg-api/          # API 层：接口定义、常量、枚举
│   └── src/main/java/cn/com/bsszxc/plt/msg/
│       ├── constant/     # 常量定义（MsgConstant）
│       └── ...
└── plt-msg-core/         # Core 层：业务逻辑实现
    └── src/main/java/cn/com/bsszxc/plt/msg/
        ├── config/       # 配置类（SmsProperties）
        ├── db/model/     # 数据模型
        ├── handler/      # 处理器（模板转换、参数填充）
        ├── pojo/         # 数据传输对象
        ├── service/      # 服务层
        └── ...
```

## 核心数据模型

### 1. MsgChannel（消息通道）
- `channelId`: 通道ID
- `channelName`: 通道名称
- `channelCode`: 通道编码
- `channelParam`: 连接通道所需参数（JSON格式）
- `channelType`: 通道类型（短信、邮件、公众号等）
- `protocolType`: 协议类型（腾讯云短信、阿里云短信、CMPP等）
- `appId`: 来源应用ID

### 2. MsgTemplate（消息模板）
- `templateId`: 模板ID
- `templateName`: 模板名称
- `templateCode`: 模板编码
- `templateTitle`: 消息标题
- `templateContent`: 消息内容（统一格式）
- `paramsTemplate`: 参数模板（用于填充第三方通道参数）
- `channelId`: 适用通道
- `thirdTemplateId`: 第三方模板ID
- `extendAttr`: 可扩展属性（JSON）

### 3. Msg（消息）
- `msgId`: 消息ID
- `msgTitle`: 消息标题
- `msgContent`: 消息内容
- `contentFillParam`: 内容填充参数（JSON）
- `templateId`: 消息模板ID
- `channelId`: 推送通道
- `pushStatus`: 推送状态

### 4. MsgInst（消息实例）
- `msgInstId`: 消息实例ID
- `msgId`: 消息ID
- `receiveObj`: 接收对象
- `receiveObjType`: 接收对象类型（用户、村民等）
- `receiveAddr`: 接收地址（手机号、邮箱等）
- `pushStatus`: 推送状态
- `pushResult`: 推送结果

## 核心设计模式

### 1. 通道处理器抽象（Strategy Pattern）

**抽象基类**: `MsgChannelHandlerService`

```java
public abstract class MsgChannelHandlerService {
    // 填充接收地址（如查询用户手机号）
    protected abstract void fillReceiverAddress(String channelParams, List<MsgInst> msgInstList);
    
    // 发送消息并填充最终状态
    protected abstract void sendMsgAndFillFinalStatus(MsgChannel msgChannel, Msg msg, 
                                                      MsgTemplate msgTemplate, List<MsgInst> msgInstList);
    
    // 通道匹配判断
    public abstract boolean match(MsgChannel msgChannel);
    
    // 检查通道配置
    protected abstract void checkChannel(String channelParams) throws ChannelCallException;
}
```

**已实现的通道**:
- `TencentSmsChannelServiceImpl`: 腾讯云短信
- `AliYunSmsChannelServiceImpl`: 阿里云短信
- `InsideStationMailChannelServiceImpl`: 站内信
- `WechatProgramChannelServiceImpl`: 微信小程序
- `WechatOfficialAccountChannelServiceImpl`: 微信公众号
- `CmppSmsChannelServiceImpl`: CMPP 短信协议

### 2. 通道路由管理

**管理服务**: `ChannelHandlerMangeServiceImpl`

```java
@Service
public class ChannelHandlerMangeServiceImpl implements ChannelHandlerMangeService {
    @Resource
    private List<MsgChannelHandlerService> msgChannelHandlerServices;
    
    @Override
    public MsgChannelHandlerService getMsgChannelHandlerService(MsgChannel msgChannel) {
        // 通过 match() 方法找到匹配的通道处理器
        return msgChannelHandlerServices.stream()
            .filter(x -> x.match(msgChannel))
            .findFirst()
            .orElse(null);
    }
}
```

### 3. 模板转换机制（Enum Singleton Pattern）

**枚举类**: `TemplateTranslateHandlerEnum`

支持统一模板与各通道模板格式的双向转换：

| 转换器 | 说明 | 占位符格式 |
|--------|------|-----------|
| UNIFY_2_TENCENT_SMS | 统一 → 腾讯云短信 | `{{name}}` → `{1}` |
| UNIFY_2_TENCENT_SMS2 | 统一 → 腾讯云短信（保留名称） | `{{name}}` → `{name}` |
| TENCENT_SMS_2_UNIFY | 腾讯云短信 → 统一 | `{name}` → `{{name}}` |
| UNIFY_2_ALIYUN_SMS | 统一 → 阿里云短信 | `{{name}}` → `${name}` |
| ALIYUN_SMS_2_UNIFY | 阿里云短信 → 统一 | `${name}` → `{{name}}` |
| UNIFY_2_WECHAT_PROGRAM | 统一 → 微信小程序 | `{{name}}` → `{{name.DATA}}` |
| WECHAT_PROGRAM_2_UNIFY | 微信小程序 → 统一 | `{{name.DATA}}` → `{{name}}` |

**统一模板占位符格式**: `{{变量名}}` 或 `{{变量名:默认值}}`

### 4. 参数模板生成（Enum Singleton Pattern）

**枚举类**: `ParamsTemplateGeneratorEnum`

根据模板内容生成参数模板：

| 生成器 | 输入模板 | 输出参数模板 |
|--------|---------|-------------|
| TENCENT_SMS | `您的验证码是{code}` | `["{{code}}"]` |
| ALIYUN_SMS | `您的验证码是${code}` | `{"code":"{{code}}"}` |
| WECHAT_PROGRAM | `验证码{{code.DATA}}` | `{"code":{"value":"{{code}}"}}` |
| UNIFY | `您的验证码是{{code}}` | `{"code":"{{code}}"}` |

### 5. 模板参数填充

**枚举类**: `TemplateFillHandlerEnum`

```java
UNIFY.getInstance().fill(paramsTemplate, fillParams)
```

支持：
- 字符串模板填充
- JSON 对象模板填充
- JSON 数组模板填充

## 消息发送流程

```
1. 业务层调用发送消息接口
   ↓
2. 创建 Msg 记录（消息）
   ↓
3. 创建 MsgInst 记录（消息实例，每个接收者一条）
   ↓
4. 根据 channelId 查询 MsgChannel（通道配置）
   ↓
5. ChannelHandlerMangeService 路由到对应的通道处理器
   ↓
6. 通道处理器执行：
   a. fillReceiverAddress()：填充接收地址（如查询用户手机号）
   b. 查询 MsgTemplate（消息模板）
   c. 模板参数填充：TemplateFillHandler.fill()
   d. sendMsgAndFillFinalStatus()：调用下游接口发送
   ↓
7. 更新 MsgInst 推送状态
   ↓
8. 更新 Msg 推送状态
```

## 通道配置示例

### 腾讯云短信配置（TencentSmsChannelConfig）
```json
{
  "secretId": "AKIDxxxx",
  "secretKey": "xxxxxx",
  "sdkAppId": "1400515089",
  "sign": "博思数村"
}
```

### 阿里云短信配置（AliYunSmsChannelConfig）
```json
{
  "accessKey": "LTAIxxxx",
  "accessSecret": "xxxxxx",
  "signName": "博思数村"
}
```

## 扩展新通道的步骤

### 1. 创建通道配置类
```java
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class XxxSmsChannelConfig {
    private String userName;
    private String password;
    // ... 其他配置
}
```

### 2. 实现通道处理器
```java
@Service
@Slf4j
@Transactional(rollbackFor = Exception.class)
public class XxxSmsChannelServiceImpl extends MsgChannelHandlerService 
    implements TemplatePushService, TemplateEditService, ... {
    
    @Override
    public boolean match(MsgChannel msgChannel) {
        // 判断是否匹配此通道（通过 protocolType）
        return MsgProtocolTypeEnum.XXX_SMS.getCode().equals(msgChannel.getProtocolType());
    }
    
    @Override
    protected void checkChannel(String channelParams) throws ChannelCallException {
        // 验证通道配置是否正确
    }
    
    @Override
    protected void fillReceiverAddress(String channelParams, List<MsgInst> msgInstList) {
        // 填充接收地址（查询用户手机号）
    }
    
    @Override
    protected void sendMsgAndFillFinalStatus(MsgChannel msgChannel, Msg msg, 
                                            MsgTemplate msgTemplate, List<MsgInst> msgInstList) {
        // 调用下游接口发送短信
        // 填充 msgInst 的 pushStatus、pushResult、pushEndTime
    }
}
```

### 3. 添加模板转换器（如需要）
在 `TemplateTranslateHandlerEnum` 中添加：
```java
UNIFY_2_XXX_SMS(new Unify2XxxSmsTemplateHandler()),
XXX_SMS_2_UNIFY(new XxxSms2UnifyTemplateHandler()),
```

### 4. 添加参数模板生成器（如需要）
在 `ParamsTemplateGeneratorEnum` 中添加：
```java
XXX_SMS(new XxxSmsParamsTemplateGenerator()),
```

### 5. 添加协议类型枚举
在 `MsgProtocolTypeEnum` 中添加：
```java
XXX_SMS("XXX_SMS", "XXX短信平台"),
```

### 6. 添加常量定义
在 `MsgConstant` 中添加占位符正则表达式（如需要）：
```java
public static final String XXX_SMS_PLACEHOLDER_MATCH_REGEX = "...";
public static final String XXX_SMS_PLACEHOLDER_REPLACEMENT = "...";
```

## 关键接口说明

### TemplatePushService
模板推送服务接口，实现此接口表示支持通过模板发送消息。

### TemplateEditService
模板编辑服务接口，实现此接口表示支持在第三方平台创建/修改模板。

### TemplateParamsFillService
模板参数填充服务接口，实现此接口表示支持参数化模板。

### TemplateStatusService
模板状态服务接口，实现此接口表示支持查询第三方平台模板状态。

### TemplateDeleteService
模板删除服务接口，实现此接口表示支持删除第三方平台模板。

### TemplatePullService
模板拉取服务接口，实现此接口表示支持从第三方平台拉取模板列表。

### MsgInstStatusService
消息实例状态服务接口，实现此接口表示支持查询消息发送状态（回执）。

## 配置文件

### application.yml
```yaml
sms:
  enabled: false  # 短信发送功能开关（默认关闭，因为收费）
  type: tencent   # 短信机类型（tencent/alibaba/yunxin）
  code:
    value: "123456"  # 关闭时默认验证码
    timeout: 300     # 验证码超时时间（秒）
    smsSendNum: 3    # 一分钟内发送次数限制
    smsCheckNum: 5   # 连续错误次数限制
```

## 注意事项

1. **异步发送**: 消息发送使用 `@Async` 异步执行，线程池为 `msgThreadPoolExecutor`
2. **批量限制**: 不同通道有不同的批量发送限制（腾讯200个，阿里100个）
3. **租户隔离**: 所有数据模型继承 `TenantSuperModel`，支持多租户
4. **状态管理**: 消息和消息实例有独立的推送状态管理
5. **错误处理**: 通道调用异常通过 `ChannelCallException` 统一处理
6. **扩展属性**: 模板和消息都支持 `extendAttr` 字段存储 JSON 扩展信息

## 测试建议

1. 单元测试：测试模板转换、参数填充逻辑
2. 集成测试：测试通道配置验证、消息发送流程
3. 压力测试：测试批量发送性能和并发处理能力
