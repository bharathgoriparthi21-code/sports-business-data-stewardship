-- Cleaned sponsorship impressions: one row per asset per home game.
select
    asset_name || '|' || cast(game_date as varchar)  as asset_game_key,
    asset_name,
    game_date,
    broadcast_impressions,
    estimated_value,
    estimated_value is null                          as is_missing_value
from {{ ref('raw_sponsorship_impressions') }}
