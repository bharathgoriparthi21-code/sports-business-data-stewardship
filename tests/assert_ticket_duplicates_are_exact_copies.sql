-- Resolution of backlog #2: duplicate ticket_ids in the raw file come from vendor
-- re-sends and are safe to collapse ONLY if every copy is identical.
-- Returns any ticket_id whose copies disagree on any field. Those need a human.

select ticket_id, count(*) as copies, count(distinct (game_date, section, price, purchase_timestamp, customer_id)) as distinct_versions
from {{ ref('raw_ticket_sales') }}
group by ticket_id
having count(*) > 1
   and count(distinct (game_date, section, price, purchase_timestamp, customer_id)) > 1
