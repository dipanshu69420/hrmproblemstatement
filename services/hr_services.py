from db.auth import get_db_connection

def get_pending_users():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, person_name, email, role
        FROM employees
        WHERE is_hr_approved = 0
          AND status = 'pending'
    """)

    users = cursor.fetchall()
    conn.close()
    return users


def approve_user(user_id):
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        UPDATE employees
        SET is_hr_approved = 1,
            status = 'active'
        WHERE id = %s
    """, (user_id,))

    conn.commit()
    conn.close()
