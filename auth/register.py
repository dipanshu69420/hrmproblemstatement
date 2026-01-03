from db.auth import get_db_connection
from services.password_service import hash_password
from services.email_service import send_otp_email
import random
from datetime import datetime, timedelta

def register_candidate(name, email, password):
    if not name or not email or not password:
        return False, "All fields are required"

    email = email.lower().strip()

    otp = str(random.randint(100000, 999999))
    otp_expiry = datetime.now() + timedelta(minutes=10)

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT id FROM employees WHERE email=%s", (email,))
        if cursor.fetchone():
            return False, "Email already exists"
        cursor.execute("""
            INSERT INTO employees
            (person_name, email, password_hash, email_otp, otp_expires_at,
             is_email_verified, is_hr_approved, status)
            VALUES (%s, %s, %s, %s, %s, 0, 0, 'pending')
        """, (
            name.strip(),
            email,
            hash_password(password),
            otp,
            otp_expiry
        ))
        conn.commit()
        send_otp_email(email, otp)

        return True, "OTP sent to your email"

    except Exception as e:
        print("REGISTER ERROR:", e)
        return False, "Registration failed. Please try again."

    finally:
        cursor.close()
        conn.close()
