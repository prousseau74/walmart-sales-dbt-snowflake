select store_key, date_key, dept_id, count(*) as n
from {{ ref('fct_weekly_sales') }}
group by 1, 2, 3
having count(*) > 1
