from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError
import logging
import time
from pathlib import Path
from datetime import datetime
from insert_raw import run_etl
import pandas as pd


# Config
DB_USER = 'root'
DB_PASSWORD = '29092003'
DB_PORT = 3306
DB_HOST = 'localhost'
DB_NAME = 'olist_dwh'

base_dir = Path.cwd()
sql_dir = base_dir / "sql"

base_dir_load = Path.cwd()
output_path = base_dir_load / "data" / "raw" / "olist_brazil_ml.csv"

# Loging
def setup_logger():
    Path("logs").mkdir(exist_ok=True)
    log_file = f"logs/pipeline_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s | %(levelname)-8s | %(message)s",
        datefmt="%H:%M:%S",
        handlers=[logging.FileHandler(log_file), logging.StreamHandler()],
    )
    return logging.getLogger("pipeline")

# Pipeline steps
PIPELINE = [
    # Staging 
    {"step": "stg_customers", "file": "staging/stg_customer.sql", "truncate": ["olist.stg_customer"]},
    {"step": "stg_sellers", "file": "staging/stg_seller.sql", "truncate": ["olist.stg_seller"]},
    {"step": "stg_products", "file": "staging/stg_product.sql", "truncate": ["olist.stg_product"]},
    {"step": "stg_geolocation", "file": "staging/stg_geolocation.sql", "truncate": ["olist.stg_geolocation"]},
    {"step": "stg_orders", "file": "staging/stg_orders.sql", "truncate": ["olist.stg_orders"]},
    {"step": "stg_order_items", "file": "staging/stg_order_items.sql", "truncate": ["olist.stg_order_items"]},
    {"step": "stg_payment", "file": "staging/stg_payment.sql", "truncate": ["olist.stg_payment"]},
    {"step": "stg_review", "file": "staging/stg_review.sql", "truncate": ["olist.stg_review"]},

    # Dimensions
    {"step": "dim_date", "file": "dims/dim_date.sql", "truncate": ["olist_dwh.dim_date"]},
    {"step": "dim_customer", "file": "dims/dim_customer.sql", "truncate": ["olist_dwh.dim_customer"]},
    {"step": "dim_seller", "file": "dims/dim_seller.sql", "truncate": ["olist_dwh.dim_seller"]},
    {"step": "dim_products", "file": "dims/dim_product.sql", "truncate": ["olist_dwh.dim_products"]},

    # Facts 
    {"step": "cte_agg", "file": "facts/cte_agg.sql", "truncate": []},
    {"step": "fact_orders", "file": "facts/fact_order.sql", "truncate": ["olist_dwh.fact_order_items", "olist_dwh.fact_orders"]},
    {"step": "fact_order_items", "file": "facts/fact_order_items.sql", "truncate": ["olist_dwh.fact_order_items"]},

    #
    {"step": "feature_engineering", "file": "features/00.ML_Feature_Selection.sql", "truncate": []},
]

def run_pipeline(steps=None):
    logger = setup_logger()
    logger.info('PIPELINE START')

    # Database connection
    try:
        engine = create_engine(f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}")
        with engine.connect():
            print("Connected MySQL successfully!")
    except SQLAlchemyError as e:
        print("Database connection failed!")
        print(e)

    try:
        with engine.connect() as conn: 
            for task in PIPELINE:
                if steps and task['step'] not in steps:
                    continue

                sql_path = sql_dir / task['file']
                if not sql_path.exists():
                    logger.warning(f"[Error: ]{task['step']} — file not found")
                    continue
                
                # Truncate tables if needed
                conn.execute(text("SET FOREIGN_KEY_CHECKS = 0"))
                for tbl in task['truncate']:
                    logger.info(f"TRUNCATE {tbl}")
                    conn.execute(text(f"TRUNCATE TABLE {tbl}"))
                conn.execute(text("SET FOREIGN_KEY_CHECKS = 1"))
                conn.commit()

                # Execute SQL file
                logger.info(f"[RUN: ]{task['step']}")
                statements = [s.strip() for s in sql_path.read_text(encoding="utf-8").split(";") if s.strip()]
                row = 0
                for stmt in statements:
                    result = conn.execute(text(stmt))
                    if result.rowcount > 0:
                        row += result.rowcount
                conn.commit()

                # Load data into ML features table
                if task['step'] == "feature_engineering":
                    df = pd.read_sql(text("SELECT * FROM olist_dwh.ml_dataset"), conn)
                    df.to_csv(output_path, index=False, encoding="utf-8-sig")

                logger.info(f"[OK: ]{task['step']} | {row:,} rows")
    except Exception as e:
        logger.error(f"[FAIL: ]{e}")
        raise
    
    finally:
        conn.close()
        logger.info("PIPELINE DONE")

if __name__ == "__main__":
    run_pipeline()

