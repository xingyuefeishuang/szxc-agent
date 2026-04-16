# 抖音方案层幂等基础能力上提工作总结

- 日期: `2026-04-14`
- 模块: `order`
- featureKey: `douyin-solution-idempotency-base`
- version: `v01`

## 本次完成

- 在 `AbstractDouyinSolution` 中补充了抖音方案层通用 Redis 幂等辅助方法。
- 将 `ScenicGroupbuyDouyinSolution` 的退款审核、退款结果通知幂等逻辑改为复用抽象层能力。
- `ScenicCalendarTicketDouyinSolution` 同步适配抽象类构造器注入。

## 收口边界

- 已抽到抽象层:
  - processing 标记生成
  - Redis set-if-absent 抢占
  - 缓存读写
  - owner 清理
  - processing 状态识别
- 仍保留在具体 solution:
  - `bizUniqKey` 的 key 前缀选择
  - 缓存 payload 编解码
  - 抖音返回体字段
  - 景区团购自身退款业务判断

## 验证结果

- 静态检索确认旧的 groupbuy 私有幂等辅助方法已移除。
- Maven 编译已尝试执行:
  - `mvn -pl plt-core-service/plt-order-service/plt-order-core -am -DskipTests compile`
- 编译未进入 `plt-order-core`，被环境阻塞在上游模块:
  - `plt-framework-swagger-starter`
  - 错误: `invalid target release: 17`

## 结论

- 这次重构适合抽到 `AbstractDouyinSolution`，但只适合抽“渠道适配层的 Redis 幂等机制”。
- 不适合继续下沉到核心订单 service，否则会违反当前订单模块的锁与幂等分层约束。
