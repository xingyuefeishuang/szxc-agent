# Walkthrough: 重构 issueVouchers 支持三种发码模式

## 变更概述

将 `FulfillmentVoucherServiceImpl.issueVouchers(OrderFulfillmentCmd)` 重构为显式三路分发。

## 变更文件

| 文件 | 说明 |
|------|------|
| `VoucherIssueMode.java` [NEW] | 发码模式枚举 |
| `PlatformVoucherIssueItemCmd.java` [NEW] | 平台侧发码明细命令 |
| `OrderFulfillmentCmd.java` [MODIFY] | 新增 `voucherIssueMode` + `platformVoucherItems` |
| `FulfillmentVoucherServiceImpl.java` [MODIFY] | 三路 switch-case 路由 + `platformReqIssueVouchers` 实现 |

## 三种模式

| 模式 | 触发 | 用途 |
|------|------|------|
| BUILTIN_RULE | 无 items | 按订单 item × quantity 自动发码 |
| CHANNEL_ITEMS | 有 voucherItems | 渠道驱动发码（含渠道→平台映射） |
| PLATFORM_ITEMS | 有 platformVoucherItems | 调用方直接指定平台 item 发码 |

## 验证

- Maven 编译通过（本次变更文件无编译错误）
