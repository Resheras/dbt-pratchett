with raw_year as (SELECT 
column_1,
column_2,
column_3,
column_4,
column_5,
REGEXP_CONTAINS(column_3, r'^(19|20)\d{2}$') as is_year 
 FROM {{ source('raw-pratchett', 'discworld_books') }} 
),
columns_fixed as (SELECT column_1 as order_of_release,
column_2 as name,
IF(is_year, column_3, null) as year,
NOT(is_year) as year_inferred,
IF(is_year, column_4, column_3) as series,
IF(is_year, column_5, column_4) as comment,
FROM raw_year),
years_filled as 
(SELECT order_of_release,
name,
ifnull(year, 
      LAST_VALUE(year IGNORE NULLS) OVER(ORDER BY order_of_release ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) as year,
year_inferred,
series,
comment
FROM columns_fixed)
SELECT
order_of_release,
{{ clean_whitespace('name') }} as name,
CAST(year as INT) as year,
year_inferred,
{{ clean_whitespace('series') }} as series,
{{ clean_whitespace(strip_footnotes('comment')) }} as comment,
FROM
years_filled
