# 抖音支付前/支付后创单状态适配总结

## 本次完成内容
- 新增 `DouyinPayNotifyRequest`，补齐 `A14` 支付通知请求体。
- `DouyinChannelAdapter` 已支持：
  - 团购 `B10` 固定支付前创单
  - 日历票 `A11` 按渠道配置解析支付前/支付后创单模式
  - 支付后创单成功后自动走统一支付回调
  - 支付通知幂等处理
  - 日历票在支付前创单模式下阻止未支付订单提前发码
  - 团购发码命中 `PENDING` 时先推进内部支付状态
  - 非 `PENDING` 订单忽略取消通知
- `DouyinSpiController` 已重写为干净版本，并接入 `/spi/douyin/calendar/payNotify`。

## 关键结果
- 统一订单中心内部状态机仍以 `OrderService.createOrder -> PENDING` 为唯一入口。
- 支付态推进统一复用 `OrderService.handlePayCallback`，没有在抖音适配层重复造状态机。
- `A21` 不再在支付前创单场景下绕过支付直接发券。
- `A12` 继续保持不返回协议外 `order_status`。

## 验证结果
- 已使用 JDK 17 编译通过 `plt-core-service/plt-order-service`。
- 本轮未补自动化测试，验证方式为模块编译通过和代码路径自检。

## 后续可继续关注
- `A14` / `B10` / `B11` 之间的真实联调时序再用联调数据回归一轮。
- `resolveCreateOrderMode(Order order)` 目前仍依赖当前请求头对应的渠道配置，后续如果一个订单需要脱离请求上下文独立判定模式，可考虑把创单模式持久化到订单扩展信息中。
