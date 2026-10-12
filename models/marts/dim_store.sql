select
    store_id   as store_key,
    store_type,
    store_size
from {{ ref('stg_stores') }}
