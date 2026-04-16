# 抖音方案层幂等基础能力上提实施计划

- 日期: `2026-04-14`
- 模块: `order`
- featureKey: `douyin-solution-idempotency-base`
- version: `v01`

## 背景

- `ScenicGroupbuyDouyinSolution` 内部存在一套 Redis 幂等流程:
  - 读取缓存结果
  - 抢占 processing 标记
  - 成功后写入最终结果
  - 异常时按 owner 清理 processing 标记
- 这套逻辑属于抖音渠道适配层的通用基础设施，不属于景区团购独有业务。
- 订单模块既有设计约束明确:
  - 外部渠道请求级幂等保留在 SPI / 适配层
  - 不下沉到核心 `OrderService`

## 实施目标

1. 将 Redis 幂等基础能力上提到 `AbstractDouyinSolution`。
2. 保留业务键拼装、缓存 payload 解释、协议返回体在具体 solution 中实现。
3. 不改变核心订单 service 的幂等边界。

## 变更步骤

1. 在 `AbstractDouyinSolution` 中新增:
   - `getIdempotentValue`
   - `tryClaimIdempotentKey`
   - `cacheIdempotentValue`
   - `clearIdempotentKeyIfOwner`
   - `buildProcessingValue`
   - `isProcessingValue`
2. 为抽象类注入 `StringRedisTemplate`，同步调整子类构造器。
3. 将 `ScenicGroupbuyDouyinSolution` 的退款审核/退款通知幂等逻辑改为复用抽象层方法。
4. 保留以下内容在具体类:
   - `bizUniqKey -> Redis key` 的映射
   - `auditResult|feeAmount` 的缓存值协议
   - 通知完成态 `DONE`
   - 抖音接口返回体组装

## 风险与控制

- 风险: 抽象过度后把渠道语义与业务语义混在一起。
- 控制:
  - 只抽“机制”，不抽“业务键”和“协议载荷”。
  - 不把幂等逻辑下沉到核心 service。
- 风险: 构造器改签名影响 Spring 注入。
- 控制:
  - 同步调整所有 `AbstractDouyinSolution` 子类构造器。

## 验证

- 静态核对 `AbstractDouyinSolution` 调用方，确认构造器全部对齐。
- 运行 Maven 编译验证。
- 若环境 JDK 不满足，仅记录为环境阻塞，不继续扩大代码改动范围。
