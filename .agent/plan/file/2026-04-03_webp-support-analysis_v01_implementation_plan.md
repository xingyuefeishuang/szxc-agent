# implementation_plan

## task
为 `plt-file` 补齐 `.webp` 图片支持，覆盖图片元数据读取、图片解码以及 FastDFS 图片处理链路。

## steps
1. 阅读仓库要求的最小全局文档，确认改动边界。
2. 定位 `plt-file` 中图片上传实现，重点检查 `FastDfsOssServiceImpl` 的 `readImageMetadata`、`readImage` 与图片回写逻辑。
3. 在 `plt-file-core` 增加 WebP `ImageIO` 插件依赖，使 `ImageIO` 能识别 `.webp`。
4. 调整 `FastDfsOssServiceImpl` 的处理后图片输出格式选择逻辑，避免 `.webp` 在缩放后回写阶段失败。
5. 尝试编译 `plt-file-core` 验证改动；若环境阻断，则记录阻断原因。
