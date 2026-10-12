select
    "Store"::int                                   as store_id,
    "Dept"::int                                    as dept_id,
    try_to_date(to_varchar("Date"))                as sales_date,
    try_to_double(to_varchar("Weekly_Sales"))      as weekly_sales,
    try_to_boolean(to_varchar("IsHoliday"))        as is_holiday
from {{ source('walmart', 'department') }}
