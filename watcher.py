import mysql.connector
import pandas as pd
import time
import json
import io
from datetime import date, datetime, timedelta
import config
import handler
import dashboard

LOG_RETENTION_DAYS = 2 

def get_db_connection():
    try:
        return mysql.connector.connect(
            host=config.DB_HOST,
            user=config.DB_USER,
            # password=config.DB_PASS,
            database=config.DB_NAME
        )
    except mysql.connector.Error as err:
        print(f"Error connecting to DB: {err}")
        return None

def format_hours_for_sms(decimal_hours):
    if pd.isna(decimal_hours):
        return "N/A"
    hours = int(decimal_hours)
    minutes = int((decimal_hours - hours) * 60)
    return f"{hours}h {minutes}m"

def get_employee_phone_numbers():
    db = get_db_connection()
    if db:
        try:
            df = pd.read_sql("SELECT person_name, mobile_no FROM employees", db)
            return df.set_index('person_name')['mobile_no'].to_dict()
        except Exception as e:
            print(f"Error fetching phone numbers: {e}")
            return {}
        finally:
            db.close()
    return {}

def get_today_attendance():
    db = get_db_connection()
    today_str = date.today().strftime('%Y-%m-%d')
    if db:
        try:
            sql = f"""
            SELECT
                person_name,
                TIME_FORMAT(MIN(time), '%H:%i') AS first_in,
                TIME_FORMAT(MAX(time), '%H:%i') AS last_out,
                TIME_TO_SEC(TIMEDIFF(MAX(time), MIN(time))) / 3600 AS work_duration_hours
            FROM new_report
            WHERE date = '{today_str}'
            GROUP BY person_name;
            """
            df = pd.read_sql(sql, db)
            return df.set_index('person_name').to_dict('index')
        except Exception as e:
            print(f"Error fetching today's attendance: {e}")
            return {}
        finally:
            db.close()
    return {}

def load_json_log(filename):
    try:
        with open(filename, 'r') as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {}

def save_json_log(filename, log):
    try:
        with open(filename, 'w') as f:
            json.dump(log, f, indent=4)
    except Exception as e:
        print(f"Error saving log {filename}: {e}")

def cleanup_old_logs(filename, retention_days):
    log = load_json_log(filename)
    if not log:
        return

    today = date.today()
    keys_to_delete = []

    for date_key in log.keys():
        try:
            log_date = datetime.strptime(date_key, '%Y-%m-%d').date()
            age_in_days = (today - log_date).days
            
            if age_in_days > retention_days:
                keys_to_delete.append(date_key)
        except ValueError:
            pass

    if keys_to_delete:
        print(f"Cleaning up {filename}: Removing {len(keys_to_delete)} old entries ({', '.join(keys_to_delete)})")
        for key in keys_to_delete:
            del log[key]
        save_json_log(filename, log)

