# 抖音 SPI 协议补齐工作总结

## 本次完成

### 1. 创建订单 DTO 补齐

文件：`plt-order-core/.../DouyinCreateOrderRequest.java`

- 补齐 `custom_spi_req_extra`
- 补齐 `appointment_cancel_rule`、`appointment_rule`
- 补齐 `refund_rule`、`ticket_rule`、`ticket_specification`
- 补齐 `order_type`、`source_order_id`、`remark`、`traveler_info`
- 扩展 `buyer/contact/tourists` 的证件与英文姓名等字段

本次只做协议承接，不改变现有下单核心逻辑。

### 2. 发码 DTO 补齐

文件：`plt-order-core/.../DouyinIssueVoucherRequest.java`

- 补齐 `merchant_ticket_amount_details`
- 补齐 `fee_amount`、`commission_amount`、`payment_discount_amount`、`coupon_pay_amount`
- 补齐发码请求里金额明细与游客字段结构

### 3. 查单返回纠偏

文件：`plt-order-core/.../DouyinChannelAdapter.java`

- 删除 `handleQueryOrder` 返回中的 `order_status`
- 结论：`A12-订单状态查询SPI.md` 文档中没有该字段，之前返回属于协议外字段
- 追加可选 `vouchers` 返回，按当前凭证表状态映射 `0/1`

### 4. 日历票发码返回修正

文件：`plt-order-core/.../DouyinChannelAdapter.java`

- 增加 `copies` 与实际券码数量校验
- 按 `ticket_rule.code_sending_info` 回填：
  - `qrcodes`
  - `certificate_nos`
  - `credentials`
- 缺少明确规则时默认回传 `qrcodes`

## 验证

按仓库 `.agent/skills/maven-compile/SKILL.md` 使用 JDK 17 编译：

```powershell
$env:JAVA_HOME='D:\05-Development\jdk-17'
mvn -pl plt-core-service/plt-order-service -am -q compile -DskipTests -s 'D:\05-Development Tools\apache-maven-3.5.4\conf\settings.xml'
```

结果：编译通过。

## 当前遗留

1. `A12.vouchers.project_id` 目前用 `voucherId` 回填，仅用于协议结构对齐。
2. `B11` 团购发码响应仍是当前系统的最小可用格式，未做完整协议重塑。
3. DTO 已补齐，但很多新增字段尚未进入后续业务消费链路。  
