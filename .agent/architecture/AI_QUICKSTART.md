# AI Quickstart

> 面向 AI 的低 token 项目速读入口。用于在进入具体任务前，快速建立稳定的全局认知。

## 1. 先读什么

按任务类型最小化读取：

- 日常修 Bug / 查问题：`AGENTS.md` + `PROJECT_STRUCTURE.md` + `AI_BEHAVIOR_RULES.md`
- 新增功能：在上面基础上，补读对应业务域的 `requirements/`、`designs/`、`references/`
- 新增实体 / 批量 CRUD / 代码生成：再补读 `CODE_GENERATION_GUIDE.md`

原则：

- 不要每次都全文重读所有 `.agent` 文档
- 先建立全局摘要，再按业务域增量读取
- 若模板与现有模块代码冲突，以现有模块事实为准

## 2. 项目是什么

- 本项目是基于 `Spring Cloud` 的微服务平台
- 核心技术栈：`JDK 17`、`Spring Boot 2.6.13`、`Spring Cloud 2021.0.5`、`MyBatis Plus 3.4.0`、`Redis`、`Nacos`、`Gateway`、`XXL-JOB`、`Seata`
- Maven 坐标：`cn.com.bsszxc:plt-project:2.0.0-SNAPSHOT`
- 统一编码：`UTF-8`

## 3. 仓库结构

主要模块包括：

- `plt-commons`
- `plt-framework`
- `plt-core-service`
- `plt-gateway`
- `plt-auth-service`
- `plt-comm-service`
- `plt-opr-service`
- `plt-mobile-service`
- `plt-workflow-service`
- `plt-open-service`
- `ind-opr-service`

其中：

- `plt-core-service` 内部通常按业务域拆成 `*-api` + `*-core`
- 新增业务域时，应沿用相同拆分模式，并在启动/聚合层完成装配

## 4. 文档分层约定

- `.agent/architecture/`：全局架构事实和跨模块规范
- `.agent/architecture/{业务域}/`：业务域专属架构约束
- `.agent/requirements/`：业务需求
- `.agent/designs/`：技术设计方案
- `.agent/references/`：第三方接口、协议、参考资料
- `.agent/plan/`：AI 任务实施计划（implementation_plan）和完成总结（walkthrough）的专属存档目录

新增文档时，优先放到对应业务子目录，不要把所有内容继续堆在根目录。

## 5. 对象模型

项目常见对象：

- `Entity`：数据库实体，对应表，位于 `db/model`
- `BO`：接口返回对象
- `AddDO`：新增请求对象
- `UpdateDO`：更新请求对象
- `QueryDO`：查询请求对象，标准分页场景必须继承 `PageReq`
- `DTO` / `VO`：特殊场景对象，不一定直连数据库

典型流转：

`AddDO/UpdateDO/QueryDO -> Controller -> Service -> Mapper -> Entity -> BO`

## 6. 继承与分层

默认继承链：

- `Entity -> TenantSuperModel -> SuperModel -> Model`
- `Mapper -> SuperMapper`
- `Service -> IBaseService`
- `ServiceImpl -> BaseServiceImpl`
- `Controller -> implements Api`

默认分层：

- `api` 层：Feign 接口 + POJO
- `core` 层：Controller / Service / Mapper / Entity

## 7. 写代码时最容易踩错的点

- `Entity` 默认不要重复声明基类已提供的通用字段，如 `createTime`、`modifyTime`、`tenantId`
- 主键默认优先参考现有模块；全局规范示例更偏向 `IdType.ASSIGN_ID`
- `BO` 中 `Long` 字段通常需要 `@JsonSerialize(using = ToStringSerializer.class)`
- 时间字段通常使用 `@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")`
- `QueryDO` 必须继承 `PageReq`
- 新代码生成前，先看同模块最近真实实现，不要只照模板
- **Controller 接口严禁返回 `ResultBody` 等响应包装类**，请直接返回业务实体（如 `String`、`boolean` 或 BO 类），API 网关会统一包装，自行包装会导致反序列化报错。

## 8. 代码生成指南怎么用

`CODE_GENERATION_GUIDE.md` 适用于：

- 根据 `CREATE TABLE` 生成实体和标准 CRUD
- 新增模块中的标准数据对象和接口骨架

生成前必须先核对：

- 同模块最近真实代码风格
- `PROJECT_STRUCTURE.md` 中的对象模型和基础类约束
- 基类是否已经提供公共字段
- 当前模块时间类型到底使用 `Date` 还是 `LocalDateTime`

优先级：

`现有模块事实 > PROJECT_STRUCTURE.md > CODE_GENERATION_GUIDE.md`

## 9. Windows 编码规则

- 项目统一使用 `UTF-8`
- 修改或创建中文文件时，禁止使用 PowerShell 重定向直接写内容
- 优先使用结构化编辑工具
- 若必须通过 PowerShell 写文本，必须显式指定 `-Encoding UTF8`

## 10. 给 AI 的工作建议

- 先用本文件建立全局认知
- 再根据任务进入对应业务域文档
- 需要生成代码时再读 `CODE_GENERATION_GUIDE.md`
- 遇到模板与真实代码不一致时，停止套模板，回到模块现有实现核对

## 11. 常用 Skills

若任务属于固定工作流，可优先查看 `.agent/skills/` 下对应技能包：

高频skill如下：
- `standard-crud-generator`：根据表结构或现有实体，为指定业务模块生成标准 CRUD 骨架
- `bug-triage`：对报错、异常和行为回归做标准化排查
- `maven-compile`：按项目既定环境执行 Maven 编译
- `utf8-console`：处理 Windows 控制台或终端相关编码问题

原则：

- 只有在任务明显匹配固定流程时再进入对应 skill
- skill 是工作流入口，不是全局架构事实来源
- 若 skill 与真实模块代码冲突，仍以真实代码为准
