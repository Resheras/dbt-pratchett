select distinct {{ dbt_utils.generate_surrogate_key(['series'])}} as series_id, 
series as series_name
from {{ ref('int_book_series') }}