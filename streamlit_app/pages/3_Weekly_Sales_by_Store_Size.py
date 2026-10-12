import streamlit as st
from common import load_weekly, year_filter, pad

st.title("Weekly Sales by Store Size")
df = year_filter(load_weekly())

by_size = df.groupby("store_size")["weekly_sales"].mean()
by_size.index = pad(by_size.index, 6)

st.caption("Average weekly sales per store, by store size (square feet)")
st.bar_chart(by_size)
st.dataframe(by_size.round(0))