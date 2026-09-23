-- Cleaned campaign sends: one row per email sent.
-- Opens are tracked with an image pixel, which image-blocking clients never load.
-- A click proves the email was opened, so is_opened counts an open when EITHER
-- the pixel fired or a link was clicked ("inferred open").
select
    send_id,
    campaign_id,
    customer_id,
    email_sent_date,
    (opened_flag = 1 or clicked_flag = 1)    as is_opened,
    opened_flag = 1                          as is_pixel_open,
    clicked_flag = 1                         as is_clicked,
    (clicked_flag = 1 and opened_flag = 0)   as is_click_without_open
from {{ ref('raw_campaign_sends') }}
