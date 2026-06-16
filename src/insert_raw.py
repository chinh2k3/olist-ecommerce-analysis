import pandas as pd
import numpy as np
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError
import logging
from pathlib import Path

logger = logging.getLogger(__name__)

BASE_DIR = Path().cwd()

RAW_TABLES = {
    "olist_customer": BASE_DIR / "data" / "raw" / "olist_customers_dataset.csv",
    "olist_geolocation": BASE_DIR / "data" / "raw" / "olist_geolocation_dataset.csv",
    "olist_order_items": BASE_DIR / "data" / "raw" / "olist_order_items_dataset.csv",
    "olist_order_payments": BASE_DIR / "data" / "raw" / "olist_order_payments_dataset.csv",
    "olist_reviews": BASE_DIR / "data" / "raw" / "olist_order_reviews_dataset.csv",
    "olist_orders": BASE_DIR / "data" / "raw" / "olist_orders_dataset.csv",
    "olist_products": BASE_DIR / "data" / "raw" / "olist_products_dataset.csv",
    "olist_sellers": BASE_DIR / "data" / "raw" / "olist_sellers_dataset.csv",
    "product_category": BASE_DIR / "data" / "raw" / "product_category_name_translation.csv",
}


# Config
DB_USER = 'root'
DB_PASSWORD = '29092003'
DB_PORT = 3306
DB_HOST = 'localhost'
DB_NAME = 'olist'

# Connect to MySQL
def get_engine():
    url = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    try:
        engine = create_engine(url)
        with engine.connect():
            logging.info("Connected to MySQL successfully.")
        return engine
    except SQLAlchemyError as e:
        logging.error(f"Database connection failed: {e}")
        raise

def extract(path: Path) -> pd.DataFrame:
    if not path.exists():
        raise FileNotFoundError(f"File không tồn tại: {path}")
    return pd.read_csv(path, low_memory=False)

def loading_to_db(engine, table_name: str, path: Path):
    logger.info(f"[LOAD] {table_name} - {path.name}")

    df = extract(path)

    df.to_sql(table_name, engine, if_exists="replace", index=False)

    logger.info(f"[DONE] {table_name}: {len(df):,} rows loaded.")

def run_etl():
    engine = get_engine()
    errors = []

    for table_name, path in RAW_TABLES.items():
        try:
            loading_to_db(engine, table_name, path)
        except Exception as e:
            logger.error(f"Failed to load {table_name}: {e}")
            errors.append(table_name)
    
    if errors:
        raise RuntimeError(f"Ingestion failed for: {errors}")

    logger.info("=== Raw ingestion completed. ===")


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    run_etl()
