import streamlit as st
from common import load_weekly, year_filter, pad

st.title("Markdown Sales by Year and Store")
st.caption("Markdown amounts (markdown1 to markdown5 combined). "
           "The source data has no markdowns before late 2011, so earlier years show 0.")
df = year_filter(load_weekly())

by_year = df.groupby("year")["markdown_total"].sum()
by_year.index = by_year.index.astype(str)
st.subheader("Total markdowns by year")
st.bar_chart(by_year)

years = sorted(df["year"].unique())
yr = st.selectbox("Year for store breakdown", years, index=len(years) - 1)
by_store = df[df["year"] == yr].groupby("store_key")["markdown_total"].sum()
by_store.index = pad(by_store.index)
st.subheader(f"Total markdowns by store, {yr}")
st.bar_chart(by_store)