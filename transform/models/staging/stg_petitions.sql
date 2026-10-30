with source as (
    select * from {{ source('raw', 'petitions') }}
),

parsed as (
    select
        id                                                         as petition_id,
        payload::json ->> '$.attributes.action'                    as title,
        payload::json ->> '$.attributes.background'                as background,
        payload::json ->> '$.attributes.state'                     as state,
        try_cast(payload::json ->> '$.attributes.signature_count' as integer)        as signatures,
        try_cast(payload::json ->> '$.attributes.opened_at' as timestamptz)          as opened_at,
        try_cast(payload::json ->> '$.attributes.closed_at' as timestamptz)          as closed_at,
        try_cast(payload::json ->> '$.attributes.government_response_at' as timestamptz) as government_response_at,
        try_cast(payload::json ->> '$.attributes.debate_outcome_at' as timestamptz)  as debate_outcome_at
    from source
)

select *
from parsed
-- the API pages can shift while we download, so keep one row per petition
qualify row_number() over (partition by petition_id order by signatures desc) = 1