# 统一订单中心 — 进阶架构讨论与设计补充 (V3.1)

> **关联文档**: [UNIFIED_ORDER_TECHNICAL_DESIGN.md](./UNIFIED_ORDER_TECHNICAL_DESIGN.md)  
> **更新日期**: 2026-03-24  
> **核心讨论点**: 商品 SPU/SKU 抽象、主子订单模型、多形态业务策略路由、对外标准 API 契约定义。  

针对我们之前探讨的6个核心问题，特此将这些细节设计的结论剥离成独立文档予以记录，作为架构演进的重要参考。

---

## 1. 商品模型：是否使用 SKU/SPU？

**结论：强烈建议引入 SPU 与 SKU 的概念。原先仅用 `platform_product_id` 过于粗糙。**

- **SPU (Standard Product Unit)**：代表一个产品主体，例如 “欢乐谷门票”。
- **SKU (Stock Keeping Unit)**：代表具体的售卖规格，例如 “欢乐谷成人周末票”、“欢乐谷儿童工作日票”。

**在架构中的体现**：
- 在订单明细表（下文提到的子订单）中，必须精确记录到 `sku_id`。
- 渠道映射表 `o_channel_product_mapping` 中，抖音售卖的某一个特定套餐，应当映射到我们内部具体的 `sku_id` 上。这保证了底层在扣减具体种类库存、计算特定维度的财务对账时不会乱套。

---

## 2. 订单模型：是否需要子订单的概念？

**结论：必须引入主子订单（Master-Detail）模型。**

特别是对于门票和文旅业务，游客极大概率会购买“家庭游组合套餐”（即1笔钱买出2张成人票、1张儿童票的不同 SKU）。单表结构无法支撑。

**表结构拆分示例**：
- **`o_order` (主订单)**：记录全局信息。如：`order_no`、`channel_code` (如 DOUYIN)、总支付金额 `total_amount`、买家手机号 `buyer_phone`、整体 `order_status`。
- **`o_order_item` (子订单/明细)**：每个购买的 SKU 对应一条记录。字段包含 `order_id`、`sku_id`、`sku_name`、`quantity` (如2张)、`price` (单价)。
- **`o_voucher` (凭证)**：挂靠在 `o_order_item` 之下。如果买2张票，则生成2条 voucher 记录。支持部分退款（只退其中一张凭证）。

---

## 3. `verify_channel` 是否需要具体到 小程序/闸机/抖音/美团？

**结论：需要具体，但这里的“具体”指的是【核销的物理发起端】，绝**不等于**【订单来源渠道】。**

- **正确的值定义应当是**：
  - `GATE`：线下物理闸机设备（配合 `verify_device_id` 记录是景区的几号闸机扫的）。
  - `MINIAPP_SELF`：游客在小程序端点击“自助核销”按钮。
  - `ADMIN_MANUAL`：平台运营人员在电脑后台手工强制核销。
  - `OPEN_API`：分销商或第三方系统通过 API 发起了核销。

**千万不要混淆**：
- 如果一张**抖音渠道 (`channel_code = DOUYIN`)** 买的票，游客拿去**闸机**扫码。核销记录的 `verify_channel` 是 **`GATE`**，绝对不是 `DOUYIN`。
- 是否需要利用 SPI 回调抖音，是由这笔票据关联的主订单的 `channel_code == 'DOUYIN'` 决定的，而和在哪儿核销的（`verify_channel`）毫无关系！

---

## 4. 抖音不同场景（日历票 vs 团购票）流程不同，如何支撑？

**结论：在抖音适配器内部（`channel.douyin` 包内），使用“策略模式（Strategy Pattern）”彻底隔离这部分复杂度。**

