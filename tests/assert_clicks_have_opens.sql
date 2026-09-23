-- Logical consistency: under the inferred-open definition, every clicked email
-- must count as opened. Returns any row that breaks that rule.
-- (Resolution of backlog #8. Pixel-only opens remain available as is_pixel_open.)

select *
from {{ ref('stg_campaign_sends') }}
where is_clicked and not is_opened
