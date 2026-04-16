# 凭证查询职责下沉实施计划

## 目标

将“按订单查询凭证、取凭证码列表、统计已核销数量、判断是否已发券”等能力从渠道适配层临时查询收回到 `VoucherService`，保证统一订单中心的领域边界清晰。

## 原则

1. `OrderService` 负责订单生命周期与订单聚合视图。
2. `VoucherService` 负责凭证生成、查询、状态判断与统计。
3. 渠道适配层不直接通过 `lambdaQuery()` 操作凭证实体。

## 变更范围

### 1. VoucherService

新增以下领域接口：

- `listByOrderNo(String orderNo)`
- `listVoucherCodesByOrderNo(String orderNo)`
- `countVerifiedByOrderNo(String orderNo)`
- `hasIssuedVouchers(String orderNo)`

### 2. VoucherServiceImpl

实现上述接口，并统一凭证查询排序与状态统计逻辑。

### 3. DouyinChannelAdapter

替换原有直接查询 `Voucher` 实体的代码：

- 发码幂等改为通过 `VoucherService.hasIssuedVouchers/listVoucherCodesByOrderNo`
- 查单统计改为通过 `VoucherService.listByOrderNo/countVerifiedByOrderNo`

## 验证方式

1. 编译 `plt-order-service` 聚合模块。
2. 确认 `DouyinChannelAdapter` 不再直接查询 `Voucher` 实体列表。
