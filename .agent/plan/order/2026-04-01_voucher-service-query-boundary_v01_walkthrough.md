# 凭证查询职责下沉完成总结

## 本次完成内容

本次把“按订单查询凭证”的能力从抖音适配层临时查询收回到 `VoucherService`，让凭证域服务真正承担凭证查询与统计职责。

## 已完成修改

1. `VoucherService`
- 新增 `listByOrderNo`
- 新增 `listVoucherCodesByOrderNo`
- 新增 `countVerifiedByOrderNo`
- 新增 `hasIssuedVouchers`

2. `VoucherServiceImpl`
- 实现按订单查询凭证 BO 列表
- 实现按订单提取凭证码列表
- 实现按订单统计已核销数量
- 实现按订单判断是否已发券

3. `DouyinChannelAdapter`
- 发码幂等改为调用 `VoucherService`
- 查单凭证数量与已核销数改为调用 `VoucherService`
- 删除 adapter 内部直接查询 `Voucher` 的实现

## 结果

当前边界已经调整为：

1. `OrderService` 负责查订单。
2. `VoucherService` 负责查凭证与统计凭证状态。
3. 渠道适配层仅做编排，不直接访问凭证持久化细节。

## 验证结果

已按仓库 `maven-compile` skill 编译通过：

- 编译范围：`plt-core-service/plt-order-service`
- 结果：通过