def run_watcher():
    print("Starting SMS & Email Watcher...")
    
    phone_book = get_employee_phone_numbers()
    if not phone_book:
        print("Error: Could not load any employee phone numbers. Exiting.")
        return

    while True:
        try:
            now = datetime.now()
            today_str = now.strftime('%Y-%m-%d')
            day_of_month = now.day
            cleanup_old_logs('sms_log.json', LOG_RETENTION_DAYS)
            cleanup_old_logs('email_log.json', LOG_RETENTION_DAYS)
            sms_log = load_json_log('sms_log.json')
            if today_str not in sms_log:
                sms_log[today_str] = {}
            
            today_log = sms_log[today_str]
            attendance_data = get_today_attendance()
            
            for person_name, data in attendance_data.items():
                
                if person_name not in phone_book or not phone_book[person_name]:
                    continue 
                
                raw_phone = str(phone_book[person_name])
                if "." in raw_phone:
                    raw_phone = raw_phone.split(".")[0]
                
                if len(raw_phone) == 10:
                    phone = raw_phone 
                else:
                    phone = raw_phone

                if person_name not in today_log:
                    today_log[person_name] = {"checkin_sent_at": None, "checkout_sent_at": None}

                first_in_time = data['first_in']
                
                # Check-in SMS
                if first_in_time and not today_log[person_name]['checkin_sent_at']:
                    print(f"Sending check-in SMS for {person_name}...")
                    success = handler.send_sms(
                        phone, 
                        config.MSG91_TEMPLATE_ID_CHECKIN,
                        var1=person_name,
                        var2=first_in_time  
                    )
                    if success:
                        today_log[person_name]['checkin_sent_at'] = first_in_time

                last_out_time = data['last_out']
                
                # Check-out SMS
                if (last_out_time != data['first_in'] and 
                    last_out_time != today_log[person_name]['checkout_sent_at']):
                    
                    print(f"Sending check-out SMS for {person_name}...")
                    duration_str = format_hours_for_sms(data['work_duration_hours'])
                    
                    success = handler.send_sms(
                        phone, 
                        config.MSG91_TEMPLATE_ID_CHECKOUT,
                        var1=last_out_time, 
                        var2=duration_str     
                    )
                    if success:
                        today_log[person_name]['checkout_sent_at'] = last_out_time
            
            save_json_log('sms_log.json', sms_log)
            email_log = load_json_log('email_log.json')
            
            if today_str not in email_log:
                if day_of_month == 16:
                    df_main = dashboard.fetch_data()
                    df_hol = dashboard.fetch_holidays()
                    json_main = df_main.to_json(date_format='iso', orient='split')
                    data_hol = {'date_list': df_hol['holiday_date'].tolist()}
                    bytes_summary = dashboard.generate_summary_report_excel(json_main, data_hol, now.month, now.year)
                    bytes_detail = dashboard.generate_detailed_report_excel(json_main, data_hol, now.month, now.year, 'all')
                    
                    attachments = [
                        (f"Summary_{now.strftime('%b_%Y')}_Mid.xlsx", bytes_summary),
                        (f"Detailed_{now.strftime('%b_%Y')}_Mid.xlsx", bytes_detail)
                    ]
                    
                    if handler.send_report_email(
                        config.EMAIL_RECIPIENTS,
                        f"Mid-Month Attendance Report - {now.strftime('%B %Y')}",
                        "Please find attached the Mid-Month Summary and Detailed attendance reports.",
                        attachments
                    ):
                        email_log[today_str] = "Mid Month Employee Report Sent"
                        save_json_log('email_log.json', email_log)

                elif day_of_month == 1:
                    first_of_this_month = now.replace(day=1)
                    prev_month_obj = first_of_this_month - timedelta(days=1)
                    target_month = prev_month_obj.month
                    target_year = prev_month_obj.year
                    
                    df_main = dashboard.fetch_data()
                    df_hol = dashboard.fetch_holidays()
                    df_emp = dashboard.fetch_employee_monthly_salaries()
                
                    json_main = df_main.to_json(date_format='iso', orient='split')
                    data_hol = {'date_list': df_hol['holiday_date'].tolist()}
                    json_emp = df_emp.to_json(orient='split')
                    bytes_summary = dashboard.generate_summary_report_excel(json_main, data_hol, target_month, target_year)
                    bytes_detail = dashboard.generate_detailed_report_excel(json_main, data_hol, target_month, target_year, 'all')
                    table_data, _ = dashboard.generate_salary_report(
                        0, json_main, data_hol, json_emp, target_month, target_year, "0"
                    )
                    
                    if table_data:
                        df_salary = pd.DataFrame(table_data)
                        salary_output = io.BytesIO()
                        with pd.ExcelWriter(salary_output, engine='xlsxwriter') as writer:
                            df_salary.to_excel(writer, sheet_name='Salary Report', index=False)
                            workbook = writer.book
                            worksheet = writer.sheets['Salary Report']
                            worksheet.set_column('A:Z', 15)
                        bytes_salary = salary_output.getvalue()
                    else:
                        bytes_salary = None

                    attachments = [
                        (f"Summary_{prev_month_obj.strftime('%b_%Y')}_Final.xlsx", bytes_summary),
                        (f"Detailed_{prev_month_obj.strftime('%b_%Y')}_Final.xlsx", bytes_detail)
                    ]
                    
                    if bytes_salary:
                         attachments.append((f"Salary_{prev_month_obj.strftime('%b_%Y')}.xlsx", bytes_salary))

                    if handler.send_report_email(
                        config.EMAIL_RECIPIENTS,
                        f"Final Attendance & Salary - {prev_month_obj.strftime('%B %Y')}",
                        f"Please find attached the Final Attendance Summary and Salary Report for {prev_month_obj.strftime('%B %Y')}.",
                        attachments
                    ):
                        email_log[today_str] = "Salary and Monthly Report Sent"
                        save_json_log('email_log.json', email_log)
            time.sleep(300)

        except KeyboardInterrupt:
            print("Stopping SMS Watcher.")
            break
        except Exception as e:
            print(f"An error occurred in the watcher loop: {e}")
            time.sleep(300)