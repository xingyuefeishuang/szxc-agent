# 内部 Controller 请求级锁实施计划

## 背景
- 已明确订单模块的请求级锁分层：
  - 内部单 -> Controller
  - 外部单 -> SPI / 适配层
  - 核心 Service -> 不承接请求级锁
- 当前内部入口仍缺少实际锁实现。

## 实施方案
1. 给 `OrderController.cancel(...)` 按 `orderNo` 增加分布式锁。
2. 给 `OrderController.payCallback(...)` 按 `orderNo` 增加分布式锁。
3. `create(...)` 暂不加锁，并在注释中明确由网关统一承担内部创建请求级幂等/锁。
4. 在 Redis Key 常量类中新增内部取消、内部支付回调锁前缀。

## 边界说明
- 本次不在核心 Service 增加请求级锁。
- 本次不处理内部创建缺少稳定业务键的问题，继续由网关层承接。
