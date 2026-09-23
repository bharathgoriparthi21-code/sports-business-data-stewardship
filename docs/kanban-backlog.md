# Starter backlog

Create each of these as a GitHub issue (use the "Stewardship item" template),
put them on a GitHub Projects board with columns Backlog / In Progress / Review / Done,
and set the In Progress WIP limit to 2. Close each with its own small PR.

Each one traces to a warning that `dbt build` already reports.

| # | Item | Type | Source of the signal |
|---|------|------|----------------------|
| 1 | Ticketing file has 15 more rows than the vendor manifest | vendor file | `assert_vendor_row_counts_match_manifest` |
| 2 | 15 duplicate ticket_ids from a vendor re-send: document dedup rule | data quality | `unique_raw_ticket_sales_ticket_id` |
| 3 | 20 tickets missing price: confirm null vs comp ticket with Ticketing Ops | definition | `not_null_raw_ticket_sales_price` |
| 4 | Tickets with no customer_id: can they be attributed to campaigns? | data quality | `not_null_raw_ticket_sales_customer_id` |
| 5 | Inconsistent section labels ("sec 100", "Loge ") from vendor | data quality | `accepted_values_raw_ticket_sales_section` |
| 6 | Sponsorship feed stopped after Jan 31: mark dataset stale, contact vendor | stale dataset | `assert_sponsorship_data_not_stale` |
| 7 | One sponsorship row missing estimated_value | data quality | `not_null_raw_sponsorship_impressions_estimated_value` |
| 8 | Clicks recorded without opens: document why and set tolerance | definition | `assert_clicks_have_opens` |
| 9 | Confirm 72-hour open window with Marketing (`is_opened` is draft) | definition | `meta.open_question` |
| 10 | Confirm purchase_timestamp timezone | definition | `meta.definition_status: draft` |
| 11 | Access review: who should see PII columns (customer_id)? | access review | `meta.pii` |
