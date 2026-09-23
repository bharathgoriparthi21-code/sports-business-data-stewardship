-- Vendor file exchange check: does what we loaded match what the vendor says it sent?
-- Resolution of backlog #1: the ticketing vendor's manifest counts UNIQUE tickets,
-- not file rows. Re-sent duplicates are expected (see assert_ticket_duplicates_are_exact_copies),
-- so ticketing is reconciled on count(distinct ticket_id).
-- Returns one row per file whose loaded count differs from the manifest.

with actual as (
    select 'raw_ticket_sales' as file_name, count(distinct ticket_id) as actual_row_count from {{ ref('raw_ticket_sales') }}
    union all
    select 'raw_campaign_sends', count(*) from {{ ref('raw_campaign_sends') }}
    union all
    select 'raw_sponsorship_impressions', count(*) from {{ ref('raw_sponsorship_impressions') }}
    union all
    select 'raw_sponsorship_impressions_backfill', count(*) from {{ ref('raw_sponsorship_impressions_backfill') }}
)

select
    m.file_name,
    m.expected_row_count,
    a.actual_row_count,
    a.actual_row_count - m.expected_row_count as difference
from {{ ref('vendor_file_manifest') }} m
left join actual a using (file_name)
where a.actual_row_count is distinct from m.expected_row_count  -- also catches files missing entirely
