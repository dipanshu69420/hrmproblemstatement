from db.auth import get_db_connection
from services.email_service import send_verification_email

def approve_employee(emp_id, approve=True):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT email, person_name FROM employees WHERE id=%s", (emp_id,))
    emp = cursor.fetchone()
    if approve:
        cursor.execute("""
            UPDATE employees SET status='active', is_hr_approved=1 WHERE id=%s
        """, (emp_id,))
    else:
        cursor.execute("""
            UPDATE employees SET status='rejected' WHERE id=%s
        """, (emp_id,))
    conn.commit()
    conn.close()
    return True
