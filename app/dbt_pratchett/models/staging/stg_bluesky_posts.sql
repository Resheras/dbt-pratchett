with counted_rows as (SELECT  
post_uri,
author_did,
author_handle,
text,
created_at,
permalink, 
row_number() over (partition by post_uri ORDER BY created_at) as row_nmb
FROM {{ source('raw-pratchett', 'bluesky_posts') }})
select 
post_uri,
author_did,
author_handle,
{{ clean_whitespace('text')}} as text,
created_at,
permalink
from counted_rows
where row_nmb = 1
