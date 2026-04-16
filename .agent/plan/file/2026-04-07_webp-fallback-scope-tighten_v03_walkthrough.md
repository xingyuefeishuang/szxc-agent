# walkthrough

## result
图片处理链路的自动降级范围已收紧为仅 `webp`。

## changes
- `FastDfsOssServiceImpl` 仍然会先按原始扩展名写出处理后的主图与缩略图。
- 当目标格式为 `webp` 且 `ImageIO.write` 不可写时，才会自动降级到 `png`。
- 对于 `jpg/png/gif` 等其他格式，如果写出失败，将直接抛错，不再静默回退到 `png`。

## final behavior
- 原图 `originFileUrl` 保持原始扩展名。
- 处理后的 `fileUrl` 与 `thumbnailUrl` 默认保持原始扩展名。
- 只有 `webp` 写出失败时，处理后的 `fileUrl` 与 `thumbnailUrl` 才会降级为 `png`。

## verification
- 本次未重新执行 Maven 编译验证。
- 改动仅涉及 `FastDfsOssServiceImpl` 的格式降级条件判断。
