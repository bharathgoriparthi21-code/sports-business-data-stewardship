-- Staleness check: the sponsorship feed should not trail ticketing by more than
-- var('sponsorship_max_lag_days'). Returns a row if it does.
{{ config(severity='warn') }}

with latest as (
    select
        (select max(game_date) from {{ ref('stg_ticket_sales') }})            as latest_ticket_game,
        (select max(game_date) from {{ ref('stg_sponsorship_impressions') }}) as latest_sponsorship_game
)

select
    *,
    latest_ticket_game - latest_sponsorship_game as lag_days
from latest
where latest_ticket_game - latest_sponsorship_game > {{ var('sponsorship_max_lag_days') }}
