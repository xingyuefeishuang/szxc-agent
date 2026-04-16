# 抖音 SPI 协议补齐实施计划

## 背景

抖音 SPI 联调过程中，当前 API 层 DTO 与本地接口文档存在结构性缺口，且 `A12` 查单返回里包含了文档未定义的 `order_status` 字段，需要按统一订单中心当前骨架做一次协议对齐。

## 目标

1. 补齐 `A11` 创建订单请求 DTO 中缺失的协议字段。
2. 补齐 `A21` 发码请求 DTO 中缺失的协议字段。
3. 修正 `A12` 查单返回，去掉非文档字段 `order_status`。
4. 让日历票发码返回结构更贴近文档，至少保证 `vouchers.size == copies`，并按 `ticket_rule` 回填凭证载体。
5. 保持现有核心下单、发码、幂等逻辑不被破坏。

## 实施步骤

1. 对照 `.agent/references/ota/douyin/` 下 `A11`、`A12`、`A21` 文档，确认当前 DTO 与返回结构缺口。
2. 扩展 `DouyinCreateOrderRequest`，补齐协议字段与嵌套结构，但不提前引入业务逻辑消费。
3. 扩展 `DouyinIssueVoucherRequest`，补齐金额、票务规则、游客信息等嵌套结构。
4. 调整 `DouyinChannelAdapter`：
   - 去掉 `handleQueryOrder` 中的 `order_status`
   - `A12` 可选返回 `vouchers`
   - `A21` 发码响应按 `ticket_rule` 回填 `qrcodes/certificate_nos/credentials`
   - 校验 `copies` 与实际凭证数量
5. 按 `.agent/skills/maven-compile/SKILL.md` 规定编译 `plt-order-service` 验证。

## 风险点

1. DTO 补齐后，后续如果抖音实际透传更复杂结构，当前仅完成“结构承接”，并未全部消费。
2. `A12.vouchers.project_id` 当前缺少独立项目建模，先用 `voucherId` 回填，满足返回结构但不代表最终业务语义。
3. 团购发码 `B11` 仍保留当前最小可用返回格式，后续若文档要求更严格，需单独补响应对象。
