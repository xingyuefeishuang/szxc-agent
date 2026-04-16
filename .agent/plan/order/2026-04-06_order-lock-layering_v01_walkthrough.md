# 订单模块锁分层约定工作总结

## 结论
- 内部单请求级锁统一放在 Controller 层。
- 外部渠道请求级锁统一放在 SPI / 适配层。
- 核心 Service 默认不再承担请求级分布式锁职责。

## 原因
- 可以避免入口层与核心层重复加锁。
- 可以减少外部渠道链路中“一个入口请求串多个核心方法”带来的锁顺序混乱风险。
- 有利于保持核心 Service 的职责纯度。

## 本次落地
- 在 `OrderController` 的 `create/cancel/pay-callback` 补充了入口层锁分层注释。
- 在 `DouyinChannelAdapter.handleCreateOrder(...)` 补充了外部请求锁归属注释。
- 在 `OrderServiceImpl.createOrder(...)` 补充了核心层不承接请求级锁的说明。

## 后续建议
- 如果未来要补资源锁，应单独设计“订单聚合资源锁”规则，避免与请求级锁复用同一层次。
