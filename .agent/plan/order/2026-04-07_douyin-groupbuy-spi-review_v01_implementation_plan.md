# Douyin Groupbuy SPI Review Plan

## Scope
- Review Douyin B-series groupbuy SPI logic against local reference docs

## Read Path
- `B00-团购方案总览.md`
- `B10-团购预下单接口V2-SPI.md`
- `B11-团购发码V2-SPI.md`
- `B20-退款审核SPI.md`
- `B22-退款结果通知SPI.md`
- `B30-团购核销.md`
- `DouyinSpiController`
- `DouyinChannelAdapter`

## Focus
- B10 create-order request/response semantics
- B11 issue-voucher sync/async and certificate/project mapping
- B20 refund-apply response semantics
- B22 refund-notify compatibility with current core refund callback model

## Output
- Findings ordered by severity
- File references to current implementation
- Local reference document paths used for comparison
