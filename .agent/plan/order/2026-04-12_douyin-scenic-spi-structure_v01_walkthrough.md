# Douyin Scenic SPI Structure v01 Walkthrough

## What Changed

- Deleted `channel/douyin/solution/common/DouyinScenicSolutionSupport`.
- Rebuilt `ScenicGroupbuyDouyinSolution` as the owner of:
  - B10 create order
  - B11 issue voucher
  - B20 refund apply
  - B22 refund notify
- Rebuilt `ScenicCalendarTicketDouyinSolution` as the owner of:
  - A10 can buy
  - A11 create order
  - A14 pay notify
  - A12 query order
  - A21 issue voucher
  - A30 cancel order
  - A31 refund apply
  - A33 refund notify
- Rebuilt scenic SPI controllers with explicit document comments and Swagger summaries such as:
  - `团购预下单 V2 (B10)`
  - `团购发码 V2 (B11)`
  - `日历票发放凭证 (A21)`
- Added `DouyinOrderChannelAdapter` so抖音渠道回写不再依赖 scenic business support.

## Verification

- Searched for remaining `DouyinScenicSolutionSupport` references in `plt-order-core`: none remain.
- `mvn clean compile -DskipTests` was attempted in `plt-core-service/plt-order-service`.
- The build did not reach `plt-order-core` compilation because the local Maven/JDK environment failed earlier with `无效的目标发行版: 17`.

## Follow-up

- Once the local JDK is aligned to Java 17, rerun module compilation to verify the new scenic SPI split end-to-end.
