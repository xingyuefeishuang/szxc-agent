# Douyin B10 Fix Plan

## Goal
- Tighten Douyin groupbuy pre-create order behavior around SKU mapping and failed SKU reporting.

## Scope
- `DouyinChannelAdapter.handleCreateOrder(...)`
- `assembleGroupbuyItems(...)`
- `resolveSkuMapping(...)`

## Changes
- Use real `o_channel_sku_mapping` lookup
- Stop using numeric fallback parsing for external SKU/SPU ids
- Collect failed SKU ids
- Reject B10 create-order when SKU mapping is missing, and return `fail_sku_id_list`
- Use sub-SKU order item counts instead of hard-coded quantity `1`

## Boundaries
- No partial-success order creation in this task
- No B11 async voucher issuance changes in this task
