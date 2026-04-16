# plt-order-core 下一阶段实施计划（v02）

## 0. 版本调整说明
- 相比 v01，本版按当前真实边界调整：
  - 渠道商品映射能力暂不实现（未对接商品中心接口）。
  - 库存扣减/释放暂不实现（无库存域数据来源）。
  - 上述两项仅保留 TODO 占位与接口边界。

## 1. `PARTIAL_REFUNDED` 说明（概念与场景）
- 定义：订单已发生部分履约或部分退款，主单未完全终结，不能标记为 `REFUNDED`。
- 典型场景：
  - 一单多券，只退其中 1 张，剩余券仍可核销。
  - 部分子项退款完成，其他子项仍在履约中。
- 当前状态：
  - 现有 `OrderStatusEnum` 未落地该枚举，现阶段保持不新增，仅在退款逻辑中留 TODO 与注释说明。

## 2. 当前阶段核心目标（按优先级）
1. P0：退款闭环可用（外部审核 + 外部通知 + 内部状态一致）
2. P0：SPI 验签真正启用（使用已实现签名工具）
3. P1：回写 API 先打通可调用骨架（优先可观测与可重试）
4. P2：映射/库存保持 TODO，等待商品域与库存域接入

## 3. 实施清单

### 阶段A（P0）：退款主链路闭环
- 文件：`DouyinChannelAdapter`、`RefundApplyServiceImpl`
- 内容：
  - `handleRefundApply` 基于请求真实调用 `refundApplyService.applyRefund`，返回 `Accept/Reject/Waiting`。
  - 利用 `biz_uniq_key` 做幂等键（至少先落库或缓存幂等标识）。
  - `handleRefundNotify` 依据通知更新内部退款终态，并保证“通知类接口”按协议返回成功/可重试。
  - A30 `AfterPay` 取消与退款链路关联（不再仅日志）。

### 阶段B（P0）：验签接入
- 文件：`DouyinSpiController`
- 内容：
  - 接入 `DouyinSignVerifyUtil.verifyNewSignature`（必要时兼容旧签名）。
  - 保证验签使用原始 `body bytes`，避免反序列化后重排导致签名失败。
  - 验签失败按 SPI 协议返回可识别错误码。

### 阶段C（P1）：回写 API 与 SDK策略
- 文件：`DouyinChannelAdapter`（`notifyVerifyResult` / `notifyRefundResult`）
- 内容：
  - 先抽象 `DouyinOpenApiClient` 接口，封装回写调用参数。
  - 若 `com.douyin.openapi:sdk:1.0.8` 可用则接 SDK；不可用则先用 HTTP 客户端直连。
  - 回写失败走重试队列 TODO（RocketMQ）。

### 阶段D（P2）：延后项（仅 TODO）
- 映射：
  - `resolveSkuMapping` 保留 TODO，等待商品中心提供映射查询能力。
- 库存：
  - `createOrder/cancelOrder` 的库存扣减与释放保留 TODO，等待库存域对接。
- 状态：
  - `PARTIAL_REFUNDED` 保留设计说明 TODO，待业务确认后统一补枚举和状态机。

## 4. 依赖与风险
- `com.douyin.openapi:sdk:1.0.8` 当前本地仓库仅有 `.lastUpdated`，未下载成功，暂不能确认其具体 API 面。
- 退款幂等若仅内存实现，重启后失效；建议最终落 DB/Redis。

## 5. 验收标准
- 退款审核 SPI：可按票状态返回接收/拒绝，重复请求不重复受理。
- 退款通知 SPI：通知类接口在业务异常时仍按协议处理（仅系统异常返回可重试）。
- SPI 验签：使用 `x-life-sign` 通过校验后才进入业务处理。
