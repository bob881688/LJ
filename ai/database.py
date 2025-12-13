from sqlalchemy import create_engine # 從SQLALCHEMY匯入create_engine用來建立資料庫的連線
from sqlalchemy.orm import sessionmaker

database_URL = "postgresql+psycopg2://appuser:passwordforDATAbase%21@119.14.200.30:5432/backend" # 要連postgreSQL的連結 但這裡是以字串顯示
engine = create_engine(database_URL) # engine才是真的會連線到資料庫的引擎，SQLALCHEMY會藉由它建立跟處理連線
session = sessionmaker(autocommit = False, autoflush = False, bind=engine) #session是工作階段、autocommit=false表示不會自動commit，autoflush=false表示不會自動刷新尚未送出的SQL表示不會自動刷新尚未送出的SQL, bind-engine是告訴sqlalemy這些session要用哪個資料庫連線

def get_db():
    db = session() # 開啟session
    try:
        yield db # yield是把db交給呼叫它的地方使用

    finally:
        db.close() # 最後一定會安全關閉session
    


