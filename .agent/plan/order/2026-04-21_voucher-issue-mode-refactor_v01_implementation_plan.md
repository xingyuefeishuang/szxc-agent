# 重构 issueVouchers 支持三种发码模式

## 1. 背景

将 `FulfillmentVoucherServiceImpl.issueVouchers(OrderFulfillmentCmd)` 从二选一路由重构为显式三路分发，支持：
1. 内置码规则发码（BUILTIN_RULE）
2. 渠道自定义 Items 发码（CHANNEL_ITEMS）
3. 调用方自定义平台 Items 发码（PLATFORM_ITEMS）

## 2. 变更文件

### 新增
- `VoucherIssueMode.java` — 发码模式枚举
- `PlatformVoucherIssueItemCmd.java` — 平台侧发码明细命令

### 修改
- `OrderFulfillmentCmd.java` — 新增 `voucherIssueMode` 和 `platformVoucherItems`
- `FulfillmentVoucherServiceImpl.java` — 入口 switch-case 三路路由 + `resolveIssueMode()` 自动推断 + `platformReqIssueVouchers()` 实现

## 3. 兼容性

- 完全向后兼容，所有现有调用方无需改动
- 不传 `voucherIssueMode` 时自动推断
