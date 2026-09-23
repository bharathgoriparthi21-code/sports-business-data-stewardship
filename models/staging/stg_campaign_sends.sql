-- Cleaned campaign sends: one row per email sent.
select
    send_id,
    campaign_id,
    customer_id,
    email_sent_date,
    opened_flag = 1                          as is_opened,
    clicked_flag = 1                         as is_clicked,
    (clicked_flag = 1 and opened_flag = 0)   as is_click_without_open
from {{ ref('raw_campaign_sends') }}
