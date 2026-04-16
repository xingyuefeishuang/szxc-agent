# OrderController 输入校验补强实施计划

## 背景
- `OrderController` 的下单入口已使用 `@Valid`，但嵌套商品项缺少关键字段约束。
- `cancel/detail/pay-callback` 的裸字符串参数也未做显式非空校验。
- 这会导致明显非法请求直接进入服务层，并在更深层以默认值或异常方式暴露。

## 实施方案
1. 给 `OrderController` 增加 `@Validated`，使方法级参数校验生效。
2. 给 `cancel/detail/pay-callback` 的 `orderNo/transactionId` 增加 `@NotBlank`。
3. 给 `StandardOrderCreateCmd.OrderItemCmd` 增加关键字段约束：
   - `spuId` 非空
   - `skuId` 非空
   - `price` 非空且不能小于 0
   - `quantity` 非空且必须大于 0

## 边界说明
- 本次不补 `calc-price` 的商品项校验，避免和未实现能力耦合。
- 本次不调整服务层默认值逻辑，只先把明显非法请求挡在 controller 入参校验层。
