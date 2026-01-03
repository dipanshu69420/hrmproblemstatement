from db.auth import get_db_connection

def get_employee_profile(user_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            id,
            person_name,
            email,
            phone,
            dob,
            profile_picture,
            designation,
            department,
            joining_date,
            employment_type,
            salary,
            salary_structure
        FROM employees
        WHERE id = %s
    """, (user_id,))

    data = cursor.fetchone()
    conn.close()
    return data


def get_employee_documents(user_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, doc_type, file_path
        FROM employee_documents
        WHERE employee_id = %s
    """, (user_id,))

    docs = cursor.fetchall()
    conn.close()
    return docs
