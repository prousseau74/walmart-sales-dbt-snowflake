select
    s.store_id      as store_key,
    s.sales_date    as date_key,
    s.dept_id,
    s.weekly_sales,
    f.temperature,
    f.fuel_price,
    f.markdown1,
    f.markdown2,
    f.markdown3,
    f.markdown4,
    f.markdown5,
    f.cpi,
    f.unemployment
from {{ ref('stg_department_sales') }} s
left join {{ ref('stg_store_features') }} f
    on  s.store_id   = f.store_id
    and s.sales_date = f.feature_date
