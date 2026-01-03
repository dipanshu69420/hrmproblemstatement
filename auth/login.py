from db.auth import get_db_connection
from services.password_service import verify_password

def authenticate_user(email, password):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT person_name, role, password_hash,
               is_email_verified, is_hr_approved, status
        FROM employees
        WHERE email = %s
    """, (email.lower(),))

    user = cursor.fetchone()
    conn.close()

    if not user:
        return "Invalid credentials"

    if not verify_password(password, user["password_hash"]):
        return "Invalid credentials"

    if not user["is_email_verified"]:
        return "Email not verified"

    if user["status"] != "active":
        return "Awaiting HR approval"

    return user
