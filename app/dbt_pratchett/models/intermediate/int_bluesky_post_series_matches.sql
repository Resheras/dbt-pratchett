SELECT
  DISTINCT post_uri, series
FROM {{ ref('stg_bluesky_posts') }}
CROSS JOIN {{ ref('int_book_series') }}
WHERE REGEXP_CONTAINS(LOWER(text), r'\b' || LOWER(series) || r'\b')