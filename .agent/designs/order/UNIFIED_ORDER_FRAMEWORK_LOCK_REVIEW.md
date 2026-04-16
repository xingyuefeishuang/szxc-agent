# 统一订单中心 — 框架内部分布式锁评估与踩坑预警 (V3.4)

> **关联工程**: `plt-framework-redis-starter`  
> **关联类**: `@DistributedLock`, `DistributedLockAspect`  
> **更新日期**: 2026-03-24  
> **核心议题**: 评估公司基础架构内建的 `@DistributedLock` 是否可直接应用于订单中心防超卖，以及底层切面源码 Review。

---

## 1. 结论定调：能用，但有两个前提！

你提到的 `@DistributedLock` 注解和对应的 AOP 切面（基于 Redisson 的 `RLock` 实现），我已经完整 Review 过其源码：

**结论：完全可以用它来做订单中心的防超卖控制。它本质上就是我上一份文档中提到的“方案一：基于 RLock 的分布式悲观锁排队”。**

你只需要在 `OrderService.createOrder` 核心方法上加上形如 `@DistributedLock(keyPrefix = "ORDER_STOCK:", lockKey = "#cmd.skuId")` 的注解，就能强行把对同一个 SKU 商品下单的所有并发请求**串行化（排队执行）**。因为同一时刻只有一个线程能拿到这个锁去数据库执行真正的 `stock = stock - 1`，所以**在逻辑上绝对不可能发生超卖**。

---

## 2. 深入探讨：这套注解在业务层面的“隐性天花板”

虽然能防超卖，但业务线和基础架构部的目标往往不一致。使用这个注解你需要了解这套打法的瓶颈：

### 2.1 整体吞吐量受限于数据库事务（拖慢排队）
切面在进入你的下单方法前拿锁（`lock.tryLock(...)`的默认 `waitTime` 为 30 秒）。
如果你的业务数据库在远端，或者 `createOrder` 方法里有插入主表、子表、查规则等一系列耗时在 **500ms** 的 DB 动作。
这就意味着，针对**同一个热门票种**，1 秒钟内你们系统最多只能处理 2 笔下单！如果有 100 个人同时抢票，剩下的人会在切面的 `lock.tryLock()` 处傻等，超过 30 秒如果还没轮到他，就会抛出 `RuntimeException`（抢锁失败）。

> **架构师建议**：对于平日冷门的景区票证兜底，这种做法极度安全省事。但在五一、国庆甚至搞秒杀运营活动前，**千万不能依赖这个锁拦截法**。高并发下一定要切回我昨日推荐的“方案二：用 `RSemaphore.tryAcquire()` 只耗时 `1ms` 非阻塞拿信号量令牌，拿不到直接无情拒绝”。

### 2.2 锁持有时间（Lease Time）与看门狗机制
该切面调用了：`lock.tryLock(distributedLock.waitTime(), distributedLock.timeUnit())`。
由于它没有传递第三个参数（LeaseTime 释放期），所以 Redisson 默认会自动启动强大的 Watchdog（看门狗）机制：每隔 10 秒自动续期，只要你的微服务进程没死，这个锁就不会自动释放。这确保了你的扣库存耗时再久，锁也不会意外丢失。这是一处极好的正确使用规范。

---

## 3. 🚨 源码漏洞预警：分布式环境下的隐藏霸王龙

在 `DistributedLockAspect` 的第 85 行 `finally` 块中，存在一个极其危险的隐藏缺陷。

```java
        } finally {
            if (lockFlag) {
                lock.unlock(); // <-- 危险！
            }
        }
```

### 危险场景推演：
1. 线程 A 成功拿到锁，`lockFlag = true`。
2. 线程 A 开始执行极其复杂的单据生成逻辑。突然，这台 JVM 发生了持续 15 秒钟的 Full GC（全员挂起 Stop-The-World）。或者因为网络抖动导致 Redisson 的看门狗（Watchdog）没能连上 Redis 服务器去续期。
3. 锁在 Redis 那端自动过期被强制回收了。
4. JVM 恢复，业务代码正常跑完或由于远端调用抛出网络超时报错。代码接着执行 `finally`。
5. 因为 `lockFlag` 仍是 `true`，切面去执行 `lock.unlock()`。
6. 但此时锁早就不在这个线程手上了！**Redisson 会瞬间抛出一个 `IllegalMonitorStateException`**。

### 这里会引发什么严重的灾难？
AOP 的 `finally` 里抛出未捕获的运行时异常，**会把原先（try 中）本来执行成功的结果或是原发性的业务报错全部吞噬（覆盖）掉！** 导致客户端收到一个莫名其妙的锁状态报错，而库里的订单可能已经落成功了，触发无法挽回的幻读客诉！

### 修复方案：
请务必联系框架部的同学，将文件 `cn\com\bsszxc\plt\redis\lock\DistributedLockAspect.java` 第 86 行代码予以加固修复：

```diff
        } finally {
-           if (lockFlag) {
+           if (lockFlag && lock.isHeldByCurrentThread()) {
                lock.unlock();
            }
        }
```
**`lock.isHeldByCurrentThread()` 是分布式解锁时不可或缺的兜底校验铁律。**
