---
name: Standard CRUD Generator
description: 在本项目中根据 CREATE TABLE 或现有表结构，为指定业务模块生成符合项目规范的标准 CRUD 骨架，并在生成前校验模块风格、基础类继承、时间类型和对象模型约束。
---

# Standard CRUD Generator

本技能用于在当前仓库中生成符合既有风格的标准 CRUD 代码。

适用场景：

- 新增实体
- 根据建表语句生成标准骨架
- 为现有业务域补齐 `Entity/BO/DO/Api/Controller/Service/Mapper`

不适用场景：

- 复杂聚合查询
- 跨模块编排逻辑
- 明显偏离标准 CRUD 模式的业务接口

## 1. 生成前必须读取

先按顺序读取：

1. `AGENTS.md`
2. `.agent/architecture/AI_QUICKSTART.md`
3. `.agent/rules/AI_BEHAVIOR_RULES.md`
4. `.agent/architecture/PROJECT_STRUCTURE.md`
5. `.agent/architecture/CODE_GENERATION_GUIDE.md`

然后补充读取：

- 目标业务域下最近的真实实现
- 对应业务域的 `requirements/`、`designs/`、`references/`，若存在

## 2. 生成原则

- 优先对齐同模块最近真实实现，不要机械照抄模板
- 若模板与真实代码冲突，以真实代码为准
- 若真实代码不足，再回退到 `PROJECT_STRUCTURE.md`
- 最后才参考 `CODE_GENERATION_GUIDE.md`

优先级：

`现有模块事实 > PROJECT_STRUCTURE.md > CODE_GENERATION_GUIDE.md`

## 3. 生成前检查清单

开始生成前，必须确认：

- 目标模块路径是否正确
- 当前业务域是否采用 `*-api + *-core` 拆分
- 包名是否符合 `cn.com.bsszxc.plt.{moduleName}` 规范
- 基类是否已经提供 `createTime`、`modifyTime`、`tenantId`
- 当前模块使用的是 `Date` 还是 `LocalDateTime`
- 主键策略是否沿用模块现状
- 返回对象中的 `Long` 字段是否需要 `ToStringSerializer`
- `QueryDO` 是否需要继承 `PageReq`

## 4. 标准输出文件

默认生成以下文件：

- `Entity`
- `BO`
- `AddDO`
- `UpdateDO`
- `QueryDO`
- `Api`
- `Controller`
- `Service`
- `ServiceImpl`
- `Mapper`
- `Mapper.xml`

若模块现状没有使用其中某类文件，按模块事实调整，不强行补齐。

## 5. 关键约束

- `Entity` 默认继承 `TenantSuperModel`
- 不要重复声明基类已有通用字段
- `QueryDO` 标准分页场景必须继承 `PageReq`
- `BO` 中 `Long` 字段通常要做字符串序列化
- 时间字段格式默认对齐现有模块
- 删除逻辑默认检查 `deleted` 字段和 `@TableLogic`

## 6. 典型工作流

1. 定位目标模块和业务域
2. 查找最近的相似实体或 CRUD 实现
3. 对照建表语句或字段定义，确认字段类型映射
4. 生成 API 层对象和接口
5. 生成 core 层实体、Mapper、Service、Controller
6. 检查导包、继承、注解、分页和序列化规则
7. 如环境允许，执行最小编译或至少做静态自检

## 7. 结果自检

生成完成后至少检查：

- 文件落点是否正确
- 包名和类名是否一致
- 接口路径是否符合模块现状
- `Service` / `ServiceImpl` 泛型是否正确
- 查询条件构造是否遗漏常见字段
- 是否误生成了基类已有字段
- 是否误用了模板中的占位包路径或示例名

## 8. 需要输入的信息

优先输入：

- `CREATE TABLE` 语句
- 所属模块
- 业务域名称
- 期望类名

若用户未提供完整信息，则先从现有模块结构和相邻实现中推断，再最小化补问。
