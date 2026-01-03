import pandas as pd
from dash import html
from db.auth import get_db_connection

def build_employee_profile(employee_name):
    conn = get_db_connection()
    if not conn:
        return None

    try:
        emp_df = pd.read_sql(
            """
            SELECT 
                person_name,
                username,
                role,
                mobile_no,
                email,
                monthly_salary
            FROM employees
            WHERE person_name = %s
            """,
            conn,
            params=[employee_name]
       )


        if emp_df.empty:
            return None

        emp = emp_df.iloc[0].to_dict()

        profile = {
            "personal": {
                "Name": emp["person_name"],
                "Email": emp.get("email", "-"),
                "Mobile": emp.get("mobile_no", "-"),
            },
            "job": {
                "Username": emp.get("username", "-"),
                "Role": emp.get("role", "-"),
            },
            "salary": {
                "Monthly Salary": emp.get("monthly_salary", "-"),
            },
            "documents": [
                "Offer Letter (N/A)",
                "ID Proof (N/A)",
                "Contract (N/A)"
            ],
            "profile_pic": "/assets/default_profile.png"
        }

        return profile

    finally:
        conn.close()

