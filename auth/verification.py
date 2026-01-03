from db.auth import get_db_connection
from services.email_service import notify_hr

def verify_email_otp(email, code):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT * FROM email_verification
        WHERE email=%s AND verification_code=%s
        AND is_used=0 AND expires_at > NOW()
    """, (email, code))
    record = cursor.fetchone()
    if not record:
        return "Invalid or expired code"
    cursor.execute("""
        UPDATE employees SET is_email_verified=1 WHERE email=%s
    """, (email,))
    cursor.execute("""
        UPDATE email_verification SET is_used=1 WHERE id=%s
    """, (record["id"],))
    conn.commit()
    notify_hr(record["email"], record["email"])
    conn.close()
    return "Email verified. Awaiting HR approval."
