SELECT 
post_uri, order_of_release
 FROM {{ ref('stg_bluesky_posts') }} 
 CROSS JOIN {{ ref('stg_books') }}
 WHERE REGEXP_CONTAINS(LOWER(text), r'\b' || LOWER(name) || r'\b')