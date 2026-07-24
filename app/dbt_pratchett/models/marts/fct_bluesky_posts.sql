{{ config(
    materialized='incremental',
    unique_key='post_uri',
    incremental_strategy='merge',
    partition_by={'field': 'created_at', 'data_type': 'timestamp', 'granularity': 'day'}
) }}

with books_counts as (
    SELECT post_uri,
    count(order_of_release) as books_count
    FROM {{ ref('int_bluesky_post_book_matches') }}
    GROUP BY post_uri
),
series_counts as (
    SELECT post_uri,
    count(series) as series_count
    FROM {{ ref('int_bluesky_post_series_matches') }}
    GROUP BY post_uri
)
SELECT p.post_uri,
author_did, 
author_handle, 
text, 
created_at, 
permalink,
coalesce(books_count,0) as books_matches_count,
coalesce(series_count,0) as series_matches_count
FROM {{ ref('stg_bluesky_posts') }} p 
LEFT JOIN books_counts b on p.post_uri = b.post_uri
LEFT JOIN series_counts s on p.post_uri = s.post_uri

    {% if is_incremental() %}
    where created_at >= (
        select timestamp_sub(max(created_at), interval 3 day)
        from {{ this }}
    )
    {% endif %}