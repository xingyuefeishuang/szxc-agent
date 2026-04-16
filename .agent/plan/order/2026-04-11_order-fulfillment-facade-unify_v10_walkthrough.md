# Order Fulfillment Facade Unify v10 Walkthrough

## What changed

这轮把履约语义从“触发阶段”改成了“交付方式 + 履约策略”：

- `OrderFulfillmentStrategy` 现在只表示 `delivery_type`
- `FulfillmentPolicy` 表示支付后是立即交付还是延迟交付
- 券类交付统一收敛到 `VoucherIssueExecutor`

支付回调入口现在会先判断 policy：

- OTA 渠道：`DEFERRED`
- 其他渠道：`IMMEDIATE`

随后再进入 `OrderFulfillmentFacadeServiceImpl` 做 `delivery_type` 路由。

## Voucher flow

`VoucherOrderFulfillmentStrategy` 只保留两种分支：

- `IMMEDIATE`：调用 `VoucherIssueExecutor` 发码，并在需要时推进到 `DELIVERING`
- `DEFERRED`：支付阶段不发码，不推进交付动作

`DefaultVoucherIssueExecutor` 只关心“如何发码”，不再携带“按需/阶段”语义：

- `voucherItems` 为空：按整单 `item * quantity` 默认发码
- `voucherItems` 非空：按明细发码，并复用已有券、补发缺失券

## Douyin alignment

抖音适配层继续只负责协议转换：

- B10 团购发码：把证码明细转换成 `voucherItems`
- A21 日历票发码：不传 `voucherItems`，走默认整单发码

同时修正了之前因为误读 DTO 带来的字段访问错误：

- B10 商品解析使用 `skuInfoList`
- A11 商品解析使用顶层 `productOutId / skuOutId / count`

## Compile and fixes

编译过程中还暴露出 API POJO 的一个历史问题：部分 `Date / BigDecimal / List` 在 class 签名里被错误生成为裸类型，导致 `core` 模块链接失败。

这轮通过两步兜住：

1. 对关键 API POJO 使用显式限定名
2. 给 `OrderBO` 显式补充 `items / vouchers` getter/setter

最终验证命令：

```powershell
$env:JAVA_HOME = 'D:\05-Development\jdk-17'
mvn clean compile -DskipTests
```

结果：`plt-core-service/plt-order-service` 编译通过。
