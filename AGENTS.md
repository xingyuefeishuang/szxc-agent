/# 代码库与AI代理指南 (Repository & Agent Guidelines)

> 本文件是 AI 了解本项目的**唯一全局入口**。请在执行任何具体任务前，仔细阅读以下关联文档。

## 📍 必读核心规范 (Required Docs)

请根据你当前的任务性质，务必先阅读对应的“单一事实来源”文档。详细的规则已统一分装到 `.agent/` 目录下，以避免本文件过度臃肿：

- **快速建立项目全局认知（低 token 入口）**：  
  👉 阅读 `d:\08-Work\01-博思\10-平台2.0\.agent\architecture\AI_QUICKSTART.md`：用于让 AI 先快速了解项目结构、对象模型、分层约束和最小阅读路径。
- **了解项目架构、技术栈与对象模型**：  
  👉 阅读 `d:\08-Work\01-博思\10-平台2.0\.agent\architecture\PROJECT_STRUCTURE.md`：用于了解模块布局、技术栈和对象模型规范。
- **避免乱码及遵循 AI 行为红线**：  
  👉 阅读 `d:\08-Work\01-博思\10-平台2.0\.agent\rules\AI_BEHAVIOR_RULES.md`
- **代码生成与基础包命名规范**：  
  👉 如果你接到了编写新模块或新实体的任务，请先阅读 `d:\08-Work\01-博思\10-平台2.0\.agent\architecture\CODE_GENERATION_GUIDE.md`
- **第三方参考资料 (接口文档、协议等)**：  
  👉 阅读 `.agent/references/` 下对应业务模块的文件。
- **业务需求文档 (PRD、任务诉求)**：  
  👉 阅读 `.agent/requirements/` 下对应业务模块的文件。
- **技术设计方案 (重构或新功能实施前的技术分析)**：  
  👉 阅读 `.agent/designs/` 下对应业务模块的文件。
- **AI 执行与复盘存档 (计划与总结)**：  
  👉 阅读 `.agent/plan/` 下对应业务模块的文件。
- **其他自动化技能或工作流 (可选)**：  
  👉 如果你需要特定的脚本指令或标准开发流程跑命令，去查看 `.agent/skills/` 或 `.agent/workflows/` 下的工作指南。

## 🧭 任务与必读文档映射 (Task-to-Docs Mapping)

为避免“读太多”或“读漏了”，请至少遵循以下最小读取规则：

| 任务类型 | 至少必读 |
|------|------|
| 修复 Bug / 排查异常 | `AGENTS.md`、`.agent/architecture/PROJECT_STRUCTURE.md`、`.agent/rules/AI_BEHAVIOR_RULES.md`，以及对应业务目录下的 `requirements/`、`designs/`、`references/`（如存在） |
| 实现新功能 | `AGENTS.md`、`.agent/architecture/PROJECT_STRUCTURE.md`、`.agent/rules/AI_BEHAVIOR_RULES.md`、对应业务目录下的 `requirements/`、`designs/`、`references/` |
| 新增模块 / 新增实体 / 批量生成 CRUD | 上述文档 + `.agent/architecture/CODE_GENERATION_GUIDE.md` |
| 纯分析 / 评审 / 方案讨论 | `AGENTS.md`、`.agent/architecture/PROJECT_STRUCTURE.md`、`.agent/rules/AI_BEHAVIOR_RULES.md`，并按话题补充读取相关 `designs/` 或 `references/` |

---

**ℹ️ 提示给后续的 AI 助手（防目录腐烂）:**
- **严密遵守领域驱动（Domain-driven）**：`.agent/architecture/`、`requirements/`、`references/`、`designs/` 允许同时存在“全局文档”和“业务文档”两层结构。  
  全局文档可放在对应目录根部；业务文档在新增时，**必须**放入特定业务领域子目录（例如 `/msg/`、`/auth/`）下，避免继续堆在根目录。
- **关于环境技能 (Skills & Workflows)**：如果增加新的通用自动化指令、编译脚本或特定的复杂重构流水线，请在 `.agent/skills/` 或 `.agent/workflows/` 下为其单独创建带有 `SKILL.md` 的技能包目录。
- **严禁**在本文件（`AGENTS.md`）中再次追加大段的项目细节描述（如目录树、配置说明等）。
- 发现新的**全局防坑指南**，请将其追加到 `.agent/rules/AI_BEHAVIOR_RULES.md` 文件中。
- **发现新的架构约束**，请将其追加到 `.agent/architecture/` 目录下对应的文件中。

**🤖 强迫自我进化 (Auto-Learning):**
在完成任务后，如满足以下任一条件，**你必须主动询问人类是否需要将经验沉淀下来**：
- 修复了非显然的环境/配置/编码问题，后续 AI 或开发者很可能再次踩坑；
- 纠正了 AI 之前对业务逻辑、对象模型或架构边界的错误理解；
- 形成了可复用的排查流程、脚本、命令序列或工作流；
- 引入了新的跨模块设计约束、技术方案或目录约定。

在获得人类允许后，执行以下操作：
1. 遇到报错/踩坑经验：更新到 `.agent/rules/AI_BEHAVIOR_RULES.md` 的避坑指南中。
2. 产生了新的技术设计方案：归档到 `.agent/designs/` 对应业务目录下。
3. 创造了可复用的脚本或操作流程：提炼成 `.agent/skills/` 的技能包说明书。

**补充硬性归档规则：**
每次任务完成后，AI 必须将本次任务的实施计划（`implementation_plan`）和工作总结（`walkthrough`）自动保存到 `.agent/plan/{业务模块名}/` 目录下（按功能模块分组存放），无需向人类确认即可自动执行此存档动作。
## Plan Archive Naming (Required Entry)

- For any task that writes to `.agent/plan/{module}/`, AI MUST read:
  - `d:\08-Work\01-博思\10-平台2.0\.agent\rules\PLAN_ARCHIVE_NAMING_STANDARD.md`
