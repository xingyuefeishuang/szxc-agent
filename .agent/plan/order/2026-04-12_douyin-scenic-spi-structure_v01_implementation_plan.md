# Douyin Scenic SPI Structure v01

## Goal

- Keep `/spi/douyin/**` as the统一外部前缀
- Keep SPI endpoint comments with document-facing names like `团购预下单 V2 (B10)`
- Remove the shared scenic business support layer
- Split scenic groupbuy and scenic calendar-ticket business orchestration into their own solution classes

## Planned Changes

1. Replace `DouyinScenicSolutionSupport` with scenario-owned implementations.
2. Move景区团购编排到 `ScenicGroupbuyDouyinSolution`.
3. Move景区日历票编排到 `ScenicCalendarTicketDouyinSolution`.
4. Keep only truly shared SPI technical capability in `DouyinSpiSignatureService`.
5. Add a dedicated `DouyinOrderChannelAdapter` for channel callback integration.
6. Restore SPI controller comments and Swagger summaries with B10/B11/A10/A21 style identifiers.
7. Run compile verification for `plt-order-service`.

## Notes

- Business helpers are intentionally duplicated between groupbuy and calendar-ticket where necessary.
- Shared business support is intentionally removed to keep scenario boundaries explicit.
