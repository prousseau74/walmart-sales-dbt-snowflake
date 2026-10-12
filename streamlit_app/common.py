import pandas as pd
import streamlit as st
from snowflake.snowpark.context import get_active_session

DB = "WALMART_E2E.DBT_PETER"
MARKDOWNS = ["markdown1", "markdown2", "markdown3", "markdown4", "markdown5"]


@st.cache_data
def load_weekly():
    """One row per store per week."""
    session = get_active_session()
    df = session.sql(f"""
        select
            d.full_date, d.year, d.quarter, d.month, d.month_name, d.is_holiday,
            s.store_key, s.store_type, s.store_size,
            sum(f.weekly_sales)  as weekly_sales,
            max(f.temperature)   as temperature,
            max(f.fuel_price)    as fuel_price,
            max(f.cpi)           as cpi,
            max(f.unemployment)  as unemployment,
            max(f.markdown1)     as markdown1,
            max(f.markdown2)     as markdown2,
            max(f.markdown3)     as markdown3,
            max(f.markdown4)     as markdown4,
            max(f.markdown5)     as markdown5
        from {DB}.fct_weekly_sales f
        join {DB}.dim_date  d on f.date_key  = d.date_key
        join {DB}.dim_store s on f.store_key = s.store_key
        group by 1, 2, 3, 4, 5, 6, 7, 8, 9
    """).to_pandas()
    df.columns = df.columns.str.lower()
    df["full_date"] = pd.to_datetime(df["full_date"])
    skip = ("full_date", "store_type", "month_name", "is_holiday")
    num = [c for c in df.columns if c not in skip]
    df[num] = df[num].apply(pd.to_numeric, errors="coerce")
    df["markdown_total"] = df[MARKDOWNS].fillna(0).sum(axis=1)
    df["month_label"] = df["month"].astype(int).astype(str).str.zfill(2)
    return df


@st.cache_data
def load_dept():
    """One row per department per week (all stores combined)."""
    session = get_active_session()
    df = session.sql(f"""
        select f.dept_id, d.full_date, d.year,
               sum(f.weekly_sales) as weekly_sales
        from {DB}.fct_weekly_sales f
        join {DB}.dim_date d on f.date_key = d.date_key
        group by 1, 2, 3
    """).to_pandas()
    df.columns = df.columns.str.lower()
    df["full_date"] = pd.to_datetime(df["full_date"])
    df["weekly_sales"] = pd.to_numeric(df["weekly_sales"], errors="coerce")
    df["dept_id"] = df["dept_id"].astype(int)
    return df


def year_filter(df):
    years = sorted(df["year"].unique())
    chosen = st.sidebar.multiselect("Year", years, default=years)
    out = df[df["year"].isin(chosen)].copy()
    if out.empty:
        st.warning("No data for these filters.")
        st.stop()
    return out


def pad(index, width=2):
    """Zero-pad labels so charts sort them in numeric order."""
    return index.astype(int).astype(str).str.zfill(width)