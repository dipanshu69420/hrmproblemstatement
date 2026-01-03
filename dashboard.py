import dash
from dash import dcc, html, dash_table, ctx
from dash.dependencies import Input, Output, State
import plotly.express as px
import plotly.graph_objects as go
import pandas as pd
import mysql.connector
from datetime import date
import calendar
import datetime
import io
import time
import warnings
import logging
from flask import session

# Database imports
from db.auth import get_db_connection
# from services.hr_services import get_pending_users # Uncomment if you use this file, otherwise local function is used

warnings.filterwarnings("ignore")
logging.getLogger('werkzeug').setLevel(logging.ERROR)
logging.getLogger('urllib3').setLevel(logging.ERROR)

LATE_THRESHOLD_TIME = datetime.time(10, 0, 0)
LATE_THRESHOLD_STR = "10:00:00"
HOURS_THRESHOLD = 9.0

# --- INITIALIZE DASH ---
# server=False is correct here because server.py attaches the flask server later
app = dash.Dash(__name__,
                server=False, 
                external_stylesheets=['https://codepen.io/chriddyp/pen/bWLwgP.css'],
                title='HRM Dashboard',
                routes_pathname_prefix="/dashboard/",
                suppress_callback_exceptions=True)

today = date.today()
current_year = today.year
current_month = today.month

month_options = [{'label': calendar.month_name[i], 'value': i} for i in range(1, 13)]
year_options_default = [{'label': str(y), 'value': y} for y in range(current_year - 2, current_year + 2)]

# --- HELPER FUNCTIONS ---

def format_hours(decimal_hours):
    if pd.isna(decimal_hours):
        return "-"
    if isinstance(decimal_hours, str):
        return decimal_hours
    try:
        hours = int(decimal_hours)
        minutes = int((decimal_hours - hours) * 60)
        return f"{hours}h {minutes}m"
    except:
        return str(decimal_hours)

def get_working_days(selected_year, selected_month, holidays_list, end_day=None):
    try:
        month_start_date = date(selected_year, selected_month, 1)
        month_end_day_from_calendar = calendar.monthrange(selected_year, selected_month)[1]
        
        if end_day is None or end_day > month_end_day_from_calendar:
            final_end_day = month_end_day_from_calendar
        else:
            final_end_day = end_day
            
        month_end_date = date(selected_year, selected_month, final_end_day)
        all_days_in_range = pd.date_range(start=month_start_date, end=month_end_date)
        
        if all_days_in_range.empty:
            return 0
        is_weekday = (all_days_in_range.dayofweek != 6) 
        holidays_set = set(str(h) for h in holidays_list)
        is_not_holiday = (~all_days_in_range.strftime('%Y-%m-%d').isin(holidays_set))
        total_working_days = (is_weekday & is_not_holiday).sum()
        return int(total_working_days)
    except:
        return 0

def get_paid_leave_days(selected_year, selected_month, holidays_list, end_day=None):
    try:
        month_start_date = date(selected_year, selected_month, 1)
        month_end_day_from_calendar = calendar.monthrange(selected_year, selected_month)[1]
        
        if end_day is None or end_day > month_end_day_from_calendar:
            final_end_day = month_end_day_from_calendar
        else:
            final_end_day = end_day
            
        month_end_date = date(selected_year, selected_month, final_end_day)
        all_days_in_range = pd.date_range(start=month_start_date, end=month_end_date)
        
        if all_days_in_range.empty:
            return 0
        is_sunday = (all_days_in_range.dayofweek == 6) 
        holidays_set = set(str(h) for h in holidays_list)
        is_manual_holiday = (all_days_in_range.strftime('%Y-%m-%d').isin(holidays_set))
        total_paid_leave_days = (is_sunday | is_manual_holiday).sum()
        return int(total_paid_leave_days)
    except:
        return 0

# --- DATA FETCHING ---

def fetch_data():
    # FIXED QUERY: Removed GROUP BY id to ensure aggregation works for the dashboard
    sql_query = """
    SELECT
        person_name,
        date,
        TIME_FORMAT(MIN(time), '%H:%i:%s') AS first_in,  
        TIME_FORMAT(MAX(time), '%H:%i:%s') AS last_out, 
        TIME_TO_SEC(TIMEDIFF(MAX(time), MIN(time))) / 3600 AS work_duration_hours
    FROM
        new_report
    GROUP BY
        person_name, date
    ORDER BY
        date DESC;
    """
    db_connection = get_db_connection()
    if db_connection:
        try:
            df = pd.read_sql(sql_query, db_connection)
            if not df.empty:
                df['date'] = df['date'].astype(str) # Ensure string format for JSON
            return df
        except Exception as err:
            print(f"Error fetching data: {err}")
        finally:
            db_connection.close()
            
    return pd.DataFrame(columns=['person_name', 'date', 'first_in', 'last_out', 'work_duration_hours'])

def fetch_holidays():
    db_connection = get_db_connection()
    if db_connection:
        try:
            df = pd.read_sql("SELECT id, DATE_FORMAT(holiday_date, '%Y-%m-%d') as holiday_date, description FROM holidays ORDER BY holiday_date", db_connection)
            if not df.empty:
                df['holiday_date'] = df['holiday_date'].astype(str)
            return df
        except Exception as err:
            print(f"Error fetching holidays: {err}")
        finally:
            db_connection.close()
    return pd.DataFrame(columns=['id', 'holiday_date', 'description'])

def fetch_employee_monthly_salaries():
    db_connection = get_db_connection()
    if db_connection:
        try:
            query = "SELECT person_name, monthly_salary, mobile_no FROM employees WHERE role != 'admin'"
            df = pd.read_sql(query, db_connection)
            return df
        except Exception as err:
            print(f"Error fetching employee salaries: {err}")
        finally:
            db_connection.close()
    return pd.DataFrame(columns=['person_name', 'monthly_salary', 'mobile_no'])

def fetch_pending_users():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT id, person_name, email, role FROM employees WHERE is_hr_approved = 0 AND status = 'pending'")
        rows = cursor.fetchall()
        return rows
    except Exception as e:
        print(f"Error fetching pending: {e}")
        return []
    finally:
        conn.close()

