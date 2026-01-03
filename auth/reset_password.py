from db.auth import get_db_connection
from services.password_service import hash_password
from services.email_service import send_otp_email
from datetime import datetime, timedelta
import random

# STEP 1: SEND OTP
def send_reset_otp(email):
    email = email.lower()
    otp = str(random.randint(100000, 999999))
    expiry = datetime.now() + timedelta(minutes=10)

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id FROM employees
        WHERE email=%s AND is_email_verified=1
    """, (email,))
    user = cursor.fetchone()

    if not user:
        return False, "Email not registered or not verified"

    cursor.execute("""
        UPDATE employees
        SET email_otp=%s, otp_expires_at=%s
        WHERE email=%s
    """, (otp, expiry, email))

    conn.commit()
    cursor.close()
    conn.close()

    send_otp_email(email, otp)
    return True, "OTP sent"


# STEP 2: VERIFY OTP + RESET PASSWORD
def reset_password(email, otp, new_password):
    email = email.lower()
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT email_otp, otp_expires_at
        FROM employees
        WHERE email=%s
    """, (email,))
    user = cursor.fetchone()

    if not user:
        return False, "Invalid request"

    if user["email_otp"] != otp:
        return False, "Invalid OTP"

    if user["otp_expires_at"] < datetime.now():
        return False, "OTP expired"

    cursor.execute("""
        UPDATE employees
        SET password_hash=%s,
            email_otp=NULL,
            otp_expires_at=NULL
        WHERE email=%s
    """, (hash_password(new_password), email))

    conn.commit()
    cursor.close()
    conn.close()
    return True, "Password updated"
