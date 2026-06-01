# 工作总结：补齐 Idempotent AOP 运行时依赖

## 结果

已修复 `plt-order-core` 中 `@Idempotent` 不生效的基础设施问题。

本次修改文件：

- `plt-framework/plt-framework-redis-starter/pom.xml`

## 核心结论

问题根因不在 `plt-order-core` 业务代码，而在 `plt-framework-redis-starter` 的依赖声明。

starter 里虽然已经存在：

- `IdempotentAspect`
- `DistributedLockAspect`
- 对应的自动配置 `IdempotentAutoConfiguration` / `DistributedLockAutoConfiguration`

但 `pom.xml` 仅保留了 `aspectjrt`，没有把 `spring-boot-starter-aop` 带入宿主应用。这样在只依赖该 starter 的业务模块里，Spring AOP 代理可能不会启用，最终表现为：

- `@Idempotent` 注解不进入切面
- 方法按原逻辑直接执行
- Redis 幂等键、处理中策略、fallback 都不会触发

## 具体修改

在 `plt-framework-redis-starter` 中：

- 新增 `org.springframework.boot:spring-boot-starter-aop`
- 移除原有 `org.aspectj:aspectjrt` `provided` 依赖

这样由 Spring Boot 统一带入 AOP 所需运行时依赖，避免宿主模块额外感知和手工补依赖。

## 验证

已在目录 `plt-framework/plt-framework-redis-starter` 执行：

```powershell
$env:JAVA_HOME = "D:\05-Development\jdk-17"
mvn compile -DskipTests
```

结果：`BUILD SUCCESS`

## 影响说明

- `plt-order-core` 中的 `@Idempotent` 将能进入切面代理。
- 同 starter 内的 `@DistributedLock` 也会共享这次 AOP 运行时补齐收益。
- 本次没有改动 `IdempotentAspect` 逻辑，也没有改动 `plt-order-core` 业务实现。
