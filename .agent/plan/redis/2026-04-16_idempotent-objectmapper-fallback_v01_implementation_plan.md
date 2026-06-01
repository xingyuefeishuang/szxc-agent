# 实施计划：为 Idempotent 组件补充 ObjectMapper 自动配置兜底

## 任务信息

- 模块：`redis`
- 日期：`2026-04-16`
- featureKey：`idempotent-objectmapper-fallback`
- 类型：`implementation_plan`

## 目标

消除 `plt-framework-redis-starter` 中 `IdempotentAspect` 对宿主应用必须提供 `ObjectMapper` Bean 的隐式依赖。

## 实施步骤

1. 在 `IdempotentAutoConfiguration` 中增加 `ObjectMapper` 默认 Bean。
2. 使用 `@ConditionalOnMissingBean(ObjectMapper.class)`，保证：
   - 宿主应用已有 `ObjectMapper` 时优先复用
   - 宿主应用没有时 starter 自己提供默认实例
3. 默认实例使用 `new ObjectMapper().findAndRegisterModules()`，尽量兼容常见时间类型和 Jackson 模块。
4. 保持 `IdempotentAspect` 的注入方式不变，只补自动配置兜底。

## 验证目标

- 自动配置语义清晰
- 不破坏已有宿主应用的 `ObjectMapper` 配置优先级
- 无需修改业务侧使用方式
