# 抖音方案层幂等分层补充说明

## 背景

- 订单模块原有分层约束已经明确：
  - 外部渠道请求级幂等保留在 SPI / 适配层
  - 核心 `OrderService` 不承担外部渠道请求级幂等职责
- 2026-04-14 的实现中，`ScenicGroupbuyDouyinSolution` 内部退款审核、退款通知存在重复的 Redis 幂等流程，因此上提到了 `AbstractDouyinSolution`。

## 本次补充结论

### 允许抽到渠道抽象层的内容

- 可以沉淀到 `AbstractDouyinSolution` 这类“渠道内抽象基类”的内容：
  - 读取幂等缓存
  - `setIfAbsent` 抢占 processing 标记
  - 写入最终结果缓存
  - 按 owner 清理 processing 标记
  - 判断缓存是否仍处于 processing 状态

这类能力属于“渠道适配层基础设施复用”，仍然在外部渠道上下文内部，没有突破既有分层边界。

### 不能继续下沉到核心 Service 的内容

- 以下内容仍然必须保留在具体渠道 solution / SPI 语义层：
  - `bizUniqKey`、`orderId`、`verifyToken` 等渠道语义业务键
  - 第三方 Redis key 前缀
  - 第三方返回体缓存 payload 的编解码规则
  - 命中幂等后的 success / retry 协议返回
  - 第三方业务特有的兜底判断

## 推荐模式

### 渠道抽象层负责

- Redis 幂等通用辅助方法
- 与渠道内多个 solution 共享的技术机制

### 具体 solution 负责

- key 拼装
- payload 结构
- 协议返回体
- 业务判断

## 反例

- 不要把 `bizUniqKey -> Redis Key -> 抖音响应体` 这一整套链路直接下沉到 `OrderService` 或 `RefundApplyService`。
- 那样会把渠道语义污染到核心领域层，违反当前订单模块的幂等分层约束。