def approve_user_db(user_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("UPDATE employees SET is_hr_approved = 1, status = 'active' WHERE id = %s", (user_id,))
        conn.commit()
    except Exception as e:
        print(f"Error approving: {e}")
    finally:
        conn.close()

def fetch_approved_leaves():
    conn = get_db_connection()
    try:
        df = pd.read_sql("SELECT employee_name, from_date, to_date FROM leave_requests WHERE status='approved'", conn)
        leave_map = {}
        if not df.empty:
            # Ensure dates are datetime objects for calculation
            df['from_date'] = pd.to_datetime(df['from_date'])
            df['to_date'] = pd.to_datetime(df['to_date'])
            
            for _, row in df.iterrows():
                days = pd.date_range(row['from_date'], row['to_date'])
                leave_map.setdefault(row['employee_name'], set()).update(
                    d.strftime('%Y-%m-%d') for d in days
                )
        return leave_map
    except Exception as e:
        print(f"Error fetching leaves: {e}")
        return {}
    finally:
        conn.close()

# --- LAYOUT ---

def serve_layout():
    user = session.get("user")
    if not user:
        return html.Div("Unauthorized - Please Login")

    return html.Div([
        # Location for redirect
        dcc.Location(id='dash-redirect', refresh=True),
        dcc.Store(id="session-store", data=user),
        get_dashboard_layout(role=user["role"], username=user["name"])
    ])

app.layout = serve_layout

def get_dashboard_layout(role='employee', username='User'):
    if role == 'admin':
        dropdown_value = 'all'
        dropdown_disabled = False
        dropdown_options = [{'label': 'All Employees', 'value': 'all'}] 
    else:
        dropdown_value = username 
        dropdown_disabled = True
        dropdown_options = [{'label': username, 'value': username}]

    download_btn_style = {'width': '100%', 'marginTop': '5px'}
    month_btn_style = {'flex': 1}
    
    if role == 'employee':
        download_btn_style = {'display': 'none'}
        month_btn_style = {'display': 'none'}
        
    tabs_children = []
    
    # --- TAB 1: DASHBOARD ---
    dashboard_tab = dcc.Tab(label='Dashboard', value='tab-dashboard', style={'padding': '0px', 'lineHeight': '40px'}, selected_style={'padding': '0px', 'lineHeight': '40px'}, children=[
            html.Div(style={'display': 'flex', 'height': '90vh', 'width': '100%', 'padding': '10px', 'gap': '10px', 'boxSizing': 'border-box'}, children=[
                html.Div(style={'flex': 1, 'display': 'flex', 'flexDirection': 'column', 'border': '1px solid #ddd', 'padding': '10px', 'gap': '10px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)', 'overflow': 'hidden'}, children=[
                    html.H3("Daywise Report", style={'textAlign': 'center', 'margin': '0 0 10px 0'}),
                    html.Div([html.Label("Select Date:", style={'fontWeight': 'bold'}), dcc.DatePickerSingle(id='day-picker', date=today, display_format='DD-MM-YYYY', style={'width': '100%'})]),
                    html.Div([html.Label("Select Employee:", style={'fontWeight': 'bold'}), dcc.Dropdown(id='day-employee-filter', options=dropdown_options, value=dropdown_value, disabled=dropdown_disabled, clearable=False)]),
                    html.Button("Download Day Report", id='btn-download-day', style=download_btn_style),
                    dcc.Graph(id='daily-attendance-gauge', style={'height': '35%'}, config={'responsive': True}),
                    dcc.Graph(id='daily-hours-indicator', style={'height': "10%"}, config={'responsive': True}),
                    html.Div(style={'display': 'flex', 'flex': 1.5, 'gap': '10px', 'overflow': 'hidden', 'minHeight': '100px'}, children=[
                        html.Div(style={'flex': 1, 'border': '1px solid #eee', 'padding': '5px', 'overflowY': 'auto'}, children=[html.H5("Present", style={'textAlign': 'center', 'margin': '5px'}), html.Ul(id='present-list', style={'padding': '0 10px', 'margin': 0, 'listStyleType': 'none', 'fontSize': '14px'})]),
                        html.Div(style={'flex': 1, 'border': '1px solid #eee', 'padding': '5px', 'overflowY': 'auto'}, children=[html.H5("Absent", style={'textAlign': 'center', 'margin': '5px'}), html.Ul(id='absent-list', style={'padding': '0 10px', 'margin': 0, 'listStyleType': 'none', 'fontSize': '14px'})])
                    ])
                ]),
                html.Div(style={'flex': 2, 'display': 'flex', 'flexDirection': 'column', 'border': '1px solid #ddd', 'padding': '10px', 'gap': '10px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'}, children=[
                    html.H3("Monthwise Report", style={'textAlign': 'center', 'margin': '0 0 10px 0'}),
                    html.Div(style={'display': 'flex', 'gap': '10px', 'alignItems': 'flex-end'}, children=[
                        html.Div(style={'flex': 1}, children=[html.Label("Month:", style={'fontWeight': 'bold'}), dcc.Dropdown(id='month-dropdown', options=month_options, value=current_month, clearable=False)]),
                        html.Div(style={'flex': 1}, children=[html.Label("Year:", style={'fontWeight': 'bold'}), dcc.Dropdown(id='year-dropdown', options=year_options_default, value=current_year, clearable=False)]),
                        html.Div(style={'flex': 1}, children=[html.Label("Employee (Month):", style={'fontWeight': 'bold'}), dcc.Dropdown(id='month-employee-filter', options=dropdown_options, value=dropdown_value, disabled=dropdown_disabled, clearable=False)])
                    ]),
                    html.Div(style={'display': 'flex', 'gap': '10px', 'marginTop': '5px'}, children=[html.Button("Download Monthly Summary", id='btn-download-month', style=month_btn_style), html.Button("Download Monthly Detailed Summary", id='btn-download-detailed-month', style=month_btn_style)]),
                    html.Div(style={'display': 'flex', 'flex': 0.9, 'gap': '10px'}, children=[dcc.Graph(id='hours-gauge', style={'flex': 1, 'height': "70%"}, config={'responsive': True}), dcc.Graph(id='attendance-gauge', style={'flex': 1, "height": "70%"}, config={'responsive': True})]),
                    html.Div(style={'display': 'flex', 'flex': 0.8, 'gap': '10px', 'overflow': 'hidden'}, children=[dcc.Graph(id='live-work-hours-pie', style={'flex': 1,"height": "110%"}, config={'responsive': True}), html.Div(style={'flex': 1, 'overflowY': 'auto', 'height': '100%'}, children=[dash_table.DataTable(id='monthly-summary-table', style_table={'height': '100%', 'overflowY': 'auto', 'border': 'none'}, style_cell={'textAlign': 'left', 'padding': '5px', 'border': 'none'}, style_header={'backgroundColor': 'rgb(230, 230, 230)', 'fontWeight': 'bold', 'border': 'none'})])])
                ])
            ])
        ])
    tabs_children.append(dashboard_tab)

    # Create Holiday Tab (For Everyone)
    holiday_add_style = {'padding': '20px'}
    holiday_table_editable = True
    holiday_row_deletable = True
    if role == 'employee':
        holiday_add_style = {'display': 'none'} 
        holiday_table_editable = False
        holiday_row_deletable = False

    holiday_tab = dcc.Tab(label='Holiday Management', value='tab-admin', style={'padding': '0px', 'lineHeight': '40px'}, selected_style={'padding': '0px', 'lineHeight': '40px'}, children=[
        html.Div(style={'padding': '20px'}, children=[
            html.Div(style=holiday_add_style, children=[
                html.H3("Add New Holiday"),
                html.Div(style={'display': 'flex', 'gap': '10px', 'alignItems': 'flex-end'}, children=[html.Div([html.Label("Holiday Date:"), dcc.DatePickerSingle(id='holiday-date-picker', date=date.today(), display_format='DD-MM-YYYY')]), html.Div(style={'flex': 1}, children=[html.Label("Description:"), dcc.Input(id='holiday-desc-input', type='text', placeholder='e.g., New Year', style={'width': '100%'})]), html.Button('Add Holiday', id='add-holiday-button')]),
                html.Div(id='holiday-add-status', style={'marginTop': '10px'}),
                html.Hr(style={'margin': '20px 0'}),
            ]),
            html.H3("Current Holiday List"),
            dash_table.DataTable(id='holiday-table', columns=[{'name': 'Date', 'id': 'holiday_date', 'editable': holiday_table_editable}, {'name': 'Description', 'id': 'description', 'editable': holiday_table_editable}], data=[], row_deletable=holiday_row_deletable, page_action='native', page_current=0, page_size=10, style_cell={'textAlign': 'left'}),
            html.Div(id='holiday-delete-status', style={'marginTop': '10px'})
        ])
    ])
    tabs_children.append(holiday_tab)

    # Create Leave Tab (Employee Only)
    if role == 'employee':
        leave_tab = dcc.Tab(label='Leave Request', value='tab-leave', style={'padding': '0px', 'lineHeight': '40px'}, selected_style={'padding': '0px', 'lineHeight': '40px'}, children=[
                html.Div(style={'padding': '20px'}, children=[
                    html.H3("Apply for Leave"),
                    dcc.Dropdown(id='leave-type', options=[{'label': 'Paid Leave', 'value': 'Paid'}, {'label': 'Sick Leave', 'value': 'Sick'}, {'label': 'Unpaid Leave', 'value': 'Unpaid'}], placeholder="Select Leave Type"),
                    dcc.DatePickerRange(id='leave-date-range', display_format='DD-MM-YYYY', style={'marginTop': '10px'}),
                    dcc.Textarea(id='leave-reason', placeholder='Reason for leave', style={'width': '100%', 'marginTop': '10px'}),
                    html.Button('Submit Leave', id='btn-apply-leave', n_clicks=0, style={'marginTop': '10px'}),
                    html.Div(id='leave-status', style={'marginTop': '10px'}),
                    html.Hr(),
                    html.H4("My Leave Requests"),
                    dash_table.DataTable(id='my-leave-table', columns=[{'name': 'Type', 'id': 'leave_type'}, {'name': 'From', 'id': 'from_date'}, {'name': 'To', 'id': 'to_date'}, {'name': 'Reason', 'id': 'reason'}, {'name': 'Status', 'id': 'status'}, {'name': 'Admin Comment', 'id': 'admin_comment'}], data=[], style_cell={'textAlign': 'left'})
                ])
            ])
        tabs_children.append(leave_tab)

    # Create Salary & Approval Tabs (Admin Only)
    if role == 'admin':
        salary_tab = dcc.Tab(label='Salary Management', value='tab-salary', style={'padding': '0px', 'lineHeight': '40px'}, selected_style={'padding': '0px', 'lineHeight': '40px'}, children=[
            html.Div(style={'padding': '20px', 'display': 'flex', 'gap': '20px'}, children=[
                html.Div(style={'flex': 1, 'border': '1px solid #ddd', 'padding': '10px', 'borderRadius': '5px'}, children=[
                    html.H3("Employee Salary Management"), html.H5("Add New Employee Salary"),
                    html.Div(style={'display': 'flex', 'gap': '10px', 'alignItems': 'center'}, children=[dcc.Input(id='new-emp-name', placeholder='Type or Select Employee Name', style={'flex': 2}, list='list-employee-names'), html.Datalist(id='list-employee-names', children=[]), dcc.Input(id='new-emp-salary', placeholder='Monthly Salary', type='number', style={'flex': 1}), html.Button('Add', id='btn-add-employee', style={'flex': 0.5})]),
                    html.Div(id='add-employee-status', style={'marginTop': '5px', 'marginBottom': '15px'}), html.Hr(), html.H5("Edit Existing Salaries"), html.Button('Load Employee Salaries', id='btn-load-salaries', style={'marginBottom': '10px', 'width': '100%'}),
                    dash_table.DataTable(id='editable-salary-table', columns=[{'name': 'Employee Name', 'id': 'person_name', 'editable': False}, {'name': 'Monthly Salary', 'id': 'monthly_salary', 'editable': True, 'type': 'numeric'}], data=[], editable=True, style_cell={'textAlign': 'left'}, style_header={'backgroundColor': 'rgb(240, 240, 240)', 'fontWeight': 'bold'}),
                    html.Button('Save Salary Changes', id='btn-save-salaries', style={'marginTop': '10px', 'width': '100%'}), html.Div(id='save-salary-status', style={'marginTop': '5px'})
                ]),
                html.Div(style={'flex': 2, 'border': '1px solid #ddd', 'padding': '10px', 'borderRadius': '5px'}, children=[
                    html.H3("Generate Salary Report"),
                    html.Div(style={'display': 'flex', 'gap': '10px', 'alignItems': 'flex-end', 'marginBottom': '10px'}, children=[html.Div(style={'flex': 1}, children=[html.Label("Month:", style={'fontWeight': 'bold'}), dcc.Dropdown(id='salary-month-dropdown', options=month_options, value=current_month, clearable=False)]), html.Div(style={'flex': 1}, children=[html.Label("Year:", style={'fontWeight': 'bold'}), dcc.Dropdown(id='salary-year-dropdown', options=year_options_default, value=current_year, clearable=False)]), html.Div(style={'flex': 1}, children=[html.Label("Exception Days (Grace):", style={'fontWeight': 'bold'}), dcc.Input(id='salary-exception-days', type='number', value=0, min=0, step=1, style={'width': '100%'})])]),
                    html.Div(style={'display': 'flex', 'gap': '10px'}, children=[html.Button('Generate Salary Report', id='btn-generate-salary', style={'flex': 1}), html.Button("Download (CSV)", id='btn-download-salary', style={'flex': 1})]), html.Hr(),
                    dash_table.DataTable(id='salary-table', columns=[], data=[], page_action='native', page_current=0, page_size=15, style_table={'overflowX': 'auto'}, style_cell={'textAlign': 'left', 'padding': '5px', 'fontFamily': 'sans-serif', 'fontSize': '12px', 'whiteSpace': 'normal', 'height': 'auto', 'minWidth': '40px', 'maxWidth': '90px', 'width': 'auto'}, style_header={'backgroundColor': 'rgb(230, 230, 230)', 'fontWeight': 'bold', 'textAlign': 'center', 'whiteSpace': 'normal', 'height': 'auto'}, style_data_conditional=[{'if': {'row_index': 'odd'}, 'backgroundColor': 'rgb(248, 248, 248)'}])
                ])
            ])
        ])
        tabs_children.append(salary_tab)
        
        approval_tab = dcc.Tab(label='Approvals', value='tab-approvals', style={'padding': '0px', 'lineHeight': '40px'}, selected_style={'padding': '0px', 'lineHeight': '40px'}, children=[
                html.Div(style={'padding': '20px'}, children=[
                    html.H3("User Approval"),
                    dash_table.DataTable(id='approval-table', columns=[{'name': 'ID', 'id': 'id'}, {'name': 'Name', 'id': 'person_name'}, {'name': 'Email', 'id': 'email'}, {'name': 'Role', 'id': 'role'}, {'name': 'Approve', 'id': 'approve', 'presentation': 'markdown'}], data=[], style_cell={'textAlign': 'center'}),
                    html.Div(id='approval-status'), html.Hr(), html.H3("Leave Approval"), dcc.Textarea(id='leave-admin-comment', placeholder='Admin comment (optional)', style={'width': '100%', 'marginBottom': '10px'}),
                    dash_table.DataTable(id='leave-approval-table', columns=[{'name': 'Employee', 'id': 'employee_name'}, {'name': 'From', 'id': 'from_date'}, {'name': 'To', 'id': 'to_date'}, {'name': 'Reason', 'id': 'reason'}, {'name': 'Approve', 'id': 'approve', 'presentation': 'markdown'}, {'name': 'Reject', 'id': 'reject', 'presentation': 'markdown'}], data=[], style_cell={'textAlign': 'center'}),
                    html.Div(id='leave-approval-status', style={'marginTop': '10px'})
                ])
            ])
        tabs_children.append(approval_tab)

    # --- HIDDEN COMPONENTS (FIXED) ---
    hidden_divs = []
    if role != 'admin':
        hidden_divs = html.Div(style={'display': 'none'}, children=[
            # Admin Buttons
            html.Button(id='btn-save-salaries', n_clicks=0),
            html.Button(id='btn-add-employee', n_clicks=0),
            html.Button(id='btn-load-salaries', n_clicks=0),
            html.Button(id='btn-generate-salary', n_clicks=0),
            html.Button(id='btn-download-salary', n_clicks=0),
            # Admin Inputs
            dcc.Input(id='new-emp-name'),
            dcc.Input(id='new-emp-salary'),
            dcc.Input(id='salary-exception-days', value=0),
            html.Div(id='list-employee-names'),
            dcc.Dropdown(id='salary-month-dropdown', value=current_month), 
            dcc.Dropdown(id='salary-year-dropdown', value=current_year),
            # Admin Tables
            dash_table.DataTable(id='editable-salary-table', data=[]),
            dash_table.DataTable(id='salary-table', data=[]),
            dash_table.DataTable(id='approval-table', data=[]),
            dash_table.DataTable(id='leave-approval-table', data=[]),
            # Admin Other
            html.Div(id='approval-status'),
            html.Div(id='leave-approval-status'),
            dcc.Textarea(id='leave-admin-comment'),
            
            # NOTE: Holiday components REMOVED from here because they are in holiday_tab for everyone
        ])
    else:
        # If Admin, hidden employee components
        hidden_divs = html.Div(style={'display': 'none'}, children=[
            html.Button(id='btn-apply-leave'),
            dcc.Dropdown(id='leave-type'),
            dcc.DatePickerRange(id='leave-date-range'),
            dcc.Textarea(id='leave-reason'),
            html.Div(id='leave-status'),
            dash_table.DataTable(id='my-leave-table', data=[])
        ])

    return html.Div([
        html.Div(style={'display': 'flex', 'justifyContent': 'space-between', 'alignItems': 'center', 'padding': '10px', 'backgroundColor': '#f8f9fa', 'borderBottom': '1px solid #ddd'}, children=[
            html.H4(f"Welcome, {username}", style={'margin': 0}),
            html.A("Logout", id="btn-logout", href="/logout", style={"backgroundColor": "#dc3545", "color": "white", "padding": "8px 16px", "borderRadius": "4px", "textDecoration": "none", "fontWeight": "bold"})
        ]),
        dcc.Store(id='data-store'), dcc.Store(id='holiday-store'), dcc.Store(id='employee-store'),
        dcc.Interval(id='interval-component', interval=300 * 1000, n_intervals=0),
        dcc.Download(id='download-daywise-xlsx'), dcc.Download(id='download-monthwise-xlsx'), dcc.Download(id='download-detailed-month-xlsx'), dcc.Download(id='download-salary-csv'),
        html.Div(id='sync-odoo-status', style={'display': 'none'}), 
        dcc.Tabs(id='main-tabs', value='tab-dashboard', style={'height': '40px'}, children=tabs_children),
        hidden_divs
    ])
    
@app.callback(Output('data-store', 'data'),
              [Input('interval-component', 'n_intervals')])
def update_data_store(n):
    df = fetch_data()
    return df.to_json(date_format='iso', orient='split')

@app.callback(Output('employee-store', 'data'),
              [Input('interval-component', 'n_intervals'),
               Input('btn-save-salaries', 'n_clicks'),
               Input('btn-add-employee', 'n_clicks')])
def update_employee_store(n_interval, n_save, n_add):
    df = fetch_employee_monthly_salaries()
    return df.to_json(orient='split')

@app.callback(
    Output('approval-table', 'data'),
    Input('main-tabs', 'value')
)
def load_pending_users(tab):
    if tab != 'tab-approvals': # Checked value matches tab def
        return []

    users = fetch_pending_users()

    for u in users:
        u['approve'] = f"[Approve](approve:{u['id']})"

    return users

@app.callback(
    Output('approval-status', 'children'),
    Input('approval-table', 'active_cell'),
    State('approval-table', 'data'),
    prevent_initial_call=True
)
def approve_user_callback(active_cell, rows):
    if not active_cell:
        return ""

    if active_cell['column_id'] == 'approve':
        row_index = active_cell['row']
        user_id = rows[row_index]['id']

        approve_user_db(user_id)

        return f"User ID {user_id} approved successfully"

    return ""

@app.callback(
    Output('dash-redirect', 'href'),
    Input('btn-logout', 'n_clicks'),
    prevent_initial_call=True
)
def redirect_after_logout(n):
    session.clear()
    return "/login?logged_out=1"

@app.callback(
    [Output('month-employee-filter', 'options'),
     Output('day-employee-filter', 'options'),
     Output('year-dropdown', 'options'),
     Output('salary-year-dropdown', 'options'),
     Output('list-employee-names', 'children')],
    Input('data-store', 'data'),
    
)
def update_dropdowns(json_data):
    user = session.get("user")
    if not user:
        return [], [], year_options_default, year_options_default, []
    user_role = user["role"]
    user_name = user["name"]
    if user_role == 'employee':
        forced_option = [{'label': user_name, 'value': user_name}]
        year_options = year_options_default
        if json_data:
            try:
                df = pd.read_json(io.StringIO(json_data), orient='split')
                df['date'] = pd.to_datetime(df['date'])
                years = df['date'].dt.year.unique()
                all_years = sorted(list(set(list(years) + [current_year, current_year-1, current_year+1])))
                year_options = [{'label': str(y), 'value': y} for y in all_years]
            except Exception:
                pass
        return forced_option, forced_option, year_options, year_options, []

    if not json_data:
        emp_options = [{'label': 'All Employees', 'value': 'all'}]
        return emp_options, emp_options, year_options_default, year_options_default, []
    
    df = pd.read_json(io.StringIO(json_data), orient='split')
    df['date'] = pd.to_datetime(df['date'])
    
    employee_names = df['person_name'].unique()
    
    emp_options = [{'label': 'All Employees', 'value': 'all'}]
    for name in sorted(employee_names):
        emp_options.append({'label': name, 'value': name})
    
    datalist_options = [html.Option(value=name) for name in sorted(employee_names)]
        
    years = df['date'].dt.year.unique()
    all_years = sorted(list(set(list(years) + [current_year, current_year-1, current_year+1])))
    year_options = [{'label': str(y), 'value': y} for y in all_years]
    
    if not year_options:
        year_options = year_options_default
        
    return emp_options, emp_options, year_options, year_options, datalist_options

@app.callback(
    [Output('daily-attendance-gauge', 'figure'),
     Output('daily-hours-indicator', 'figure'),
     Output('present-list', 'children'),
     Output('absent-list', 'children')],
    [Input('data-store', 'data'),
     Input('holiday-store', 'data'),
     Input('day-picker', 'date'),
     Input('day-employee-filter', 'value')]
)
def update_day_graph(json_data, holiday_data, selected_date, selected_employee):
    if not json_data or not selected_date or not holiday_data:
        return {}, {}, [], []
        
    try:
        selected_date_obj = datetime.date.fromisoformat(selected_date)
    except (ValueError, TypeError):
        return {}, {}, [html.Li("Invalid Date")], [html.Li("Invalid Date")]

    is_sunday = (selected_date_obj.weekday() == 6)
    holidays_list = holiday_data.get('date_list', [])
    is_manual_holiday = (selected_date in holidays_list)

    if is_sunday or is_manual_holiday:
        holiday_reason = "HOLIDAY"
        if is_sunday:
            holiday_reason = "SUNDAY"
        holiday_fig = {
            "layout": {
                "xaxis": {"visible": False}, "yaxis": {"visible": False},
                "annotations": [{"text": f"TODAY IS A {holiday_reason}", "xref": "paper", "yref": "paper", "showarrow": False, "font": {"size": 24, "color": "green"}}]
            }
        }
        return holiday_fig, {}, [], []
        
    df = pd.read_json(io.StringIO(json_data), orient='split')
    df['date'] = pd.to_datetime(df['date'])
    all_employees = set(df['person_name'].unique())
    total_employees = len(all_employees)
    
    selected_date_dt = pd.to_datetime(selected_date).date()
    day_filtered_df = df[df['date'].dt.date == selected_date_dt]
    present_employees_set = set(day_filtered_df['person_name'].unique())
    employees_present_count = len(present_employees_set)
    gauge_val = employees_present_count
    gauge_max = total_employees
    gauge_title = f"Daily Attendance ({selected_date_dt})"
    
    if selected_employee and selected_employee != 'all':
        is_present = selected_employee in present_employees_set
        gauge_val = 1 if is_present else 0
        gauge_max = 1
        gauge_title = f"Attendance: {selected_employee}"

    fig_day_gauge = go.Figure(go.Indicator(
        mode = "gauge+number",
        value = gauge_val,
        title = {'text': gauge_title},
        number = {'suffix': ""},
        gauge = {'axis': {'range': [0, gauge_max]}, 'bar': {'color': "#2ca02c"}}
    ))
    
    indicator_df = day_filtered_df
    present_list_items = []
    absent_list_items = []
    leave_map = fetch_approved_leaves()
    if selected_employee in leave_map and selected_date in leave_map[selected_employee]:
        fig_day_indicator = {
            "layout": {
                "annotations": [{
                    "text": "ON LEAVE",
                    "xref": "paper",
                    "yref": "paper",
                    "showarrow": False,
                    "font": {"size": 28, "color": "blue"}
                }]
            }
        }
    if selected_employee and selected_employee != 'all':
        indicator_df = day_filtered_df[day_filtered_df['person_name'] == selected_employee]
        if indicator_df.empty:
            fig_day_indicator = {
                "layout": {
                    "xaxis": {"visible": False}, "yaxis": {"visible": False},
                    "annotations": [{"text": "ABSENT", "xref": "paper", "yref": "paper", "showarrow": False, "font": {"size": 30, "color": "red"}}]
                }
            }
            present_list_items = []
            absent_list_items = [html.Li(selected_employee, style={'color': 'red', 'fontWeight': 'bold'})]
        else:
            total_day_hours_decimal = indicator_df['work_duration_hours'].sum()
            hours_str = format_hours(total_day_hours_decimal)
            font_color = "green" if total_day_hours_decimal >= HOURS_THRESHOLD else "#FF8C00"
            
            fig_day_indicator = go.Figure(go.Indicator(
                mode = "number",
                value = total_day_hours_decimal, 
                title = {'text': f"Hours: {selected_employee}"},
                number = {'valueformat': '.2f', 'suffix': f" ({hours_str})", 'font': {'size': 30, 'color': font_color}}
            ))
            fig_day_indicator.update_layout(margin=dict(t=50, b=10, l=10, r=10))
            row = indicator_df.iloc[0]
            style = {}
            tags = []
            try:
                first_in_time = datetime.datetime.strptime(row['first_in'], '%H:%M:%S').time()
                if first_in_time > LATE_THRESHOLD_TIME:
                    style['color'] = 'red'
                    tags.append("Late")
            except (ValueError, TypeError):
                pass
            if row['work_duration_hours'] < HOURS_THRESHOLD:
                if 'color' not in style: style['color'] = '#FF8C00'
                tags.append(f"Short Hours")

            tags_str = f" [{', '.join(tags)}]" if tags else ""
            list_text = f"{row['person_name']} (In: {row['first_in']}, Out: {row['last_out']}){tags_str}"
            present_list_items = [html.Li(list_text, style=style)]
            absent_list_items = []
    else:
        total_day_hours_decimal = indicator_df['work_duration_hours'].sum()
        hours_str = format_hours(total_day_hours_decimal)
        fig_day_indicator = go.Figure(go.Indicator(
            mode = "number",
            value = total_day_hours_decimal, 
            title = {'text': f"Total Hours ({selected_date_dt})"},
            number = {'valueformat': '.2f', 'suffix': f" ({hours_str})", 'font': {'size': 30, 'color': 'black'}}
        ))
        fig_day_indicator.update_layout(margin=dict(t=50, b=10, l=10, r=10))

        if employees_present_count == 0:
            present_list_items = [html.Li("No employees present.")]
        else:
            present_df_sorted = day_filtered_df.sort_values(by='person_name')
            for index, row in present_df_sorted.iterrows():
                style = {}
                tags = []
                try:
                    first_in_time = datetime.datetime.strptime(row['first_in'], '%H:%M:%S').time()
                    if first_in_time > LATE_THRESHOLD_TIME:
                        style['color'] = 'red'
                        tags.append("Late")
                except: pass
                if row['work_duration_hours'] < HOURS_THRESHOLD:
                    if 'color' not in style: style['color'] = '#FF8C00'
                    tags.append("Short")
                tags_str = f" [{', '.join(tags)}]" if tags else ""
                present_list_items.append(html.Li(f"{row['person_name']} ({row['first_in']}-{row['last_out']}){tags_str}", style=style))
        
        absent_employees = all_employees - present_employees_set
        if not absent_employees:
            absent_list_items = [html.Li("All employees present.")]
        else:
            absent_list_items = [html.Li(name) for name in sorted(absent_employees)]

    return fig_day_gauge, fig_day_indicator, present_list_items, absent_list_items

@app.callback(
    [Output('hours-gauge', 'figure'),
     Output('attendance-gauge', 'figure'),
     Output('live-work-hours-pie', 'figure'),
     Output('monthly-summary-table', 'data'),
     Output('monthly-summary-table', 'columns'),
     Output('monthly-summary-table', 'style_data_conditional')],
    [Input('data-store', 'data'),
     Input('holiday-store', 'data'),
     Input('month-dropdown', 'value'),
     Input('year-dropdown', 'value'),
     Input('month-employee-filter', 'value')]
)
def update_month_graphs(json_data, holiday_data, selected_month, selected_year, selected_employee):
    
    if not all([json_data, holiday_data, selected_month, selected_year]):
        return {}, {}, {}, [], [], []

    df = pd.read_json(io.StringIO(json_data), orient='split')
    df['date'] = pd.to_datetime(df['date'])
    date_filtered_df = df[
        (df['date'].dt.month == selected_month) &
        (df['date'].dt.year == selected_year)
    ]
    filtered_df = date_filtered_df
    if selected_employee and selected_employee != 'all':
        filtered_df = date_filtered_df[date_filtered_df['person_name'] == selected_employee]

    if filtered_df.empty and (selected_employee and selected_employee != 'all'):
         empty_fig = {"layout": {"annotations": [{"text": "No data.", "xref": "paper", "yref": "paper", "showarrow": False, "font": {"size": 20}}]}}
         return empty_fig, empty_fig, empty_fig, [], [], []
    elif date_filtered_df.empty:
         empty_fig = {"layout": {"annotations": [{"text": "No data.", "xref": "paper", "yref": "paper", "showarrow": False, "font": {"size": 20}}]}}
         return empty_fig, empty_fig, empty_fig, [], [], []

    holidays_list = holiday_data.get('date_list', [])
    today_obj = date.today()
    end_day_to_check = None
    if selected_year == today_obj.year and selected_month == today_obj.month:
        end_day_to_check = today_obj.day
        filtered_df = filtered_df[filtered_df['date'].dt.date <= today_obj]
    
    total_working_days_in_range = get_working_days(selected_year, selected_month, holidays_list, end_day_to_check)
    total_actual_decimal = filtered_df['work_duration_hours'].sum()
    hours_actual = int(total_actual_decimal)
    minutes_actual = int((total_actual_decimal - hours_actual) * 60)
    if selected_employee and selected_employee != 'all':
        total_expected = total_working_days_in_range * HOURS_THRESHOLD
        gauge_title = f"Total Hours: {selected_employee}"
    else:
        num_unique_employees = date_filtered_df['person_name'].nunique()
        total_expected = total_working_days_in_range * num_unique_employees * HOURS_THRESHOLD
        gauge_title = f"Total Hours (All Employees)"

    bar_color = "#1f77b4"
    if total_actual_decimal < total_expected:
        bar_color = "#FF8C00" 

    fig_gauge = go.Figure(go.Indicator(
        mode = "gauge+number",
        value = total_actual_decimal,
        title = {'text': gauge_title},
        number = {'suffix': f" hrs ({hours_actual}h {minutes_actual}m)"},
        gauge = {'axis': {'range': [0, total_expected if total_expected > 0 else 1]}, 'bar': {'color': bar_color}}
    ))
    fig_gauge.update_layout(margin=dict(t=50, b=10))

    if selected_employee and selected_employee != 'all':
        total_days_present = len(filtered_df)
        fig_att_gauge = go.Figure(go.Indicator(
            mode = "gauge+number", value = total_days_present,
            title = {'text': f"Days Present"},
            number = {'suffix': f" / {total_working_days_in_range}"},
            gauge = {'axis': {'range': [0, total_working_days_in_range if total_working_days_in_range > 0 else 1]}, 'bar': {'color': "#2ca02c"}}
        ))
        fig_att_gauge.update_layout(margin=dict(t=50, b=10))
    else:
        fig_att_gauge = {"layout": {"xaxis": {"visible": False}, "yaxis": {"visible": False}, "annotations": [{"text": "Select employee for attendance", "xref": "paper", "yref": "paper", "showarrow": False}]}}

    df_pie_hours = filtered_df.groupby('person_name')['work_duration_hours'].sum().reset_index()
    df_pie_hours = df_pie_hours[df_pie_hours['work_duration_hours'] > 0]
    if df_pie_hours.empty:
        fig_pie_hours = {"layout": {"annotations": [{"text": "No data", "xref": "paper", "yref": "paper", "showarrow": False}]}}
    else:
        df_pie_hours['hours_text'] = df_pie_hours['work_duration_hours'].apply(format_hours)
        fig_pie_hours = px.pie(df_pie_hours, values='work_duration_hours', names='person_name', title=f'Work Hours')
        fig_pie_hours.update_traces(text=df_pie_hours['hours_text'], textinfo='text', textposition='inside')
          
    late_days_df = filtered_df[filtered_df['first_in'] > LATE_THRESHOLD_STR].copy()
    late_days_summary = late_days_df.groupby('person_name')['date'].count().reset_index().rename(columns={'date': 'Late Days'})

    short_days_df = filtered_df[filtered_df['work_duration_hours'] < HOURS_THRESHOLD].copy()
    short_days_summary = short_days_df.groupby('person_name')['date'].count().reset_index().rename(columns={'date': 'Short Hour Days'})

    summary_df = filtered_df.groupby('person_name').agg(
        Total_Hours_Done_Decimal=('work_duration_hours', 'sum'),
        Total_Days_Attended=('date', 'count')
    ).reset_index()
    
    summary_df = summary_df.merge(late_days_summary, on='person_name', how='left')
    summary_df = summary_df.merge(short_days_summary, on='person_name', how='left')
    summary_df['Late Days'] = summary_df['Late Days'].fillna(0).astype(int)
    summary_df['Short Hour Days'] = summary_df['Short Hour Days'].fillna(0).astype(int)

    summary_df['Total_Hours_Done'] = summary_df['Total_Hours_Done_Decimal'].apply(format_hours)
    summary_df['Total_Hours_To_Be_Done_Decimal'] = total_working_days_in_range * HOURS_THRESHOLD
    summary_df['Total_Hours_To_Be_Done'] = summary_df['Total_Hours_To_Be_Done_Decimal']
    summary_df['Total_Days_To_Be_Attended'] = total_working_days_in_range
    
    summary_df_final = summary_df.rename(columns={
        'person_name': 'Employee',
        'Total_Days_Attended': 'Days Attended',
        'Total_Days_To_Be_Attended': 'Total Work Days',
        'Total_Hours_Done': 'Hours Done',
        'Total_Hours_To_Be_Done': 'Hours Expected',
        'Late Days': 'Late Days',
        'Short Hour Days': 'Short Hour Days'
    })
    
    final_columns_with_helpers = ['Employee', 'Days Attended', 'Total Work Days', 'Hours Done', 'Hours Expected', 'Late Days', 'Short Hour Days', 'Total_Hours_Done_Decimal', 'Total_Hours_To_Be_Done_Decimal']
    summary_df_final = summary_df_final[final_columns_with_helpers]
    summary_df_final['Hours Expected'] = summary_df_final['Hours Expected'].apply(lambda x: f"{x:.0f}")

    final_columns_display = [col for col in final_columns_with_helpers if '_Decimal' not in col]
    table_columns = [{"name": i, "id": i} for i in final_columns_display]
    table_data = summary_df_final.to_dict('records')

    style_data_conditional = [
        {'if': {'row_index': 'odd'}, 'backgroundColor': 'rgb(248, 248, 248)'},
        {'if': {'filter_query': '{Late Days} > 0', 'column_id': 'Late Days'}, 'backgroundColor': '#FFC0CB', 'color': 'black'},
        {'if': {'filter_query': '{Short Hour Days} > 0', 'column_id': 'Short Hour Days'}, 'backgroundColor': '#FFE0B2', 'color': 'black'},
        {'if': {'filter_query': '{Total_Hours_Done_Decimal} < {Total_Hours_To_Be_Done_Decimal}', 'column_id': 'Hours Done'}, 'backgroundColor': '#FFE0B2', 'color': 'black'}
    ]
    
    return fig_gauge, fig_att_gauge, fig_pie_hours, table_data, table_columns, style_data_conditional

@app.callback(
    Output('leave-status', 'children'),
    Input('btn-apply-leave', 'n_clicks'),
    State('leave-type', 'value'),
    State('leave-date-range', 'start_date'),
    State('leave-date-range', 'end_date'),
    State('leave-reason', 'value'),
    prevent_initial_call=True
)
def apply_leave(n_clicks, leave_type, start_date, end_date, reason):
    user = session.get('user')
    if not user:
        return "Session expired. Please login."

    if not all([leave_type, start_date, end_date, reason]):
        return "Please fill all fields"

    conn = get_db_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            INSERT INTO leave_requests
            (employee_name, leave_type, from_date, to_date, reason, status)
            VALUES (%s,%s,%s,%s,%s,'Pending')
        """, (user['name'], leave_type, start_date, end_date, reason))

        conn.commit()
        return "Leave request submitted successfully"
    except mysql.connector.Error as err:
        return f"Database Error: {err}"
    finally:
        cur.close()
        conn.close()
        
@app.callback(
    Output('my-leave-table', 'data'),
    [Input('btn-apply-leave', 'n_clicks'),
     Input('main-tabs', 'value')],
    State('session-store', 'data')
)
def load_my_leaves(n, tab, user):
    if not user:
        return []

    conn = get_db_connection()
    cur = conn.cursor(dictionary=True)

    try:
        # FIXED: Querying where employee_name = user['name']
        cur.execute("""
            SELECT leave_type, from_date, to_date, reason, status, admin_comment
            FROM leave_requests
            WHERE employee_name=%s
            ORDER BY created_at DESC
        """, (user["name"],))

        rows = cur.fetchall()
        return rows
    except Exception as e:
        return []
    finally:
        cur.close()
        conn.close()
        
@app.callback(
    Output('leave-approval-table', 'data'),
    Input('main-tabs', 'value')
)
def load_pending_leaves(tab):
    if tab != 'tab-approvals':
        return []

    conn = get_db_connection()
    # FIXED: Selecting employee_name
    try:
        df = pd.read_sql("""
            SELECT id, employee_name, from_date, to_date, reason
            FROM leave_requests
            WHERE status='pending'
        """, conn)
        
        if not df.empty:
            df['approve'] = df['id'].apply(lambda x: f"[Approve](approve:{x})")
            df['reject'] = df['id'].apply(lambda x: f"[Reject](reject:{x})")
            return df.to_dict('records')
    except Exception:
        pass
    finally:
        conn.close()
    
    return []

@app.callback(
    Output('leave-approval-status', 'children'),
    Input('leave-approval-table', 'active_cell'),
    State('leave-approval-table', 'data'),
    prevent_initial_call=True
)
def handle_leave_approval(cell, rows):
    if not cell:
        return ""

    row = rows[cell['row']]
    leave_id = row['id']

    action = cell['column_id']
    status = 'approved' if action == 'approve' else 'rejected'

    conn = get_db_connection()
    cur = conn.cursor()

    conn.commit()
    conn.close()

    return f"Leave {status.upper()} successfully"

@app.callback(
    Output('download-daywise-xlsx', 'data'),
    Input('btn-download-day', 'n_clicks'),
    [State('data-store', 'data'),
     State('day-picker', 'date')],
    prevent_initial_call=True
)
def download_day_report(n_clicks, json_data, selected_date):
    if not json_data:
        return dash.no_update
    
    selected_date_dt = pd.to_datetime(selected_date).date()
    excel_bytes = generate_day_report_excel(json_data, selected_date)
    filename = f"day_summary_{selected_date_dt}.xlsx"
    return dcc.send_bytes(excel_bytes, filename)

@app.callback(
    Output('download-monthwise-xlsx', 'data'),
    Input('btn-download-month', 'n_clicks'),
    [State('data-store', 'data'),
     State('holiday-store', 'data'),
     State('month-dropdown', 'value'),
     State('year-dropdown', 'value')],
    prevent_initial_call=True
)
def download_month_report(n_clicks, json_data, holiday_data, selected_month, selected_year):
    if not all([json_data, holiday_data, selected_month, selected_year]):
        return dash.no_update

    excel_bytes = generate_summary_report_excel(json_data, holiday_data, selected_month, selected_year)
    filename = f"month_attendance_summary_{selected_year}_{selected_month}.xlsx"
    return dcc.send_bytes(excel_bytes, filename)

@app.callback(
    Output('download-detailed-month-xlsx', 'data'),
    Input('btn-download-detailed-month', 'n_clicks'),
    [State('data-store', 'data'),
     State('holiday-store', 'data'),
     State('month-dropdown', 'value'),
     State('year-dropdown', 'value'),
     State('month-employee-filter', 'value')],
    prevent_initial_call=True
)
def download_detailed_month_report(n_clicks, json_data, holiday_data, selected_month, selected_year, selected_employee):
    if not all([json_data, holiday_data, selected_month, selected_year]):
        return dash.no_update

    excel_bytes = generate_detailed_report_excel(json_data, holiday_data, selected_month, selected_year, selected_employee)
    
    filename = f"detailed_month_report_{selected_year}_{selected_month}"
    if selected_employee and selected_employee != 'all':
        filename += f"_{selected_employee}"
    filename += ".xlsx"
    
    return dcc.send_bytes(excel_bytes, filename)


@app.callback(
    [Output('holiday-store', 'data'),
     Output('holiday-table', 'data')],
    [Input('interval-component', 'n_intervals'),
     Input('add-holiday-button', 'n_clicks'), 
     Input('holiday-table', 'data_timestamp')]
)
def update_holiday_store_and_table(n_interval, n_clicks, delete_timestamp):
    df = fetch_holidays()
    holiday_dict = {
        'date_list': df['holiday_date'].tolist()
    }
    table_data = df.to_dict('records')
    return holiday_dict, table_data

@app.callback(
    Output('holiday-add-status', 'children'),
    Input('add-holiday-button', 'n_clicks'),
    [State('holiday-date-picker', 'date'),
     State('holiday-desc-input', 'value')],
    prevent_initial_call=True
)
def add_holiday(n_clicks, new_date, new_desc):
    if not new_date:
        return "Please select a date."
    
    db_connection = get_db_connection()
    if db_connection:
        try:
            cursor = db_connection.cursor()
            query = "INSERT INTO holidays (holiday_date, description) VALUES (%s, %s)"
            cursor.execute(query, (new_date, new_desc))
            db_connection.commit()
            return f"Successfully added {new_date} - {new_desc}"
        except mysql.connector.Error as err:
            return f"Error: {err}"
        finally:
            cursor.close()
            db_connection.close()
    return "Could not connect to database."

@app.callback(
    Output('holiday-delete-status', 'children'),
    Input('holiday-table', 'data_previous'),
    State('holiday-table', 'data'),
    prevent_initial_call=True
)
def delete_holiday_row(previous_data, current_data):
    if previous_data is None or len(previous_data) <= len(current_data):
        return ""
        
    deleted_row = None
    current_ids = {row['id'] for row in current_data}
    for row in previous_data:
        if row['id'] not in current_ids:
            deleted_row = row
            break
            
    if deleted_row is None:
        return ""
        
    db_connection = get_db_connection()
    if db_connection:
        try:
            cursor = db_connection.cursor()
            query = "DELETE FROM holidays WHERE id = %s"
            cursor.execute(query, (deleted_row['id'],))
            db_connection.commit()
            return f"Successfully deleted {deleted_row['holiday_date']}"
        except mysql.connector.Error as err:
            return f"Error deleting: {err}"
        finally:
            cursor.close()
            db_connection.close()
    return "Could not connect to database."

@app.callback(
    [Output('salary-table', 'data'),
     Output('salary-table', 'columns')],
    [Input('btn-generate-salary', 'n_clicks')],
    [State('data-store', 'data'),
     State('holiday-store', 'data'),
     State('employee-store', 'data'), 
     State('salary-month-dropdown', 'value'),
     State('salary-year-dropdown', 'value'),
     State('salary-exception-days', 'value')],
    prevent_initial_call=True
)
def generate_salary_report(n_clicks, json_data, holiday_data, employee_data, 
                           selected_month, selected_year, exception_days_str):
    if not all([json_data, holiday_data, employee_data, selected_month, selected_year]):
        return [], []

    df = pd.read_json(io.StringIO(json_data), orient='split')
    df['date'] = pd.to_datetime(df['date'])
    
    salary_df = pd.read_json(io.StringIO(employee_data), orient='split')
    if salary_df.empty:
        return [], []

    date_filtered_df = df[
        (df['date'].dt.month == selected_month) &
        (df['date'].dt.year == selected_year)
    ]

    holidays_list = holiday_data.get('date_list', [])
    
    total_calendar_days = calendar.monthrange(selected_year, selected_month)[1]
    if total_calendar_days == 0:
        return [], []
        
    today_obj = date.today()
    current_report_year = today_obj.year
    current_report_month = today_obj.month
    
    attendance_summary = date_filtered_df.groupby('person_name').agg(
        Total_Days_Attended=('date', 'count')
    ).reset_index()
    summary_df = salary_df.merge(attendance_summary, on='person_name', how='left')
    summary_df['Total_Days_Attended'] = summary_df['Total_Days_Attended'].fillna(0)
    
    summary_df['Daily_Rate'] = summary_df['monthly_salary'] / total_calendar_days

    if selected_year == current_report_year and selected_month == current_report_month:
        
        chargeable_end_day = today_obj.day
        current_date_filtered_df = date_filtered_df[date_filtered_df['date'].dt.date <= today_obj]
        
        current_attendance_summary = current_date_filtered_df.groupby('person_name').agg(
            Total_Days_Attended=('date', 'count')
        ).reset_index()
        
        summary_df = salary_df.merge(current_attendance_summary, on='person_name', how='left')
        summary_df['Total_Days_Attended'] = summary_df['Total_Days_Attended'].fillna(0)
        summary_df['Daily_Rate'] = summary_df['monthly_salary'] / total_calendar_days

        paid_leave_days_count = get_paid_leave_days(selected_year, selected_month, holidays_list, chargeable_end_day)
        summary_df['Paid Leave Days'] = paid_leave_days_count
        
        chargeable_days_to_date = get_working_days(selected_year, selected_month, holidays_list, chargeable_end_day)
        summary_df['Chargeable Days (to date)'] = chargeable_days_to_date
        
        summary_df['Days Absent (to date)'] = summary_df['Chargeable Days (to date)'] - summary_df['Total_Days_Attended']
        summary_df['Days Absent (to date)'] = summary_df['Days Absent (to date)'].clip(lower=0)

        summary_df['Calculated_Salary'] = (summary_df['Total_Days_Attended'] * summary_df['Daily_Rate']) + \
                                          (summary_df['Paid Leave Days'] * summary_df['Daily_Rate'])
        
        summary_df.loc[summary_df['Total_Days_Attended'] == 0, 'Calculated_Salary'] = 0
                                          
        total_salary_paid = summary_df['Calculated_Salary'].sum()

        summary_df_final = summary_df.rename(columns={
            'person_name': 'Employee',
            'monthly_salary': 'M. Salary',
            'Total_Days_Attended': 'Attended',
            'Paid Leave Days': 'Paid Leave',
            'Chargeable Days (to date)': 'Chrg. Days',
            'Days Absent (to date)': 'Absent'
        })

        summary_df_final['M. Salary'] = summary_df_final['M. Salary'].map('{:,.2f}'.format)
        summary_df_final['Daily_Rate'] = summary_df_final['Daily_Rate'].map('{:,.2f}'.format)
        summary_df_final['Calculated_Salary'] = summary_df_final['Calculated_Salary'].map('{:,.2f}'.format)
        
        final_columns = [
            'Employee', 'M. Salary', 'Daily_Rate', 
            'Chrg. Days', 'Attended', 
            'Absent', 'Paid Leave', 'Calculated_Salary'
        ]
        
    else:
        
        chargeable_days_count = get_working_days(selected_year, selected_month, holidays_list, None)
        
        try:
            exception_days = int(exception_days_str)
        except (ValueError, TypeError):
            exception_days = 0
        if exception_days is None or exception_days < 0:
            exception_days = 0

        summary_df['Chargeable Days'] = chargeable_days_count
        summary_df['Days Absent'] = summary_df['Chargeable Days'] - summary_df['Total_Days_Attended']
        summary_df['Days Absent'] = summary_df['Days Absent'].clip(lower=0)
        summary_df['Exception Days'] = exception_days
        summary_df['Final Absent Days'] = summary_df['Days Absent'] - summary_df['Exception Days']
        summary_df['Final Absent Days'] = summary_df['Final Absent Days'].clip(lower=0)
        
        summary_df['Total_Deduction'] = summary_df['Final Absent Days'] * summary_df['Daily_Rate']
        summary_df['Calculated_Salary'] = summary_df['monthly_salary'] - summary_df['Total_Deduction']
        
        summary_df.loc[summary_df['Total_Days_Attended'] == 0, 'Calculated_Salary'] = 0
        summary_df.loc[summary_df['Total_Days_Attended'] == 0, 'Total_Deduction'] = summary_df['monthly_salary']

        total_salary_paid = summary_df['Calculated_Salary'].sum()
        
        summary_df_final = summary_df.rename(columns={
            'person_name': 'Employee',
            'monthly_salary': 'M. Salary',
            'Total_Days_Attended': 'Attended',
            'Chargeable Days': 'Chrg. Days',
            'Days Absent': 'Absent',
            'Exception Days': 'Exc. Days',
            'Final Absent Days': 'Final Absent',
        })
        
        summary_df_final['M. Salary'] = summary_df_final['M. Salary'].map('{:,.2f}'.format)
        summary_df_final['Daily_Rate'] = summary_df_final['Daily_Rate'].map('{:,.2f}'.format)
        summary_df_final['Total_Deduction'] = summary_df_final['Total_Deduction'].map('{:,.2f}'.format)
        summary_df_final['Calculated_Salary'] = summary_df_final['Calculated_Salary'].map('{:,.2f}'.format)
        
        final_columns = [
            'Employee', 'M. Salary', 'Chrg. Days', 'Attended', 
            'Absent', 'Exc. Days', 'Final Absent', 
            'Daily_Rate', 'Total_Deduction', 'Calculated_Salary'
        ]

    
    summary_df_final = summary_df_final[final_columns]
    
    table_columns = [{"name": i, "id": i} for i in summary_df_final.columns]
    table_data = summary_df_final.to_dict('records')
    
    total_row_values = {col: '-' for col in final_columns}
    total_row_values['Employee'] = 'Total'
    total_row_values['Calculated_Salary'] = f'{total_salary_paid:,.2f}'
    
    table_data.append(total_row_values)
    
    return table_data, table_columns

@app.callback(
    Output('download-salary-csv', 'data'),
    Input('btn-download-salary', 'n_clicks'),
    [State('salary-table', 'data'),
     State('salary-month-dropdown', 'value'),
     State('salary-year-dropdown', 'value')],
    prevent_initial_call=True
)
def download_salary_report(n_clicks, table_data, selected_month, selected_year):
    if not table_data:
        return dash.no_update
        
    df = pd.DataFrame(table_data)
    filename = f"salary_report_{selected_year}_{selected_month}.csv"
    
    return dcc.send_data_frame(df.to_csv, filename, index=False)


@app.callback(
    Output('add-employee-status', 'children'),
    Input('btn-add-employee', 'n_clicks'),
    [State('new-emp-name', 'value'),
     State('new-emp-salary', 'value')],
    prevent_initial_call=True
)
def add_new_employee(n_clicks, name, salary):
    if not name or not salary:
        return "Please provide both name and salary."
        
    if float(salary) < 0:
        return "Salary cannot be negative."

    name_parts = name.strip().split()
    if len(name_parts) >= 2:
        first_name = name_parts[0].lower()
        last_name = name_parts[-1].lower()
        first_name = ''.join(e for e in first_name if e.isalnum())
        last_name = ''.join(e for e in last_name if e.isalnum())
        base_username = f"{first_name}{last_name}"
    else:
        base_username = name_parts[0].lower()
        base_username = ''.join(e for e in base_username if e.isalnum())

    default_password = "ai@123"
    default_role = "employee"
    
    db_connection = get_db_connection()
    if db_connection:
        try:
            cursor = db_connection.cursor(dictionary=True)
            query_check = "SELECT username FROM employees WHERE username LIKE %s"
            cursor.execute(query_check, (base_username + '%',))
            existing_users = cursor.fetchall()  
            existing_usernames_set = {user['username'] for user in existing_users} 
            final_username = base_username
            counter = 1
            while final_username in existing_usernames_set:
                final_username = f"{base_username}{counter}"
                counter += 1
            query_insert = """
                INSERT INTO employees 
                (person_name, monthly_salary, username, password, role) 
                VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(query_insert, (name, salary, final_username, default_password, default_role))
            db_connection.commit()
            
            return f"Success! Added '{name}'. Assigned Username: '{final_username}'"
            
        except mysql.connector.Error as err:
            return f"Database Error: {err}"
        finally:
            cursor.close()
            db_connection.close()
    return "Could not connect to database."

@app.callback(
    Output('editable-salary-table', 'data'),
    Input('btn-load-salaries', 'n_clicks'),
    State('employee-store', 'data'),
    prevent_initial_call=True
)
def load_salaries_for_editing(n_clicks, employee_data):
    if not employee_data:
        return []
    
    salary_df = pd.read_json(io.StringIO(employee_data), orient='split')
    return salary_df.to_dict('records')

@app.callback(
    Output('save-salary-status', 'children'),
    Input('btn-save-salaries', 'n_clicks'),
    State('editable-salary-table', 'data'),
    prevent_initial_call=True
)
def save_edited_salaries(n_clicks, table_data):
    if not table_data:
        return "No data to save."
        
    db_connection = get_db_connection()
    if db_connection:
        try:
            cursor = db_connection.cursor()
            query = "UPDATE employees SET monthly_salary = %s WHERE person_name = %s"
            update_data = [(row['monthly_salary'], row['person_name']) for row in table_data]
            
            cursor.executemany(query, update_data)
            db_connection.commit()
            return f"Successfully updated {len(update_data)} employee records."
        except mysql.connector.Error as err:
            return f"Error updating: {err}"
        finally:
            cursor.close()
            db_connection.close()
    return "Could not connect to database."

if __name__ == '__main__':
    # Server is handled in server.py
    pass