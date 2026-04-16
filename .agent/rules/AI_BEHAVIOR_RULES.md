# AI Agent 行为准则 (Behavior Rules)

> 本文档定义了所有协助本项目的 AI 必须严格遵守的底层行为规范。

## 1. 编码与防乱码规则 (Encoding Rules)

由于大部分 AI 生成工具在 Windows 环境下调用 Shell 脚本时，会默认使用系统本地编码（如 GBK 或 UTF-16），这会导致严重的中文字符乱码问题。因此，所有 AI 必须**绝对死守**以下原则：

- **强制原生存取**：在写入、修改或创建包含中文字符的文件时，**禁止**通过终端执行 `echo "内容" > file.md` 或 `Out-File` 等重定向指令。
- **必须使用结构化编辑工具**：请始终优先使用当前运行环境提供的结构化文件编辑工具来修改文件内容，而不是依赖 Shell 重定向。常见示例包括 `apply_patch`、`edit_file`、`write_to_file`、`replace_file_content` 等。
- **Shell 备用方案（不推荐）**：如果极特殊情况下（如编写自动化构建脚本）必须使用 PowerShell 写入文本，**必须**显式追加编码参数，例如：`-Encoding UTF8`，并确认不会引入 BOM、控制台转码或重定向乱码。
- **禁止向源码文件写入 BOM**：`.java`、`.xml`、`.yml`、`.properties`、`.md` 等文本文件统一使用 **UTF-8 无 BOM**。在 Windows 下即使指定 `UTF-8`，部分写入方式仍可能写出 `EF BB BF` 文件头，导致 Jenkins / Maven / javac 出现 `illegal character: '\\ufeff'`。修改源码文件后，如怀疑编码异常，应优先检查文件头字节并移除 BOM。

## 2. 交互准则 (Interaction Guidelines)

- **保持简洁**：在修改代码或提交成果时，不要大段重复未修改的代码。
- **不要破坏现有结构**：遵照 `PROJECT_STRUCTURE.md` 和各模块的已有设计，不要自行引入新的代码风格。

## 3. 上下文读取策略 (Context Loading Strategy)

- **优先低 token 入口**：AI 在首次进入仓库或开启新任务时，应优先阅读 `.agent/architecture/AI_QUICKSTART.md`，先建立项目全局认知，再按任务类型增量读取其他文档。
- **避免全文重复灌入**：除非任务确实需要，不要在每次任务中重复全文读取 `PROJECT_STRUCTURE.md`、`CODE_GENERATION_GUIDE.md` 及其他大型文档。
- **按任务逐层深入**：修 Bug 优先补充读取架构与行为规范；新增功能再读取对应业务域的 `requirements/`、`designs/`、`references/`；新增实体或标准 CRUD 时再读取 `CODE_GENERATION_GUIDE.md`。
- **以真实代码为准**：若摘要文档、模板文档与模块现有实现不一致，应回到真实代码和对应业务设计文档核对，不得机械套用模板。

## 4. 产物规范与语法验证 (Artifacts & Validation)

- **Mermaid 图表完整性**：在撰写包含 `mermaid` 图表的 `.md` 文档时，**禁止**在代码块中使用 `... (保持不变) ...` 等省略占位符。这会导致渲染引擎报错，导致图表无法显示。必须提供完整、语法正确的 Mermaid 代码。
- **配置与 SQL 准确性**：生成的 SQL 必须经过基础语法自审（如括号匹配、逗号位置），禁止生成包含伪代码或逻辑断层的内容。
- **编译优先走仓库 Skill**：涉及 Maven 编译、测试或安装时，优先检查并遵循 `.agent/skills/maven-compile/SKILL.md` 的固定 JDK、Maven、`settings.xml` 与命令约定，不要擅自使用历史路径或系统默认 Java 环境。
- **外部接口 DTO 注释规范**：对接第三方 SPI、OpenAPI、回调协议时，请求/响应 DTO 必须优先按协议场景或版本分组字段，例如 `// ========== 通用字段 ==========`、`// ========== 团购 (B10) 专属字段 ==========`、`// ========== 日历票 (A21) 专属字段 ==========`；字段与嵌套结构应补充能脱离文档直接阅读的中文注释，说明字段语义、适用场景、关键约束（如 `count/copies` 区别、哪些字段决定响应载体）；已有的协议说明、业务注释和 TODO 默认保留，不得为了“代码整洁”擅自删除后续实现线索。

## 5. 🤖 强迫自我进化 (Auto-Learning)

在完成任务后，如满足以下任一条件，**你必须主动询问人类是否需要将经验沉淀下来**：
- 修复了非显然的环境/配置/编码问题，后续 AI 或开发者很可能再次踩坑；
- 纠正了 AI 之前对业务逻辑、对象模型或架构边界的错误理解（如本次对 Mermaid 占位符导致渲染失败的修复）；
- 形成了可复用的排查流程、脚本、命令序列或工作流。
## Plan Archive Naming (Mandatory)

- Any AI that writes files under `.agent/plan/{module}/` MUST follow:
  - `.agent/rules/PLAN_ARCHIVE_NAMING_STANDARD.md`
- Required file name:
  - `YYYY-MM-DD_{featureKey}_vNN_{docType}.md`
- Required docType:
  - `implementation_plan`
  - `walkthrough`
- Required pair rule:
  - same `date + featureKey + version`
  - both `implementation_plan` and `walkthrough` must exist
- Non-compliant naming is treated as rule violation.
