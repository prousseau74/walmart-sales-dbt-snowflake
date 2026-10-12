select
    "Store"::int                                   as store_id,
    try_to_date(to_varchar("Date"))                as feature_date,
    try_to_double(to_varchar("Temperature"))       as temperature,
    try_to_double(to_varchar("Fuel_Price"))        as fuel_price,
    try_to_double(to_varchar("MarkDown1"))         as markdown1,
    try_to_double(to_varchar("MarkDown2"))         as markdown2,
    try_to_double(to_varchar("MarkDown3"))         as markdown3,
    try_to_double(to_varchar("MarkDown4"))         as markdown4,
    try_to_double(to_varchar("MarkDown5"))         as markdown5,
    try_to_double(to_varchar("CPI"))               as cpi,
    try_to_double(to_varchar("Unemployment"))      as unemployment,
    try_to_boolean(to_varchar("IsHoliday"))        as is_holiday
from {{ source('walmart', 'fact') }}
