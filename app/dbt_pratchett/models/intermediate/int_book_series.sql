SELECT 
order_of_release,
TRIM(flattened_series) as series
 FROM {{ ref('stg_books') }}
 INNER JOIN UNNEST((
  SPLIT(
    REPLACE(
      (REPLACE(series,'(','/')),
      ')','/'
    ),'/'
  )
)) AS flattened_series
WHERE TRIM(flattened_series) !=''