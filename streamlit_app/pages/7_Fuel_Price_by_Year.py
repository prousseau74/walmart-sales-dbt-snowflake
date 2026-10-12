import streamlit as st
from common import load_weekly, year_filter

st.title("Fuel Price by Year")
df = year_filter(load_weekly()).dropna(subset=["fuel_price"])

by_year = df.groupby("year")["fuel_price"].mean()
by_year.index = by_year.index.astype(str)
st.subheader("Average fuel price by year")
st.bar_chart(by_year)

st.subheader("Average fuel price by week")
st.line_chart(df.groupby("full_date")["fuel_price"].mean())