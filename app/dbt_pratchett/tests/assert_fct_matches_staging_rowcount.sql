with fct as (
    select count(*) as n from {{ ref('fct_bluesky_posts') }}
),
stg as (
    select count(distinct post_uri) as n from {{ ref('stg_bluesky_posts') }}
)
select
    fct.n as fct_count,
    stg.n as stg_count
from fct
cross join stg
where fct.n != stg.n