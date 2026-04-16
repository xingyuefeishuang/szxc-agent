# 抖音SPI下单字段默认值补全

抖音SPI回调创建订单时，不会传递平台内部概念的字段（如 `prodId`、`appId`、`userId`、`createUser` 等）。当这些字段为 `null` 时，数据库 `NOT NULL` 约束或 MyBatis-Plus 自动填充会报错。需要在核心层入库前，对这些字段进行兜底赋默认值。

## Proposed Changes

### OrderServiceImpl — 创单字段兜底

#### [MODIFY] [OrderServiceImpl.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/impl/OrderServiceImpl.java)

在 `createOrder()` 方法中，在 `this.save(order)` **之前**，对 Order 实体增加 null 兜底逻辑：

| 字段 | 默认值 | 说明 |
|------|--------|------|
| `prodId` | `"0"` | 抖音SPI无产品线概念 |
| `appId` | `"0"` | 抖音SPI无应用模块概念 |
| `userId` | `"0"` | 抖音SPI无内部用户ID，已有 `channelUserId` 存 OpenID |
| `userAccount` | `""` | 抖音SPI无用户账号 |
| `createUser` | `0L` | SPI回调无登录上下文，`FieldFill.INSERT` 依赖 MetaObjectHandler 中的登录用户  |
| `modifyUser` | `0L` | 同上 |
| `parentOrderId` | `0L` | 已在现有代码中设置（保持不变） |
| `payType` | `0` | 抖音SPI不传支付方式 |
| `discountAmount` | `BigDecimal.ZERO` | 可能为 null |
| `couponAmount` | `BigDecimal.ZERO` | 可能为 null |
| `deleted` | `0` | 逻辑删除初始值 |

对 OrderItem 子项同样增加兜底：

| 字段 | 默认值 | 说明 |
|------|--------|------|
| `prodId` | 从 `cmd.getProdId()` 继承（已兜底为 `"0"`） | 子单冗余 |
| `appId` | 从 `cmd.getAppId()` 继承（已兜底为 `"0"`） | 子单冗余 |
| `price` | `BigDecimal.ZERO` | 可能未传 |
| `couponAmount` | `BigDecimal.ZERO` | 可能未传 |
| `createUser` | `0L` | 同主表 |
| `modifyUser` | `0L` | 同主表 |
| `deleted` | `0` | 逻辑删除初始值 |
| `refundStatus` | `"NONE"` | 新建子项无售后 |

---

### VoucherServiceImpl — 发券字段兜底

#### [MODIFY] [VoucherServiceImpl.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/impl/VoucherServiceImpl.java)

在 `issueVouchers()` 中创建 `Voucher` 对象后，对以下字段兜底：

| 字段 | 默认值 | 说明 |
|------|--------|------|
| `prodId` | 从 `item.getProdId()` 继承（已兜底） | 冗余字段 |
| `appId` | 从 `item.getAppId()` 继承（已兜底） | 冗余字段 |
| `createUser` | `0L` | 同上 |
| `modifyUser` | `0L` | 同上 |
| `deleted` | `0` | 逻辑删除初始值 |

## Verification Plan

### Automated Tests

项目当前无单元测试。使用 Maven 编译验证代码无语法错误：

```powershell
# 按 maven-compile skill 执行
cd d:\08-Work\01-博思\10-平台2.0
$env:JAVA_HOME = "C:\Users\79904\.jdks\corretto-17.0.14"
mvn clean compile -pl plt-core-service/plt-order-service/plt-order-core -am -T 2C -q
```

### Manual Verification

改动后可由用户在联调环境向抖音SPI发送创单请求，验证：
1. 不传 `prodId`、`appId`、`userId` 等字段时不再报 NOT NULL 约束异常
2. 数据库中相关字段正确写入默认值 `"0"` / `0L` / `BigDecimal.ZERO`
