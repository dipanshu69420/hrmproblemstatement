import xmlrpc.client

# 1. Standard Odoo URL (Just the base, no /api/...)
url = "http://localhost:8069"
db = "odoo"
username = "admin"      # Real Odoo Login
password = "admin"   # Real Odoo Password

# 2. Connect to the Common Endpoint (For Authentication)
common = xmlrpc.client.ServerProxy('{}/xmlrpc/2/common'.format(url))

try:
    # 3. Authenticate
    uid = common.authenticate(db, username, password, {})
    print(f"Logged in successfully! User ID: {uid}")

    # 4. Connect to Object Endpoint (For Data)
    models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))

    # 5. Create Attendance Record Directly
    new_id = models.execute_kw(db, uid, password, 'hr.attendance', 'create', [{
        'employee_id': 12, # You must know the Integer ID of the employee here
        'check_in': '2025-11-12 09:00:00',
        'check_out': '2025-11-12 17:00:00'
    }])
    print(f"Created Attendance ID: {new_id}")

except Exception as e:
    print(f"XML-RPC Failed: {e}")