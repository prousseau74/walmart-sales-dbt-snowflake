import streamlit as st
from common import load_weekly, year_filter

st.title("Weekly Sales by Store Type and Month")
df = year_filter(load_weekly())

p = df.pivot_table(index="month_label", columns="store_type",
                   values="weekly_sales", aggfunc="mean")

st.caption("Average weekly sales per store. Month 01 is January.")
st.bar_chart(p)
st.dataframe(p.round(0))