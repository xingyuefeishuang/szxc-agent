# implementation_plan

## 基本信息
- 模块: `order`
- featureKey: `controller-review`
- 日期: `2026-04-05`
- 任务类型: 代码评审

## 目标
- 审查 `plt-order-core` 下控制器接口逻辑是否存在明显缺陷。
- 重点核对接口入参约束、控制器语义、与 service 实现的一致性、回调幂等与安全边界。

## 范围
- `plt-order-core/src/main/java/cn/com/bsszxc/plt/order/controller/`
- `plt-order-core/src/main/java/cn/com/bsszxc/plt/order/channel/douyin/spi/`
- 相关 `service`、`cmd`、`pojo`、状态机与设计文档

## 执行步骤
1. 阅读仓库级 AI 规范与 `.agent` 相关架构/行为文档。
2. 定位 `plt-order-core` 控制器及对应 API/Service/POJO。
3. 检查主控制器接口的入参、返回值、调用链与边界条件。
4. 检查抖音 SPI 控制器的验签、回调语义与幂等处理。
5. 输出按严重度排序的 review findings，并附文件与行号。

## 结果产出
- 形成 review 结论，优先列出缺陷与风险，不做代码改动。
