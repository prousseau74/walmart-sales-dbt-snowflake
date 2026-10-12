import streamlit as st
from common import load_weekly, year_filter

st.title("Weekly Sales by CPI")
df = year_filter(load_weekly()).dropna(subset=["cpi"])
df["cpi_bucket"] = (df["cpi"] // 10 * 10).astype(int).astype(str).str.zfill(3)

by_cpi = df.groupby("cpi_bucket")["weekly_sales"].mean()
st.caption("Average weekly sales per store. A bucket of 130 means a CPI from 130 to 139.")
st.bar_chart(by_cpi)
st.dataframe(by_cpi.round(0))