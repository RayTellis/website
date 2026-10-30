select
    petition_id,
    title,
    state,
    signatures,
    opened_at,
    closed_at,
    date_diff('day', opened_at, current_date)       as days_open,
    government_response_at is not null              as has_response,
    debate_outcome_at is not null                   as was_debated,

    case
        when signatures < 10000  then 10000
        when signatures < 100000 then 100000
    end                                             as next_threshold,

    case
        when signatures < 10000  then 10000  - signatures
        when signatures < 100000 then 100000 - signatures
    end                                             as signatures_to_go,

    case
        when signatures < 10000  then '1. Under 10k'
        when signatures < 100000 then '2. 10k to 100k'
        else                          '3. Over 100k'
    end                                             as signature_band,

    'https://petition.parliament.uk/petitions/' || petition_id as url

from {{ ref('stg_petitions') }}