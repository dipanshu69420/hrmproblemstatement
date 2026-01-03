from db.auth import get_db_connection
from datetime import datetime

def verify_email_otp(email, otp):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT email_otp, otp_expires_at
        FROM employees
        WHERE email=%s
    """, (email.lower(),))

    user = cursor.fetchone()

    if not user:
        return False, "User not found"

    if user["email_otp"] != otp:
        return False, "Invalid OTP"

    if datetime.now() > user["otp_expires_at"]:
        return False, "OTP expired"

    cursor.execute("""
        UPDATE employees
        SET is_email_verified=TRUE, email_otp=NULL, otp_expires_at=NULL
        WHERE email=%s
    """, (email.lower(),))
    conn.commit()

    cursor.close()
    conn.close()
    return True, "Email verified successfully"
