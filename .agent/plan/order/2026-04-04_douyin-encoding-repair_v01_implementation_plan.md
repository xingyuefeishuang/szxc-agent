# implementation_plan

## 背景
用户反馈本次改动引入乱码，要求立即修复并保留功能实现。

## 目标
1. 修复本次改动中出现的乱码风险点。
2. 保留并恢复退款与验签功能改动。
3. 验证文件编码与可编译性前提。

## 实施步骤
1. 将 `DouyinChannelAdapter`、`DouyinSpiController` 回退到仓库版本，避免继续扩大乱码范围。
2. 重新实现 `DouyinChannelAdapter` 的退款申请/通知逻辑：
   - 退款申请幂等缓存
   - 已核销拒绝退款
   - 退款通知幂等与完结调用
3. 重新实现 `DouyinSpiController` 的验签流程：
   - 每个 SPI 入口统一先验签
   - 通过 `ChannelConfig` 查 `appSecret`
   - 走新签名，失败再走旧签名兜底
4. 确认两个文件为 UTF-8 无 BOM。
5. 进行编译验证；若失败记录环境阻塞项。

## 风险与回滚
- 风险：本机 JDK 版本低于项目目标版本会导致无法完成编译。
- 回滚：可对上述两个文件执行 `git checkout -- <file>` 回退。