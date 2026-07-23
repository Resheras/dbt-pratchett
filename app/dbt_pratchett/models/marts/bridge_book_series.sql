select 
{{ dbt_utils.generate_surrogate_key(['book_id', 'series_id']) }} as book_series_id,
book_id, 
series_id
from 
{{ ref('int_book_series') }} bs join 
{{ ref('dim_books') }} bo
on bs.order_of_release = bo.order_of_release
join
{{ ref('dim_series') }} se 
on bs.series = se.series_name
