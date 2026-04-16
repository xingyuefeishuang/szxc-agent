# 统一订单中心骨架搭建 — 完成总结

## 变更总览

共 **新建 9 个文件**，**修改 8 个文件**，搭建了完整的系统拓扑骨架。

### 新建文件

| 文件 | 说明 |
|------|------|
| [OrderPaidEvent.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/event/OrderPaidEvent.java) | 支付成功事件 |
| [VerifySuccessEvent.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/event/VerifySuccessEvent.java) | 核销成功事件 |
| [RefundApprovedEvent.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/event/RefundApprovedEvent.java) | 退款审批事件 |
| [StandardOrderCreateCmd.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/cmd/StandardOrderCreateCmd.java) | 统一下单指令 |
| [PriceCalcCmd.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/cmd/PriceCalcCmd.java) | 价格试算指令 |
| [OrderController.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/controller/OrderController.java) | 订单交易 API (6 endpoints) |
| [VerifyController.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/controller/VerifyController.java) | 统一核销 API (2 endpoints) |
| [RefundController.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/controller/RefundController.java) | 售后退款 API (3 endpoints) |
| [VoucherController.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/controller/VoucherController.java) | 票务凭证 API (3 endpoints) |

### 修改文件

| 文件 | 说明 |
|------|------|
| [OrderService.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/OrderService.java) | +6 方法签名 |
| [VoucherService.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/VoucherService.java) | +6 方法签名 |
| [RefundApplyService.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/RefundApplyService.java) | +3 方法签名 |
| [VerifyLogService.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/VerifyLogService.java) | +2 方法签名 |
| [OrderServiceImpl.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/impl/OrderServiceImpl.java) | 创单/取消/支付回调伪代码 |
| [VoucherServiceImpl.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/impl/VoucherServiceImpl.java) | 发券/核销/冻结伪代码 |
| [RefundApplyServiceImpl.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/impl/RefundApplyServiceImpl.java) | 退款申请/审批伪代码 |
| [DouyinChannelAdapter.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/channel/douyin/adapter/DouyinChannelAdapter.java) | 添加 @EventListener 事件监听 |

## 遗留 TODO 清单

| TODO | 位置 | 优先级 |
|------|------|--------|
| 分布式锁扣减库存 | `OrderServiceImpl.createOrder` | 🔴 高 |
| RocketMQ 15分钟延迟关单消息 | `OrderServiceImpl.createOrder` | 🔴 高 |
| 释放库存（反扣） | `OrderServiceImpl.cancelOrder` | 🔴 高 |
| 有效期计算 (SpuRule) | `VoucherServiceImpl.issueVouchers` | 🟡 中 |
| 全部核销→COMPLETED判断 | `VoucherServiceImpl.verify` | 🟡 中 |
| 自动审批逻辑 (SpuRule.needRefundAudit) | `RefundApplyServiceImpl.applyRefund` | 🟡 中 |
| 资金原路退款 | `RefundApplyServiceImpl.auditRefund` | 🔴 高 |
| 部分退款判断 (全退/部分退) | `RefundApplyServiceImpl.auditRefund` | 🟡 中 |
| 价格试算 | `OrderServiceImpl.calcPrice` | 🟢 低 |
| 分页查询实现 | `OrderServiceImpl.pageQuery` | 🟢 低 |
| 凭证延期逻辑 | `VoucherController.delay` | 🟢 低 |
| 抖音 API 回写实现 | `DouyinChannelAdapter` | 🟡 中 |
| 回写失败重试队列 | `DouyinChannelAdapter` | 🟡 中 |
