# walkthrough

- 结论: 当前 `.agent/plan` 存在两套以上命名模式（日期前缀式、后缀式、无日期式），导致无法通过文件名直观看出先后。
- 建议: 统一采用 `YYYY-MM-DD_HH-mm[-ss]_{topic}_{docType}.md`，其中 `docType` 仅允许 `implementation_plan` 或 `walkthrough`。
- 迁移策略:
  1. 先从新文件开始强制执行新规范；
  2. 对历史文件按需批量重命名；
  3. 可选增加 `INDEX.md` 自动索引（按时间倒序）。
- 收益: 无需打开文件即可判断时间先后，且同一任务 plan/walkthrough 可被稳定聚合。
