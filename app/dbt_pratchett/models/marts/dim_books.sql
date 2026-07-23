SELECT 
{{ dbt_utils.generate_surrogate_key(['order_of_release'])}} as book_id, 
order_of_release, 
name as book_name, 
year as published_year, 
year_inferred, 
comment
from 
{{ ref('stg_books') }}