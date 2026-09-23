-- Logical consistency: a click without an open is possible (image blocking) but
-- should be rare. Warn if it exceeds 1% of clicks.
{{ config(severity='warn') }}

select
    count(*) filter (where is_click_without_open)                   as clicks_without_open,
    count(*) filter (where is_clicked)                              as total_clicks
from {{ ref('stg_campaign_sends') }}
having count(*) filter (where is_click_without_open)
     > 0.01 * count(*) filter (where is_clicked)
