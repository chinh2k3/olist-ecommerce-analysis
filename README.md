# 🛒 Olist E-Commerce — End-to-End Data Pipeline & Analytics Project

A self-initiated end-to-end data project built on the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). The project covers the full data lifecycle: raw ingestion → staging → data warehouse (star schema) → analytics-ready layer, with exploratory analysis to surface actionable insights on customer satisfaction.

---

## 🗂️ Repository Structure

```
Olist Data Analysis/
├── data/
│   ├── raw/                                  # 9 original CSVs from Kaggle + ML-ready file
│   │       olist_brazil_ml.csv               # Joined & enriched dataset for modeling
│   │       olist_customers_dataset.csv
│   │       olist_geolocation_dataset.csv
│   │       olist_orders_dataset.csv
│   │       olist_order_items_dataset.csv
│   │       olist_order_payments_dataset.csv
│   │       olist_order_reviews_dataset.csv
│   │       olist_products_dataset.csv
│   │       olist_sellers_dataset.csv
│   │       product_category_name_translation.csv
│   └── processed/
│           olist_preprocessed.csv            # Feature-engineered output for modeling
│
├── logs/
│       pipeline_YYYYMMDD_HHMMSS.log          # Auto-generated run log per execution
│
├── notebook/
│       EDA_Olist_Brazil.ipynb                # Exploratory analysis & insights
│       Preprocessing_Olist.ipynb             # Feature engineering
│       Model_Olist.ipynb                     # Classification model (supplementary)
│
├── sql/
│   ├── validation/                           # Raw layer: type fixes, PKs, relationships, per-table overviews
│   │       00.Alter_raw_datatype.sql
│   │       01.create_primary_key.sql
│   │       02.create_relationship_table.sql
│   │       03–10.overview_olist_*.sql
│   │
│   ├── staging/                              # Staging layer: dedup, casting, business logic
│   │       stg_customer.sql
│   │       stg_geolocation.sql
│   │       stg_orders.sql
│   │       stg_order_items.sql
│   │       stg_payment.sql
│   │       stg_product.sql
│   │       stg_reviews.sql
│   │       stg_seller.sql
│   │
│   ├── dims/                                 # Dimension tables
│   │       dim_customer.sql
│   │       dim_date.sql
│   │       dim_product.sql
│   │       dim_seller.sql
│   │
│   ├── facts/                                # Fact tables
│   │       cte_agg.sql                       # Shared aggregation CTEs
│   │       fact_order.sql
│   │       fact_order_items.sql
│   │
│   ├── olist_dwh_star_schema/                # Analytics queries on top of DWH
│   │       08.olist_star_schema_ddl.sql      # Full schema DDL
│   │       00–07.*.sql                       # Revenue, geography, product, review, payment, seller, advanced
│   │
│   └── features/
│           ML_Feature_Selection.sql          # Feature extraction layer for modeling
│
├── src/
│       insert_raw.py                         # Raw ingestion: CSV → raw schema (MySQL)
│       ETL_Funtion.py                        # Orchestrator & shared ETL utilities
│
└── README.md
```

---

## 🏗️ Pipeline Design

### Architecture Overview

```
Raw CSVs (9 tables)
      │
      ▼
[insert_raw.py]  ──────────►  raw schema       (as-is ingestion, no transformation)
                                    │
                                    ▼
                          [staging SQL scripts] (dedup · type casting · business logic)
                          Temp tables → Permanent staging tables
                                    │
                                    ▼
                          [DWH scripts]  ──────►  olist_dwh  (star schema, analytics-ready)
                                    │
                                    ▼
                          [ML feature layer]  ──►  Downstream modeling
```

### Design Principles

**SQL-first, Python-thin**: All transformation logic lives in `.sql` files. Python acts as a thin orchestration layer — calling, sequencing, and logging — not embedding business logic in code. This keeps transformations readable, version-controllable, and easy to hand off.

**Idempotent loads**: Every pipeline step is re-runnable. Staging and DWH tables use `TRUNCATE` + full reload, so re-running from any step is safe and predictable.

**Modular orchestrator**: New steps are added by appending one entry to the `PIPELINE` list — no rewiring of control flow.

```python
PIPELINE = [
    {"name": "insert_raw",   "fn": run_insert_raw},
    {"name": "stg_orders",   "fn": run_sql, "file": "staging/stg_orders.sql"},
    {"name": "stg_reviews",  "fn": run_sql, "file": "staging/stg_reviews.sql"},
    # ...
    {"name": "dim_customer", "fn": run_sql, "file": "dwh/dim_customer.sql"},
    {"name": "fact_orders",  "fn": run_sql, "file": "dwh/fact_orders.sql"},
]
```

### Notable Engineering Decisions

| Problem | Decision & Rationale |
|---|---|
| MySQL doesn't support `QUALIFY` | Rewrote dedup logic using `ROW_NUMBER()` subquery — functionally equivalent, MySQL-compatible |
| `TEXT` columns can't be indexed directly | Added explicit prefix length `INDEX (col(255))` to satisfy MySQL's index length constraint |
| FK constraints block `TRUNCATE` | Ordered truncation to respect parent → child dependency; re-enabled constraints after reload |
| Date arithmetic on YYYYMMDD keys | Used `DATEDIFF()` instead of integer subtraction — avoids silent wrong results (e.g. `20240101 - 20231201` ≠ 31 days) |
| Recursive CTE depth limit in MySQL | Refactored recursive logic into iterative staging steps to stay within MySQL's default depth |

---

## 🗃️ Data Warehouse — Star Schema (`olist_dwh`)

