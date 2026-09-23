-- Cleaned ticket sales: one row per ticket_id.
-- Issues are FLAGGED, not silently dropped, so downstream users can see them.
with source as (
    select * from {{ ref('raw_ticket_sales') }}
),

deduplicated as (
    select
        *,
        row_number() over (
            partition by ticket_id
            order by purchase_timestamp
        ) as _row_num
    from source
)

select
    ticket_id,
    game_date,
    upper(trim(replace(lower(section), 'sec ', ''))) as section,
    price,
    purchase_timestamp,
    customer_id,
    price is null        as is_missing_price,
    customer_id is null  as is_missing_customer
from deduplicated
where _row_num = 1
