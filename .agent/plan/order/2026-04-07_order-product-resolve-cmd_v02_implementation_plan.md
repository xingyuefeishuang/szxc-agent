# 统一商品解析命令骨架 v02 - 实施计划

## 背景

在 v01 中已经完成了统一商品解析命令/结果对象和 `OrderProductFacadeService.resolveCreateItems(...)` 的骨架搭建。

本次目标是在不打断现有其他链路的前提下，把抖音 B10 创单真正接到统一商品门面里，验证这套边界不是“只定义不用”。

## 本次目标

1. 让抖音 B10 在 `DouyinChannelAdapter.handleCreateOrder(...)` 中改为调用 `orderProductFacadeService.resolveCreateItems(...)`
2. 在 `OrderProductFacadeServiceImpl` 内先实现 `DOUYIN + B10` 的过渡解析
3. 不改 A11，避免一次迁移过多逻辑

## 实施步骤

1. 给 `DouyinChannelAdapter` 注入 `OrderProductFacadeService`
2. 新增 B10 的统一命令组装方法
3. 用 `resolveCreateItems(...)` 返回的 `items/failItemKeys` 替代 B10 旧的直接解析路径
4. 在 `OrderProductFacadeServiceImpl` 中只实现 `channelCode=DOUYIN && bizType=B10`

## 本次不做

1. 不迁移 A11 日历票
2. 不接商品域
3. 不重构 B11 发码
