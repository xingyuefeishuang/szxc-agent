# implementation_plan

## 基本信息
- 模块: `order`
- featureKey: `controller-fixes`
- 日期: `2026-04-05`
- 版本: `v02`

## 目标
- 在不破坏现有中文注释与文件编码的前提下，重新落实两个控制器相关修复。

## 修复范围
- `DouyinSpiController.groupbuyCreateOrder`
- `OrderServiceImpl.handlePayCallback`

## 执行约束
- 先使用 `.agent/skills/utf8-console` 读取源码，确认控制台 UTF-8 显示正常。
- 不使用 PowerShell 对源码做字符串写回。
- 仅使用 `apply_patch` 进行最小化逻辑修改。
- 不删除或改写用户已有中文注释。

## 实施步骤
1. 读取 `utf8-console` 与 `code-migration` 相关技能说明。
2. 为 `groupbuyCreateOrder` 增加与其他抖音 SPI 一致的验签前置。
3. 将支付回调幂等判定扩展到支付后续状态。
4. 复查变更片段，确认注释未受影响。
