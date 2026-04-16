# OrderController 复审工作总结

## 本次检查内容
- 审阅 `OrderController` 的 `create/cancel/detail/page/pay-callback/calc-price` 六个入口。
- 对照 `OrderServiceImpl` 实际实现，检查接口描述、输入校验和结果行为是否一致。
- 补充核对 `StandardOrderCreateCmd`、`PriceCalcCmd`、`OrderQueryDO` 的字段约束。

## 本次输出
- 发现 `calc-price` 已对外开放但实现仍为空壳。
- 发现分页查询请求对象暴露大量字段，但服务端仅消费其中少量字段，接口语义与实现不一致。
- 发现创建订单和价格试算的嵌套商品项缺乏关键字段校验，controller 允许明显非法请求进入服务层。

## 说明
- 本次结论来自静态代码审查，未执行接口测试。