| Table | Type | Grain / Description |
|---|---|---|
| `dim_customer` | Dimension | One row per customer — demographics & location |
| `dim_seller` | Dimension | One row per seller — profile & location |
| `dim_products` | Dimension | One row per product — category & attributes |
| `dim_date` | Dimension | One row per date — year, month, day, weekday flags |
| `dim_payment` | Dimension | Payment type & installment info |
| `fact_orders` | Fact | Order-level grain — status, timestamps, review score |
| `fact_order_items` | Fact | Item-level grain — price, freight, seller FK |

The star schema separates analytical queries from raw operational data, enables clean joins for BI tools, and provides a stable foundation for both ad-hoc analysis and downstream modeling.

---

## 📊 Analytical Findings (`EDA_Olist_Brazil.ipynb`)

> All group comparisons use Mann-Whitney U (two-sided). Effect size r: < 0.1 negligible · 0.1–0.3 small · 0.3–0.5 medium.

### Target Overview

Reviews are polarized: 5-star accounts for **59.3%** and 1-star for **9.7%** — mid-range scores (2–3) are underrepresented, consistent with online review behavior where customers engage most at the extremes. Overall dissatisfaction rate: **~21%** (score 1–3).

---

### Key Finding 1 — Delivery Delay is the primary satisfaction driver

Orders delivered ahead of schedule have markedly lower dissatisfaction. The relationship is statistically robust (p < 0.001) and practically meaningful. `delivery_delay_days` is the single strongest continuous predictor among order-level features.

> **Implication**: operational on-time delivery performance matters far more than pricing or payment friction.

---

### Key Finding 2 — Freight cost affects satisfaction; freight ratio does not

| Freight Bin | Dissatisfaction Rate |
|---|---|
| Very Low | 16.6% |
| Low | 19.1% |
| Medium | 20.2% |
| High | 21.0% |
| Very High | 28.1% |

Gap of **~11.6 pp** between extremes (r = 0.126). By contrast, `freight_ratio` (shipping cost as % of order value) has r = 0.040 (negligible).

> **Implication**: customers anchor on the **absolute shipping fee**, not on whether it's proportionally "fair" relative to order size — a relevant insight for pricing strategy.

---

### Key Finding 3 — Total order value is statistically significant but practically irrelevant

Dissatisfied customers have slightly higher average order value (173.56 BRL vs 156.07 BRL), and dissatisfaction rises mildly across low/medium/high bins (19.1% → 20.6% → 23.3%). However, effect size r = 0.063 (negligible).

> **Implication**: distinguishing statistical significance from practical effect size matters for prioritising business actions — this gap is real but not worth acting on.

---

### Key Finding 4 — Seller reputation is the strongest predictor in the dataset

| Seller Avg Review Score | Dissatisfaction Rate |
|---|---|
| Low (1–3) | 58.1% |
| Medium (3–4) | 28.5% |
| High (4–5) | 16.4% |

Gap of **~41.7 pp**, r = −0.277 — the largest effect size observed across all features.

| Seller Late Rate Bin | Dissatisfaction Rate |
|---|---|
| Very Low | 15.2% |
| Very High | 27.6% |

Gap of **~12.4 pp**, r = 0.139.

> **Implication**: a seller's historical track record (rating + late rate) is a far more reliable signal than any single order attribute. Seller quality control would have an outsized impact on platform-level satisfaction.

---

### Key Finding 5 — Product category drives large satisfaction differences

High dissatisfaction categories (well above 21% avg): `office_furniture` (36.4%), `audio` (31.0%), `home_confort` (30.7%), `fashion_male_clothing` (29.5%).

Low dissatisfaction categories: `books` (9.8%–13.0%), `flowers` (11.1%).

> **Implication**: dissatisfaction risk is not uniform across the catalogue — categories with physical fit/assembly/quality expectations need different SLA or seller vetting.

---

### Key Finding 6 — Payment method and geographic distance are non-factors

Payment satisfaction spread: debit card (81.25%) → voucher (77.41%) — only **2–3 pp** across all methods. Geographic distance (Haversine): r = 0.073 (negligible) despite p < 0.001.

> **Implication**: not every statistically significant variable warrants business attention — this is the "significance ≠ importance" lesson applied in practice.

---

### Multicollinearity Handling

| Pair | Correlation | Decision |
|---|---|---|
| `payment_value` vs `total_order_value` | r = 1.0 | Dropped `total_order_value` |
| `quarter` vs `month` | r = 0.97 | Dropped `quarter` |
| `distance_km` vs `same_state` | r = −0.57 | Dropped `same_state`, kept continuous `distance_km` |

---

## 🤖 Downstream Modeling (supplementary)

A binary classifier (`is_unsatisfied`: review score 1–3) was trained as a downstream output of the pipeline to validate feature quality. Best result: **ROC-AUC ~0.75–0.76** (LightGBM), consistent with published benchmarks on this dataset. The moderate ceiling reflects the absence of subjective satisfaction signals (product quality perception, expectation mismatch) that are not captured in transactional data.

---

## ⚙️ Setup

```bash
# Create environment
conda create -n olist_env python=3.11
conda activate olist_env
pip install -r requirements.txt

# Configure MySQL connection in config.py, then run:
python pipeline/orchestrator.py
```

---

## 🛠️ Tech Stack

| Layer | Tools |
|---|---|
| Ingestion & Orchestration | Python |
| Transformation | MySQL, SQL-first |
| Data Warehouse | MySQL — star schema |
| Analysis | pandas, scipy, matplotlib, seaborn |
| Modeling (supplementary) | scikit-learn, LightGBM |

---

## 📄 Dataset

> Olist. (2018). *Brazilian E-Commerce Public Dataset by Olist*. Kaggle.  
> https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce — CC BY-NC-SA 4.0

---

## 👤 Author

**Chinh** — Data Engineering & Analytics Thesis Project