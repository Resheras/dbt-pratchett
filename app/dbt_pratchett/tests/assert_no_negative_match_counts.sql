select
    post_uri,
    books_match_count,
    series_match_count
from {{ ref('fct_bluesky_posts') }}
where books_match_count < 0
   or series_match_count < 0