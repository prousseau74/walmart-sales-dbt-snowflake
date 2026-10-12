import streamlit as st
from common import load_weekly, year_filter

st.title("Weekly Sales by Store Type")
df = year_filter(load_weekly())

left, right = st.columns(2)
with left:
    st.subheader("Total sales")
    st.bar_chart(df.groupby("store_type")["weekly_sales"].sum())
with right:
    st.subheader("Average weekly sales per store")
    st.bar_chart(df.groupby("store_type")["weekly_sales"].mean())

st.subheader("Total weekly sales over time")
over_time = df.pivot_table(index="full_date", columns="store_type",
                           values="weekly_sales", aggfunc="sum")
st.line_chart(over_time)