# Douyin Groupbuy SPI Review Walkthrough

## What Was Reviewed
- Groupbuy SPI docs under `.agent/references/ota/douyin/`
- `DouyinSpiController`
- `DouyinChannelAdapter`

## Main Conclusions
- The main risks are in adapter semantics rather than controller routing.
- Current groupbuy implementation has weak project/certificate mapping consistency across create, issue, refund, and verify-related flows.
- B11 currently behaves as synchronous voucher issuance only and does not really support the documented async mode.
