import config
import mysql.connector
def get_db_connection():
    try:
        db_connection = mysql.connector.connect(
            host=config.DB_HOST,
            user=config.DB_USER,
            # password=config.DB_PASS,
            database=config.DB_NAME
        )
        return db_connection
    except mysql.connector.Error as err:
        print(f"Error connecting to DB: {err}")
        return None