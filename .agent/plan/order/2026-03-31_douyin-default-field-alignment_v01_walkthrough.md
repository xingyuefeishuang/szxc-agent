# 抖音下单默认值适配完成总结

## 本次完成内容

本次将“抖音场景下缺失的平台内部字段默认值”统一收敛到了订单中心 Core 层，避免抖音适配器直接承担内部模型补齐职责。

### 已完成修改

1. `OrderServiceImpl.createOrder()`
- 新增主单标准化变量，统一处理 `userId/userAccount/prodId/appId`
- 将金额字段统一兜底为 `BigDecimal.ZERO`
- 将 `payType` 兜底为 `0`
- 新增安全解析审计用户方法，避免 `Long.valueOf()` 因空串或非数字值报错
- 子单统一继承标准化后的主单上下文，补齐 `price/couponAmount/refundStatus/createUser/modifyUser/deleted`

2. `VoucherServiceImpl.issueVouchers()`
- 发券时对 `userId/prodId/appId` 使用统一兜底
- `createUser/modifyUser` 改为优先继承子单审计字段，缺失再回退 `0L`

3. `DouyinChannelAdapter`
- 创单增加按 `channelOrderNo` 的幂等返回
- 发码增加“已有凭证直接复用”的幂等逻辑
- 查单补充凭证总数、已核销数和订单状态映射

4. `OrderServiceImpl.getOrderDetail()`
- 显式回填 `OrderBO.id`，修复 adapter 依赖订单主键时可能取空的问题

## 结果

统一订单中心当前已满足以下约束：

1. 抖音适配层可以继续只传渠道真实可得字段。
2. 核心层能对内部上下文字段进行稳定补齐。
3. 主单、子单、凭证三层的默认值口径保持一致。

## 未完成项

1. Maven 编译已完成。
- 按仓库 `.agent/skills/maven-compile/SKILL.md` 中的 JDK 17 / Maven 3.5.4 路径编译通过。

2. 联调验证未执行。
- 仍需在测试环境走抖音重复创单、重复发码、查单三组请求验证幂等与状态返回。
