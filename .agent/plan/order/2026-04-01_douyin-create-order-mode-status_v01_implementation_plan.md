# 抖音支付前/支付后创单状态适配实施计划

## 背景
- 抖音同时存在支付前创单和支付后创单两种场景。
- 统一订单中心要求订单状态严格遵循内部状态机，不能因为 SPI 时序不同而提前发码或错误取消。

## 实施目标
- 团购 `B10` 固定按支付前创单处理。
- 日历票 `A11` 按渠道配置 `extraConfig` 中的创单模式区分 `PRE_PAY_CREATE` 和 `POST_PAY_CREATE`。
- 支付前创单时，创单后保持 `PENDING`，收到支付信号后再推进到 `PAID -> DELIVERING`。
- 支付后创单时，创单成功后立即补走统一支付回调。
- `A14` 支付通知 SPI 正式接入控制器和适配层。
- `A21` 在支付前创单且订单仍为 `PENDING` 时禁止提前发券。
- 取消单只允许作用于 `PENDING` 单，避免把已支付订单回退为 `CANCELED`。

## 具体改动
1. 在 `DouyinChannelAdapter` 中引入创单模式常量和解析逻辑。
2. 改造 `handleCreateOrder`：
   - 新单始终先走统一 `createOrder`
   - `POST_PAY_CREATE` 立即补走 `handlePayCallback`
   - 幂等命中时补偿 `PENDING` 状态订单
3. 新增 `DouyinPayNotifyRequest`，实现 `handlePayNotify`：
   - 按 `order_out_id` / `order_id` 查单
   - 已跨过支付红线时按幂等成功返回
   - 未跨过时调用统一支付回调
4. 改造发码逻辑：
   - `B11` 命中 `PENDING` 单时先推进支付状态，再复用已发券结果
   - `A21` 在支付前创单模式下若订单仍未支付，则返回重试，不提前发码
5. 改造取消单逻辑：
   - 非 `PENDING` 状态直接忽略并返回成功
6. 重写 `DouyinSpiController`，补齐 `A14 /calendar/payNotify` 入口，并保留原有验签 TODO。

## 验证
- 使用仓库约定的 JDK 17 Maven 编译命令执行 `plt-order-service` 模块编译。
- 编译命令：
  - `mvn -pl plt-core-service/plt-order-service -am -q compile -DskipTests`
