with weeks as (
    select
        feature_date as full_date,
        boolor_agg(is_holiday) as is_holiday
    from {{ ref('stg_store_features') }}
    group by feature_date
)

select
    full_date                as date_key,
    full_date,
    year(full_date)          as year,
    quarter(full_date)       as quarter,
    month(full_date)         as month,
    monthname(full_date)     as month_name,
    weekofyear(full_date)    as week_of_year,
    is_holiday
from weeks
