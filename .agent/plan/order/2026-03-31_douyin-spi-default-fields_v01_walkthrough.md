# 抖音SPI字段默认值补全 — 完成总结

## 改动范围

### [OrderServiceImpl.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/impl/OrderServiceImpl.java)

`createOrder()` 方法中，对 **Order** 和 **OrderItem** 实体的 null 字段进行兜底赋值：

| 实体 | 字段 | 默认值 |
|------|------|--------|
| Order | `userId` | `"0"` |
| Order | `userAccount` | `""` |
| Order | `prodId` | `"0"` |
| Order | `appId` | `"0"` |
| Order | `totalAmount` / `payAmount` / `discountAmount` / `couponAmount` | `BigDecimal.ZERO` |
| Order | `payType` | `0` |
| Order | `createUser` / `modifyUser` | `0L` |
| Order | `deleted` | `0` |
| OrderItem | `prodId` / `appId` / `userId` | 从主订单继承（已兜底） |
| OrderItem | `price` / `couponAmount` | `BigDecimal.ZERO` |
| OrderItem | `quantity` | `1` |
| OrderItem | `refundStatus` | `"NONE"` |
| OrderItem | `createUser` / `modifyUser` | `0L` |
| OrderItem | `deleted` | `0` |

### [VoucherServiceImpl.java](file:///d:/08-Work/01-博思/10-平台2.0/plt-core-service/plt-order-service/plt-order-core/src/main/java/cn/com/bsszxc/plt/order/service/impl/VoucherServiceImpl.java)

`issueVouchers()` 方法中，对 **Voucher** 实体补充兜底：

| 字段 | 默认值 |
|------|--------|
| `prodId` / `appId` | 从 OrderItem 继承，null 兜底为 `"0"` |
| `createUser` / `modifyUser` | `0L` |
| `deleted` | `0` |

## 验证结果

Maven 编译通过：`BUILD SUCCESS`（7.3s）
