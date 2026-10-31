import streamlit as st
from common import load_weekly, year_filter

st.title("Weekly Sales by Temperature and Year")
df = year_filter(load_weekly()).dropna(subset=["temperature"])

# 10-degree bands; anything below 10°F falls into the lowest band
df["temp_band"] = (df["temperature"].clip(lower=0) // 10 * 10).astype(int)
df["temp_label"] = df["temp_band"].astype(str).str.zfill(3)

p = df.pivot_table(index="temp_label", columns="year",
                   values="weekly_sales", aggfunc="mean")
p.columns = p.columns.astype(int).astype(str)

st.caption("Average weekly sales per store by temperature band (°F). "
           "060 means 60–69°F; 000 includes anything below 10°F.")
st.bar_chart(p)
st.dataframe(p.round(0))
