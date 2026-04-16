# implementation_plan

## 基本信息
- 模块: `order`
- featureKey: `order-redis-key-constants`
- 日期: `2026-04-05`

## 目标
- 将 `plt-order-service` 内散落的 Redis key 前缀统一收敛到常量类。
- 本次仅处理 `order` 模块自身已实际使用的 Redis key，不跨模块扩散。

## 范围
- `plt-order-api/.../constant/`
- `plt-order-core/.../channel/douyin/adapter/DouyinChannelAdapter.java`

## 实施步骤
1. 扫描 `plt-order-service` 中实际落地的 Redis key 与锁 key。
2. 新增独立常量类承载 Redis key 前缀。
3. 替换 `DouyinChannelAdapter` 中的散落字符串。
4. 复查注解参数与方法拼接逻辑。

## 约束
- 不修改无关业务逻辑。
- 不删除现有中文注释。
- 仅使用结构化补丁修改源码。
