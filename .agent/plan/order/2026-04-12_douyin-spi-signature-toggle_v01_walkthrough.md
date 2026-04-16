# 工作总结

## 结果

已为抖音 SPI 验签增加动态配置开关，支持通过 Nacos 开启或关闭。

## 具体修改

1. 在 `DouyinSpiSignatureService` 上添加 `@RefreshScope`。
2. 新增配置项：
   `plt.order.douyin.spi.signature-verify-enabled`
3. 默认值为 `true`，保持现有逻辑不变。
4. 当配置为 `false` 时，`verifySignature(...)` 直接返回 `null` 跳过验签，并输出告警日志。

## 校验

- 静态检查确认配置键、字段和开关分支已生效。
- 未执行 Nacos 联调和 Maven 编译，仅完成代码层面的快速校验。
