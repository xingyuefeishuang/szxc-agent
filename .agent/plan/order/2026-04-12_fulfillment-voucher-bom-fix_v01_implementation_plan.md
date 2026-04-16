# 实施计划

## 任务

修复 `FulfillmentVoucherServiceImpl.java` 因 UTF-8 BOM 导致的 Jenkins 编译失败，并将该经验沉淀到全局 AI 规则。

## 实施步骤

1. 检查目标文件头字节，确认是否存在 `EF BB BF`（UTF-8 BOM）。
2. 在不改动业务代码内容的前提下，将文件重写为 UTF-8 无 BOM。
3. 复核文件头，确认源码从 `package` 直接开始。
4. 将“源码文件禁止写入 BOM”的规则追加到 `.agent/rules/AI_BEHAVIOR_RULES.md`。
5. 归档本次实施计划与工作总结。

## 风险与关注点

- 若使用不当的 Windows 写文件方式，后续仍可能再次引入 BOM。
- 本次只修复已发现文件，不批量扫描全仓库。
