# implementation_plan

- 阅读仓库要求的最小文档，确认本次属于活动订单状态排查。
- 全局检索 `ActiOrderStatus.EXPIRED` 的写入点和相关延时消息类型。
- 对比 `plt-mobile`、`plt-opr`、`plt-cms` 中各调用链的触发场景。
- 判断哪些场景语义正确，定位最可能的错误设置场景。
- 归档本次排查结论与风险说明。
