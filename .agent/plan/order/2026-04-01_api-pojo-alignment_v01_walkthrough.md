# 统一订单 API POJO 对齐完成总结

## 本次完成内容

本次将 `plt-order-api` 中订单、凭证、退款、渠道配置、规格映射相关 POJO 与 `plt-order-core/db/model` 当前实体做了系统性对齐，解决了 API 层对象仍保留旧版字段模型的问题。

## 已完成修改

1. 规则补充
- 在 `.agent/rules/AI_BEHAVIOR_RULES.md` 中新增“编译优先走 `.agent/skills/maven-compile/SKILL.md`”规则。

2. 订单 API 对象对齐
- `OrderBO/OrderAddDO/OrderUpdateDO/OrderQueryDO`
- 核心修复：`orderStatus` 统一改为 `String`
- 主键统一为 `orderId`
- 新增 `parentOrderId/prodId/appId/channelUserId/payAmount/discountAmount/couponAmount/userId/userAccount/payType/clientIp/extendAttr`
- 移除旧版设计中的商品映射和买家信息字段

3. 凭证 API 对象对齐
- `VoucherBO/VoucherAddDO/VoucherUpdateDO/VoucherQueryDO`
- 主键统一为 `voucherId`
- 关联字段统一为 `orderItemId`
- 状态字段统一为 `status`

4. 退款 API 对象对齐
- `RefundBO/RefundAddDO/RefundUpdateDO/RefundQueryDO`
- 主键统一为 `refundId`
- 状态字段统一为 `String refundStatus`
- 新增 `orderItemId/prodId/appId/userId`

5. OTA API 对象对齐
- `OtaChannelConfig*` 改为对齐 `ChannelConfig`
- `OtaProductMapping*` 改为对齐 `ChannelSkuMapping`

## 验证结果

已按仓库 `maven-compile` skill 的固定环境编译通过：

- 编译范围：`plt-core-service/plt-order-service`
- 结果：通过

## 收益

1. `BeanUtil.copyProperties` 不再依赖错误字段名做“部分成功”的隐式转换。
2. `OrderBO.orderStatus` 与 `Order.orderStatus` 类型统一，发码链路不会再因为状态字段不一致出错。
3. 后续继续完善统一订单中心时，API 层与 DB/Entity 的演化方向重新一致。
