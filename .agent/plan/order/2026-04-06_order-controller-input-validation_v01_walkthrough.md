# OrderController 输入校验补强工作总结

## 本次改动
- `OrderController` 增加 `@Validated`。
- `cancel/detail/pay-callback` 入参增加 `@NotBlank` 校验。
- `StandardOrderCreateCmd.OrderItemCmd` 增加以下约束：
  - `spuId` -> `@NotNull`
  - `skuId` -> `@NotNull`
  - `price` -> `@NotNull + @DecimalMin("0")`
  - `quantity` -> `@NotNull + @Min(1)`

## 结果
- controller 不再接受缺失 `spuId/skuId/price/quantity` 的下单请求。
- `orderNo` 和 `transactionId` 为空字符串时，会在入口层直接被校验拦截。

## 未覆盖事项
- `calc-price` 相关输入校验暂未补。
- 未执行自动化测试，本次结论基于静态代码修改。
