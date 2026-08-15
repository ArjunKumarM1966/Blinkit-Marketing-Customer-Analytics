# Blinkit Marketing & Customer Analytics
End-to-end data analytics project on Blinkit's marketing performance, customer orders, and delivery operations — using **SQL** for data querying, **Python (Pandas/Seaborn)** for exploratory analysis, and **Power BI** for interactive dashboards.

## 📌 Project Overview
This project analyzes Blinkit's marketing campaigns, customer orders, delivery performance, and customer feedback to answer key business questions like:

- Which marketing channels and campaigns drive the best ROAS?
- How does delivery delay affect customer satisfaction?
- Which cities/stores generate the most revenue?
- What % of customers are repeat buyers vs one-time?
- Is marketing-reported revenue consistent with actual order revenue?

The goal was to go from raw multi-table data → cleaned relational data → SQL business analysis → Python EDA → interactive Power BI dashboard**.

## 🗂️ Dataset
6 related tables (~5,000–5,400 rows each):

| Table | Description |
|---|---|
| `blinkit_customers` | Customer profile, segment, registration date |
| `blinkit_orders` | Order details, delivery status, payment method |
| `blinkit_order_items` | Line-item level product quantity & price |
| `blinkit_products` | Product catalog with category, brand, margin |
| `blinkit_customer_feedback` | Ratings, sentiment, feedback category |
| `blinkit_marketing_performance` | Campaign spend, clicks, conversions, ROAS |

## 🛠️ Tools & Tech Stack

- Excel – initial data formatting & cleanup
- SQL (MySQL)** – data querying & business analysis
- Python – Pandas, NumPy, Matplotlib, Seaborn (EDA)
- Power BI – interactive dashboard & reporting
- Jupyter Notebook – analysis documentation

## Data Preparation & Database Setup
- - Created database and loaded 6 raw tables
- Fixed column data types (`date`, `datetime`) using `ALTER TABLE`
- Added Primary Keys on all tables
- Added Foreign Key relationships:
  - `orders → customers`
  - `order_items → orders, products`
  - `customer_feedback → orders`

## 📊 Data Analysis Work (Core Focus)
### 1. Excel – Initial Data Check
Before SQL/Python analysis, raw CSV files were quickly reviewed in Excel to check for data quality issues (missing values, obvious mismatches, inconsistent formats). No major issues were found — data was clean and consistent, so no manual correction was needed.

### 2. SQL Analysis (MySQL)
Business questions solved using SQL, including window functions, joins, and CTEs:

- **Marketing Performance:** Channel-wise ROAS, CTR, CPC, CPA, top 5 campaigns by ROAS, underperforming campaigns (ROAS < 1)
- **Revenue Reconciliation:** Marketing-reported revenue vs actual order revenue (variance analysis)
- **Customer Analytics:** Repeat vs one-time customers, top 10 customers by spend, customers above overall AOV (subquery)
- **Operations:** City-wise & store-wise revenue, order cancellation rate, top stores per city (`DENSE_RANK`)
- **Trends:** Monthly revenue trend, MoM growth % (`LAG` window function), running cumulative revenue
- **Customer Satisfaction:** Average rating per store, feedback vs target audience analysis

📁 SQL file: `Blinkit_SQL_Analysis.sql`

### 3. Python EDA
- Data cleaning: datatype conversion, null/inf handling
- **Feedback analysis:** rating distribution, low-rating reason breakdown, sentiment analysis
- **Delivery analysis:** on-time vs delayed orders, average delay (mins), impact of delay on customer rating
- **Correlation analysis:** marketing metrics heatmap (spend, revenue, clicks, conversions, ROAS)
- **Visualizations:** top 10 product categories by revenue, campaign revenue trend over time, ad spend vs conversions (channel-wise scatter)

📁 Notebook: `Python_Analysis.ipynb`

### 4. Power BI Dashboard (2 Pages)

**Page 1 – Sales & Operations Overview**
- KPIs: Total revenue (₹11.01M), order count (5K), AOV (₹2.20K), on-time delivery rate (30.6%)
- Monthly revenue trend, delivery status distribution, payment method breakdown
- Top revenue-generating cities, store performance table, geo map by city

**Page 2 – Marketing Performance & Campaign ROI**
- KPIs: Total revenue (₹32.19M), spend (₹16.32M), clicks, conversions, ROAS (2.74)
- Revenue by channel, audience segment performance, campaign-wise revenue contribution
- Detailed campaign performance matrix (clicks, conversions, revenue, spend, avg ROAS)

📁 File: `Blinkit_Dashboard.pbix`
📸 Screenshots: `/screenshots/`

## 🔑 Key Insights

- **Late delivery is common** (69% of orders delayed) but **doesn't significantly impact ratings** (3.35 avg on-time vs 3.34 delayed) — customer dissatisfaction is driven more by *Delivery, Product Quality & Customer Service* issues than delay alone.
- Marketing spend and revenue show **near-zero correlation** with clicks/conversions at the campaign level — suggesting spend efficiency needs deeper channel-level review.
- **Dairy & Breakfast, Pharmacy, and Fruits & Vegetables** are the top revenue-generating categories.
- Repeat customer % and top-spender segments highlight where retention efforts should focus.

## 📁 Project Structure

```
Blinkit-Marketing-Customer-Analytics/
│
├── SQL/
│   └── Blinkit_SQL_Analysis.sql
├── Python/
│   └── Python_Analysis.ipynb
├── PowerBI/
│   └── Blinkit_Dashboard.pbix
├── screenshots/
│   ├── sales_operations_overview.png
│   └── marketing_performance_roi.png
└── README.md

## 🚀 How to Use

1. Run `Blinkit_SQL_Analysis.sql` on MySQL to recreate the schema & explore business queries.
2. Open `Python_Analysis.ipynb` in Jupyter to see the EDA and visualizations.
3. Open `Blinkit_Dashboard.pbix` in Power BI Desktop to interact with the dashboard.














