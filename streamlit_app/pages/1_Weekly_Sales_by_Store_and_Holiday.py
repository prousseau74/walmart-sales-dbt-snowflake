import streamlit as st
from common import load_weekly, year_filter, pad

st.title("Weekly Sales by Store and Holiday")
df = year_filter(load_weekly())
df["week_type"] = df["is_holiday"].map({True: "Holiday", False: "Non-holiday"})

p = df.pivot_table(index="store_key", columns="week_type",
                   values="weekly_sales", aggfunc="mean")
p.index = pad(p.index)

st.caption("Average weekly sales per store")
st.bar_chart(p)
st.dataframe(p.round(0))
