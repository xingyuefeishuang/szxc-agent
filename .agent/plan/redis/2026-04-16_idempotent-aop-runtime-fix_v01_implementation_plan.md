# 实施计划：补齐 Idempotent AOP 运行时依赖

## 归档信息

- 日期：2026-04-16
- 模块：`redis`
- featureKey：`idempotent-aop-runtime-fix`
- 版本：`v01`

## 问题背景

`plt-order-core` 中已经使用了 `@Idempotent`，且 `plt-framework-redis-starter` 也提供了 `IdempotentAspect` 自动配置。

但当前 starter 的 `pom.xml` 只声明了 `aspectjrt`，没有引入 Spring Boot AOP starter，因此像 `plt-order-core` 这类仅依赖 `plt-framework-web-starter` 和 `plt-framework-redis-starter` 的模块，运行时可能根本没有启用 Spring AOP 代理，导致 `@Idempotent` 只是普通注解，不会进入切面。

## 实施目标

1. 补齐 `plt-framework-redis-starter` 的 AOP 运行时依赖。
2. 保持 `IdempotentAspect`、`DistributedLockAspect` 现有代码与自动配置不变。
3. 通过最小编译验证确认 starter 构建通过。

## 实施步骤

1. 修改 `plt-framework/plt-framework-redis-starter/pom.xml`
   - 新增 `org.springframework.boot:spring-boot-starter-aop`
   - 移除冗余的 `org.aspectj:aspectjrt` `provided` 依赖
2. 在 `plt-framework/plt-framework-redis-starter` 目录执行 `mvn compile -DskipTests`
3. 记录影响范围与验证结果

## 风险与说明

- 本次修复属于基础设施依赖补齐，影响的是 starter 内所有基于 Spring AOP 的注解能力，不仅限于 `@Idempotent`。
- 若宿主工程显式关闭了 AOP 自动配置，则仍需宿主侧单独处理；当前仓库内未见此类关闭配置。
