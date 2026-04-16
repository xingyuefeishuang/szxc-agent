# 订单服务编译校验 v01 - 实施计划

## 背景

本轮已经完成：

- 抖音 B10 商品识别收口到 `OrderProductFacadeService`
- 订单域 `spuId/skuId` 从 `Long` 调整为 `String`

这属于对象模型级改动，必须进行一次 `plt-order-service` 编译校验，确认没有类型不匹配和残留引用。

## 本次目标

1. 按仓库 `maven-compile` skill 执行编译
2. 只编译 `plt-order-service`
3. 定位并修复本轮改动引入的编译错误

## 实施步骤

1. 读取 `.agent/skills/maven-compile/SKILL.md`
2. 在 `plt-core-service/plt-order-service` 下按 skill 指定 JDK 17 + settings.xml 执行 Maven 编译
3. 如有报错，先修复当前改动导致的问题
4. 重新编译直至 `plt-order-api` 和 `plt-order-core` 通过

## 备注

预期可能存在环境级警告：
- Maven 本地仓库写权限不足

若只表现为 metadata tracking file 警告，但不阻断编译，可先记录，不作为本轮代码问题处理。
