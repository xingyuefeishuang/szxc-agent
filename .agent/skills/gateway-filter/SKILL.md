---
name: Gateway Filter Creation
description: 创建 plt-gateway 网关过滤器的标准步骤
---

# Gateway Filter Creation Skill

## 概述

本技能用于在 `plt-gateway` 项目中创建新的网关过滤器。过滤器采用 Spring Cloud Gateway 的 `GlobalFilter` 模式，并集成 Nacos 配置中心进行动态配置。

## 项目结构

```
plt-gateway/
├── plt-gateway-comm/          # 公共模块
│   └── src/main/java/cn/com/bsszxc/plt/gateway/
│       ├── enums/
│       │   ├── FilterOrderEnum.java      # 过滤器优先级枚举
│       │   └── NacosExtensionEnum.java   # Nacos 配置枚举
│       ├── filter/
│       │   ├── AbstractFilter.java       # 过滤器基类
│       │   └── properties/
│       │       └── AbstractFilterProperties.java  # 配置基类
│       └── listener/
│           └── AbstractNacosConfigListener.java   # Nacos 监听器基类
├── plt-boss-gateway/          # Boss 网关
├── plt-biz-gateway/           # Biz 网关  
└── plt-api-gateway/           # API 网关
```

## 创建过滤器步骤

### 1. 添加过滤器优先级枚举

**文件**: `plt-gateway-comm/.../enums/FilterOrderEnum.java`

```java
// 数值越小优先级越高
REQ_XXX(-450, "XXX过滤器"),
```

**现有优先级参考**:
- `-1000`: ORIG_REQ_LOGGING (原始请求日志)
- `-900`: REQ_FORBIDDEN (禁止请求)
- `-850`: REQ_ADD_HEADERS (添加请求头)
- `-800`: REQ_COOKIE_PARSE (Cookie 解析)
- `-700`: REQ_TENANT_PARSE (租户解析)
- `-430`: REQ_AUTH (认证鉴权)
- `-420`: REQ_DECRYPT (解密)
- `-410`: REQ_SIGN_VERIFY (签名验证)

### 2. 添加 Nacos 配置枚举

**文件**: `plt-gateway-comm/.../enums/NacosExtensionEnum.java`

```java
REQ_XXX("xxxFilter", "XXX过滤器"),
```

### 3. 创建过滤器配置类

**文件**: `plt-xxx-gateway/.../filter/properties/XxxFilterProperties.java`

```java
package cn.com.bsszxc.plt.gateway.filter.properties;

import lombok.Data;
import org.springframework.stereotype.Component;

@Data
@Component
public class XxxFilterProperties extends AbstractFilterProperties {
    // 自定义配置项
    private String customConfig;
}
```

### 4. 创建过滤器实现类

**文件**: `plt-xxx-gateway/.../filter/request/XxxRequestFilter.java`

```java
package cn.com.bsszxc.plt.gateway.filter.request;

import cn.com.bsszxc.plt.gateway.config.GatewayProperties;
import cn.com.bsszxc.plt.gateway.enums.FilterOrderEnum;
import cn.com.bsszxc.plt.gateway.filter.AbstractFilter;
import cn.com.bsszxc.plt.gateway.filter.properties.XxxFilterProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Slf4j
@Component
public class XxxRequestFilter extends AbstractFilter {

    public XxxRequestFilter(GatewayProperties gatewayProperties,
                            XxxFilterProperties xxxFilterProperties) {
        super(gatewayProperties, xxxFilterProperties);
    }

    @Override
    protected Mono<Void> doFilter(ServerWebExchange exchange, GatewayFilterChain chain) {
        log.info("'XXX'过滤器开始执行");
        // 过滤器逻辑
        return chain.filter(exchange);
    }

    @Override
    public int getOrder() {
        return FilterOrderEnum.REQ_XXX.getValue();
    }
}
```

### 5. 创建 Nacos 配置监听器

**文件**: `plt-xxx-gateway/.../listener/NacosXxxFilterListener.java`

```java
package cn.com.bsszxc.plt.gateway.listener;

import cn.com.bsszxc.plt.gateway.config.GatewayProperties;
import cn.com.bsszxc.plt.gateway.enums.NacosExtensionEnum;
import cn.com.bsszxc.plt.gateway.filter.properties.XxxFilterProperties;
import com.alibaba.cloud.nacos.NacosConfigManager;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;

@Slf4j
@Component
public class NacosXxxFilterListener extends AbstractNacosConfigListener<XxxFilterProperties> {

    protected NacosXxxFilterListener(XxxFilterProperties xxxFilterProperties,
                                     NacosConfigManager nacosConfigManager,
                                     GatewayProperties gatewayProperties) {
        super(xxxFilterProperties, nacosConfigManager, gatewayProperties);
    }

    @PostConstruct
    public void init() {
        log.info("xxx filter config init...");
        GatewayProperties.ExtensionConfig extensionConfig =
                gatewayProperties.getFilterConfig(NacosExtensionEnum.REQ_XXX);
        if (extensionConfig == null) {
            return;
        }
        String dataId = extensionConfig.getDataId();
        String group = extensionConfig.getGroup();
        initConfig(dataId, group, XxxFilterProperties.class);
        addNacosListener(dataId, group, XxxFilterProperties.class);
    }
}
```

## Nacos 配置示例

配置格式为 JSON：

```json
{
  "enable": true,
  "name": "xxx过滤器",
  "whitePath": [
    {"predicate": "STARTS_WITH", "url": "/public/"}
  ],
  "whiteMediaType": [],
  "whiteHeaders": [],
  "customConfig": "value"
}
```

## 关键类说明

### AbstractFilter

提供通用功能：
- OPTIONS 请求自动跳过
- `enable` 开关控制
- 白名单路径/MediaType/Headers 自动跳过
- `isMatchCustomSkipRule()` 自定义跳过规则

### AbstractFilterProperties

基础配置字段：
- `enable`: 是否启用
- `name`: 过滤器名称
- `order`: 排序（一般不用，使用枚举）
- `whitePath`: 路径白名单
- `whiteMediaType`: MediaType 白名单
- `whiteHeaders`: 请求头白名单

## 参考文件

- 过滤器示例: `plt-gateway-comm/.../filter/request/AddHeadersRequestFilter.java`
- 配置类示例: `plt-gateway-comm/.../filter/properties/AddHeadersRequestFilterProps.java`
- 监听器示例: `plt-boss-gateway/.../listener/NacosAuthFilterListener.java`
