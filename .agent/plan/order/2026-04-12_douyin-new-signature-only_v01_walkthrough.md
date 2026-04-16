# 工作总结

## 结果

已将抖音 SPI 验签链路收口为仅支持新签名 `x-life-sign`。

## 具体修改

1. `DouyinSignVerifyUtil` 删除了旧签名 `sign` / `MD5` 相关实现：
   - `computeOldSignature(...)`
   - `verifyOldSignature(...)`
   - `md5Bytes(...)`
2. 同步更新工具类顶部说明、构造规则说明和 `main` 示例，只保留新签名流程。
3. `DouyinSpiSignatureService` 删除旧签名回退校验，只执行 `verifyNewSignature(...)`。

## 校验

- 检索确认抖音订单链路内已无 `verifyOldSignature`、`computeOldSignature`、`md5Bytes`、`oldSign` 残留引用。
- 未执行 Maven 编译，仅完成静态校验。
