from db.auth import get_db_connection
from services.password_service import verify_password

def authenticate_user(email, password):
    conn = get_db_connection()
    if not conn:
        return "Database connection failed"

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT 
                id,
                person_name,
                email,
                role,
                password_hash,
                is_email_verified,
                is_hr_approved,
                status
            FROM employees
            WHERE email = %s
        """, (email.lower(),))
        user = cursor.fetchone()
        if not user:
            return "Invalid email or password"
        if not verify_password(password, user["password_hash"]):
            return "Invalid email or password"

        if not user["is_email_verified"]:
            return "Email not verified"

        if not user["is_hr_approved"] or user["status"] != "active":
            return "Awaiting HR approval"
        return {
            "id": user["id"],
            "username": user["person_name"],
            "email": user["email"],
            "role": user["role"]
        }
    finally:
        cursor.close()
        conn.close()
