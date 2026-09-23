-- Cleaned ticket sales: one row per ticket_id.
-- Issues are FLAGGED, not silently dropped, so downstream users can see them.
with source as (
    select * from {{ ref('raw_ticket_sales') }}
),

deduplicated as (
    -- Duplicates are verified exact copies (tests/assert_ticket_duplicates_are_exact_copies.sql)
    select
        *,
        row_number() over (
            partition by ticket_id
            order by purchase_timestamp
        ) as _row_num
    from source
)

select
    d.ticket_id,
    d.game_date,
    m.standard_section   as section,
    d.price,
    d.purchase_timestamp,
    d.customer_id,
    d.price is null        as is_missing_price,
    d.customer_id is null  as is_missing_customer
from deduplicated d
left join {{ ref('section_label_mapping') }} m
    on d.section = m.raw_label
where d._row_num = 1
