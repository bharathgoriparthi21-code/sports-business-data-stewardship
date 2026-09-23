-- Vendor file exchange check: does what we loaded match what the vendor says it sent?
-- Returns one row per file whose loaded row count differs from the manifest.
{{ config(severity='warn') }}

with actual as (
    select 'raw_ticket_sales' as file_name, count(*) as actual_row_count from {{ ref('raw_ticket_sales') }}
    union all
    select 'raw_campaign_sends', count(*) from {{ ref('raw_campaign_sends') }}
    union all
    select 'raw_sponsorship_impressions', count(*) from {{ ref('raw_sponsorship_impressions') }}
)

select
    m.file_name,
    m.expected_row_count,
    a.actual_row_count,
    a.actual_row_count - m.expected_row_count as difference
from {{ ref('vendor_file_manifest') }} m
join actual a using (file_name)
where a.actual_row_count <> m.expected_row_count
