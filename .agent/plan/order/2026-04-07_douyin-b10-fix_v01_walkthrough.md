# Douyin B10 Fix Walkthrough

## What Changed
- B10 create-order now records failed external SKU ids during assembly
- Missing mapping now blocks order creation instead of silently building a degraded internal order
- Groupbuy sub-SKU quantity is no longer hard-coded to `1`
- SKU mapping now comes from `o_channel_sku_mapping`

## Result
- The adapter is closer to B10 document semantics
- The internal order core is less likely to receive `0` or fake mapped SKU/SPU ids
- `fail_sku_id_list` now has a real source for rejection responses

## Remaining Gaps
- Partial-success create-order is still not implemented
- B11 async issuance and project-id consistency are still pending
