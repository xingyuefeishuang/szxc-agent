# 实施计划：优化 Idempotent 幂等组件

## 任务信息

- 模块：`redis`
- 日期：`2026-04-16`
- featureKey：`idempotent-component-fix`
- 类型：`implementation_plan`

## 目标

修复 `plt-framework-redis-starter` 下 `Idempotent` 组件的关键正确性问题，使其满足以下要求：

- 成功执行业务后，即使缓存结果写回失败，也不能放开重复执行
- `CUSTOM fallback` 必须走 Spring Bean，且按“一方法一 fallback”约束使用
- 统一复用 Spring 管理的 `ObjectMapper`
- 对幂等 key 和 fallback 返回值进行运行时校验

## 实施步骤

1. 修改 `IdempotentAspect`
   - 注入 `ObjectMapper`
   - 注入 `ApplicationContext`
   - 分离“业务执行失败”和“结果缓存失败”的处理逻辑
2. 修改 `CUSTOM fallback` 获取方式
   - 从 Spring 容器取 Bean
   - 缺失 Bean 时抛清晰异常
3. 补充保护逻辑
   - `prefix/key` 非空校验
   - fallback 返回值与目标方法返回类型兼容性校验
   - Redis 中幂等记录反序列化失败时抛清晰异常
4. 修改自动配置
   - 注册默认 fallback Bean
   - 组装新的 `IdempotentAspect` 构造参数
5. 做源码级核对与模块编译尝试

## 验证目标

- 切面流程无语义回退
- 自动配置可正确装配新的依赖
- 编译若失败，需要明确区分代码问题与本地环境问题
