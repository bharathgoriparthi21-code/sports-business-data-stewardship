# Resolution log

How each `dbt build` warning was resolved. Principle: fix problems at the right
layer and write the decision down. Never delete a check just to make it quiet, and
never drop rows without a flag.

> **Note on the "business answers" below:** this is a simulation, so the
> confirmations from Ticketing Ops, Partnerships, and Marketing are assumed.
> In a real role, each would be confirmed with the named owner before merging.

| # | Warning | Resolution | Layer | Check now in place |
|---|---------|------------|-------|--------------------|
| 1 | Ticket file had 15 more rows than the vendor manifest | Manifest counts unique tickets, not file rows. Reconcile on `count(distinct ticket_id)`. Missing files now also fail the check. | test | `assert_vendor_row_counts_match_manifest` |
| 2 | 15 duplicate `ticket_id`s | Confirmed every duplicate is an exact copy from a vendor re-send, so collapsing is safe. Uniqueness is enforced in staging, not raw. | test + staging | `assert_ticket_duplicates_are_exact_copies` (fails if copies ever disagree) |
| 3 | 20 tickets missing `price` | Null = not sent; comps arrive as 0.00 *(assumed Ticketing Ops answer)*. Rows kept and flagged `is_missing_price`. | raw test | `missing_rate_below` 2% |
| 4 | 11 tickets missing `customer_id` | Walk-up / cash sales *(assumed)*. Kept, flagged `is_missing_customer`, excluded from campaign attribution. | raw test | `missing_rate_below` 1% |
| 5 | 3 nonstandard `section` labels | Added `section_label_mapping` seed. Staging joins through it. A new unmapped label now fails the build. | seed + staging | `relationships` to mapping table |
| 6 | Sponsorship feed stale after Jan 31 | Vendor delivered a backfill for Feb-Apr games *(simulated)*. Staging merges deliveries; later delivery wins. Added to manifest. | new seed + staging | `assert_sponsorship_data_not_stale` now passes |
| 7 | 1 sponsorship row missing `estimated_value` | Vendor restated the row in the backfill. Completeness enforced after merge. | staging | `not_null` on `stg_sponsorship_impressions.estimated_value` |
| 8 | Clicks without opens above 1% | Redefined `is_opened` to include inferred opens (a click proves an open). Pixel-only opens kept as `is_pixel_open` to match the platform dashboard. Open rate moves from 37.9% to 38.4%. | staging | `assert_clicks_have_opens` (strict, row-level) |

**Result:** 35 checks, 0 warnings, 0 errors. Verified the checks still fire by
injecting an unmapped section label, which failed the build as expected.

**Still open:** #9 (72-hour open window), #10 (timestamp timezone), #11 (PII access
review). Those are definition and access questions, not failing checks.
