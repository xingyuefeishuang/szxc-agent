# 订单模块请求级锁分层约定

## 背景

订单模块同时存在两类对外入口：

1. 内部入口：`OrderController`
2. 外部入口：`DouyinSpiController` / `DouyinChannelAdapter`

如果在入口层和核心 Service 层同时普遍叠加请求级分布式锁，会带来以下问题：

- 请求锁职责重复
- 锁粒度混杂（外部请求键、订单号、退款业务键并存）
- 外部链路中“一个入口请求串多个核心方法”时，锁顺序难以统一

因此，请求级锁需要先统一分层。

## 约定

### 1. 内部单请求级锁

统一放在 `OrderController`。

适用原则：

- 能从入参中拿到稳定业务键时，直接在 Controller 层加锁
- 当前已落地：
  - `cancel(orderNo)` -> 按 `orderNo` 加锁
  - `payCallback(orderNo, transactionId)` -> 按 `orderNo` 加锁

### 2. 内部单创建

`create(StandardOrderCreateCmd cmd)` 当前**不在 Controller 层补锁**。

原因：

- 现有入参中没有稳定的内部请求业务键
- 如果按请求体拼接锁键，容易引入伪幂等或误串行
- 内部单通用幂等与请求级锁暂统一由网关层承担

因此，当前约定是：

- 网关负责内部单创建的请求级幂等/锁
- `OrderController.create(...)` 不额外补伪锁

### 3. 外部渠道请求级锁

统一放在 SPI / 适配层。

示例：

- `DouyinChannelAdapter.handleCreateOrder(...)`

原因：

- 外部渠道天然带有请求唯一键（如 `orderId`、`bizUniqKey`）
- 外部请求幂等本就属于渠道上下文，不应下沉到核心 Service

### 4. 核心 Service

核心 Service 默认**不承接请求级分布式锁职责**。

核心层职责保留为：

- 业务命令执行
- 状态机流转
- 业务幂等判断

如果未来需要补“资源锁”（例如订单聚合资源锁），应单独设计，不与请求级锁混用。

## 当前落地结果

### 内部入口

- `OrderController.cancel(...)`：按 `orderNo` 加请求级锁
- `OrderController.payCallback(...)`：按 `orderNo` 加请求级锁
- `OrderController.create(...)`：不加锁，由网关统一兜底

### 外部入口

- 抖音创单请求锁继续留在 `DouyinChannelAdapter.handleCreateOrder(...)`

### 核心层

- `OrderServiceImpl.createOrder(...)` 保持纯业务命令语义
- 请求级幂等和请求级锁均不在核心层重复处理