抖音的业务线杂乱，如果写在一个大类里全是 `if-else`。我们的解法：
- `DouyinSpiController` 接收外部请求，提取其中的 `biz_type` 或商品标识。
- 通过一个路由工厂 `DouyinBizStrategyFactory`，选择对应的策略实现类去处理业务流转。
  - 策略A：`DouyinGroupBuyStrategy`（处理核销后发券、团购生命周期）
  - 策略B：`DouyinCalendarTicketStrategy`（处理强日历约束、选座锁定等流转）
- **核心价值**：不论抖音有多少种变形模式，在适配器经过策略模式消化后，向下扔给 Core 层的都是极简的 `StandardOrderCreateCmd` 或 `VerifyRequest`，核心领域层（`OrderService`）无需知道这是团购还是日历，只管出票。

---

## 5. 抖音发码场景对接多个 SPI 接口（预订、下单、发码），怎么兼容？

**结论：适配器作为防腐层，吸收多次握手握手调用，并依次触发核心域状态机的部分状态演进。**

抖音标准的四段式流转：
1. **预订校验 (`/validateOrder`)**：
   - 适配器不创建订单，仅调用 Core 层的 `ProductRuleService.checkStock()` 查询库存是否充足。
2. **创单 (`/createOrder`)**：
   - 适配器调用 `OrderService.create()`，核心层落库主子订单记录 `o_order`，状态处于 `PENDING`(待支付/处理状态)，并不发码。
3. **确认订单 (`/confirmOrder` 可选)**：
   - 更新 `o_order` 的状态为 `PAID`。
4. **发券 (`/issueVoucher`)**：
   - 适配器调用 `VoucherService.issueVoucher(orderId)`，核心层生成真实的凭证并落入 `o_voucher` 表。适配器拿到生成的 Voucher 集合，加密成抖音期待的二维码/文本密文，返回给兜底服务器。

这种分段调用完全对应了内部领域模型的生命周期，核心底座无需因为抖音把下单拆成了四步而改变自身业务逻辑，只需提供颗粒度合适的 Service 方法即可。

---

## 6. 统一订单中心对外提供的“纯粹” API 能力清单

不包含提供给抖音及其他 OTA 厂商的 webhook/SPI，这里汇聚的是我们在企业内网乃至公网业务（自家小程序、其它微服务、后台前端）可以随取随用的**标准核心 API 契约总览**（由 `core/controller` 暴露）：

### 6.1 交易与订单组 API
- `POST /api/core/order/create` (统一下单：入参包含 SPU/SKU、购买人信息；返回通用订单号 `order_no`)
- `POST /api/core/order/cancel` (取消未支付订单，释放库存)
- `GET /api/core/order/detail/{order_no}` (查询订单详情，包含其下挂的所有 Voucher)
- `POST /api/core/order/page` (多维条件分页查询，供给运营后台列表)

### 6.2 票务与凭证组 API
- `GET /api/core/voucher/query` (根据票码查询当前凭证状态，是未核销/已过期/已核销)
- `POST /api/core/voucher/disable` (手工冻结/作废特定凭证，适用客诉等强管制)
- `POST /api/core/voucher/delay` (特定凭证延期)

### 6.3 统一核销引擎组 API
- `POST /api/core/verify/check` (核心核销口：**闸机、扫码枪、PDA对接的唯一接口**。入参：票码、设备ID、核销端类别。返回：是否准入放行信号)
- `POST /api/core/verify/manual` (内场票务中心人工手工核销。要求记录操作人账号信息)

### 6.4 售后与退款组 API
- `POST /api/core/refund/apply` (发起退票申请：可传入批量要退的 VoucherId)
- `POST /api/core/refund/audit` (人工审批退款单，审批通过后才通知网关/微信退款资金流转)
- `GET /api/core/refund/detail` (退款审核链路查询)

> **注**：所有的通用 API 都不应该带有专门的 `ota_auth_code` 参数。如果某个外部大客户（比如 OTA）要下单，不走这些网口，而是走 `DouyinSpiController` 等专有防腐层代理转化再调内部 Service 或以上接口。
