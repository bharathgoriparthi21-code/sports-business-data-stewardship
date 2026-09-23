-- Cleaned sponsorship impressions: one row per asset per home game.
-- Combines the original vendor delivery with the later backfill/correction file.
-- When both files contain the same asset and game, the later delivery wins.
with deliveries as (
    select *, 1 as delivery_order, 'original' as source_delivery
    from {{ ref('raw_sponsorship_impressions') }}
    union all
    select *, 2 as delivery_order, 'backfill' as source_delivery
    from {{ ref('raw_sponsorship_impressions_backfill') }}
),

ranked as (
    select
        *,
        row_number() over (
            partition by asset_name, game_date
            order by delivery_order desc
        ) as _row_num
    from deliveries
)

select
    asset_name || '|' || cast(game_date as varchar)  as asset_game_key,
    asset_name,
    game_date,
    broadcast_impressions,
    estimated_value,
    source_delivery
from ranked
where _row_num = 1
