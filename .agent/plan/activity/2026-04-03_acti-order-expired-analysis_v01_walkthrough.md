# walkthrough

本次排查确认，`plt-cms` 中没有直接把活动订单状态写成 `ActiOrderStatus.EXPIRED` 的代码；`plt-cms` 仅定义了延时类型枚举 `ActiOrderDelayType.ACTIVITY_END("ORDER_TIMEOUT", "订单过期")`，实际写库发生在 `plt-mobile` 和 `plt-opr`。

已识别的 `EXPIRED` 场景分为两类：

1. 正常场景：活动结束延时消息
   - `plt-mobile-service/.../ActiOrderMessageConsumer.java`
   - 当延时类型为 `ACTIVITY_END` 且订单仍为 `WAIT_JOIN` 时，更新为 `EXPIRED`；若为 `JOINED` 则更新为 `FINISHED`。
   - 这个语义和“活动结束后未参与即过期”一致，判断为合理。

2. 可疑且更可能出错的场景：支付成功回调按“回调到达时间”判定是否过期
   - `plt-mobile-service/.../ActiPrebookServiceImpl.java#insertAndPayCallback`
   - `plt-opr-service/.../ActiPrebookServiceImpl.java#insertAndPayCallback`
   - 两处都使用 `LocalDateTime.now()` 与 `actualStartTime/actualEndTime` 比较；如果支付回调到达时已晚于活动结束时间，就直接把订单写成 `EXPIRED`。
   - 这会把“实际已支付成功，但支付回调晚到/重试晚到”的订单误判为过期，属于最明显的错误场景。

补充风险：

- `ActiPrebookServiceImpl#update` 在预约单确认时，也会按“确认发生时的当前时间”把订单置为 `EXPIRED`。这个是否合理依赖业务定义；如果“审核晚了不允许参与”是预期，则可以成立。相比之下，支付成功回调场景的误判更明确。
- `plt-opr-service/.../ActiOrderServiceImpl.java#confirmJoin` 对 `EXPIRED` 订单又允许改成 `FINISHED`，侧面说明系统里确实存在“先被打成 EXPIRED，后续再人工纠正”的路径。
