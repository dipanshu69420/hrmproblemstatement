import random, datetime
from db.auth import get_db_connection
from services.password_service import hash_password
from services.email_service import send_verification_email, notify_hr
import config

def register_candidate(name, email, password):
    conn = get_db_connection()
    cursor = conn.cursor()
    password_hash = hash_password(password)
    try:
        cursor.execute("""
            INSERT INTO employees
            (person_name, email, password_hash, role)
            VALUES (%s, %s, %s, 'employee')
        """, (name, email.lower(), password_hash))
        conn.commit()
        code = str(random.randint(100000, 999999))
        expiry = datetime.datetime.now() + datetime.timedelta(minutes=10)
        cursor.execute("""
            INSERT INTO email_verification (email, verification_code, expires_at)
            VALUES (%s, %s, %s)
        """, (email, code, expiry))
        conn.commit()
        send_verification_email(email, code)
        return "Registration successful. Verify your email."
    except Exception as e:
        return str(e)
    finally:
        conn.close()
