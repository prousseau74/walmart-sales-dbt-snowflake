select
    "Store"::int as store_id,
    "Type"       as store_type,
    "Size"::int  as store_size
from {{ source('walmart', 'stores') }}
