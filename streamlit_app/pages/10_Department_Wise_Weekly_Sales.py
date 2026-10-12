import streamlit as st
from common import load_dept, year_filter, pad

st.title("Department Wise Weekly Sales")
df = year_filter(load_dept())

top = df.groupby("dept_id")["weekly_sales"].sum().nlargest(15)
default = [int(d) for d in top.index[:3]]
top.index = pad(top.index)
st.subheader("Top 15 departments by total sales")
st.bar_chart(top)

depts = sorted(df["dept_id"].unique())
chosen = st.multiselect("Departments to compare over time", depts, default=default)
if chosen:
    lines = (df[df["dept_id"].isin(chosen)]
             .pivot_table(index="full_date", columns="dept_id",
                          values="weekly_sales", aggfunc="sum"))
    lines.columns = lines.columns.astype(str)
    st.line_chart(lines)