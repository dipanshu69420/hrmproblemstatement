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
import config
import threading
import watcher
import xmlrpc.client
import pytz
import time
import warnings
import logging

warnings.filterwarnings("ignore")
logging.getLogger('werkzeug').setLevel(logging.ERROR)
logging.getLogger('urllib3').setLevel(logging.ERROR)

LATE_THRESHOLD_TIME = datetime.time(10, 0, 0)
LATE_THRESHOLD_STR = "10:00:00"
HOURS_THRESHOLD = 9.0
DEFAULT_ROLE = "admin"
DEFAULT_USERNAME = "Admin"

def format_hours(decimal_hours):
    if pd.isna(decimal_hours):
        return "-"
    if isinstance(decimal_hours, str):
        return decimal_hours
    hours = int(decimal_hours)
    minutes = int((decimal_hours - hours) * 60)
    return f"{hours}h {minutes}m"


def get_working_days(selected_year, selected_month, holidays_list, end_day=None):
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
    holidays_set = set(holidays_list)
    is_not_holiday = (~all_days_in_range.strftime('%Y-%m-%d').isin(holidays_set))
    total_working_days = (is_weekday & is_not_holiday).sum()
    return total_working_days

def get_paid_leave_days(selected_year, selected_month, holidays_list, end_day=None):
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
    holidays_set = set(holidays_list)
    is_manual_holiday = (all_days_in_range.strftime('%Y-%m-%d').isin(holidays_set))
    total_paid_leave_days = (is_sunday | is_manual_holiday).sum()
    return total_paid_leave_days

def get_db_connection():
    try:
        db_connection = mysql.connector.connect(
            host=config.DB_HOST,
            user=config.DB_USER,
            password=config.DB_PASS,
            database=config.DB_NAME
        )
        return db_connection
    except mysql.connector.Error as err:
        print(f"Error connecting to DB: {err}")
        return None

def fetch_data():
    sql_query = """
    SELECT
        id,
        person_name,
        date,
        TIME_FORMAT(MIN(time), '%H:%i:%s') AS first_in,  
        TIME_FORMAT(MAX(time), '%H:%i:%s') AS last_out, 
        TIME_TO_SEC(TIMEDIFF(MAX(time), MIN(time))) / 3600 AS work_duration_hours
    FROM
        new_report
    WHERE
        person_name IN (
            SELECT DISTINCT person_name
            FROM new_report
            WHERE direction = 'IN'
        )
    GROUP BY
        id, person_name, date;
    """
    db_connection = get_db_connection()
    if db_connection:
        try:
            df = pd.read_sql(sql_query, db_connection)
            return df
        except pd.io.sql.DatabaseError as err:
            print(f"Error fetching data: {err}")
        finally:
            db_connection.close()
            
    return pd.DataFrame(columns=['id','person_name', 'date', 'first_in', 'last_out', 'work_duration_hours'])

def fetch_holidays():
    db_connection = get_db_connection()
    if db_connection:
        try:
            df = pd.read_sql("SELECT id, DATE_FORMAT(holiday_date, '%Y-%m-%d') as holiday_date, description FROM holidays ORDER BY holiday_date", db_connection)
            return df
        except pd.io.sql.DatabaseError as err:
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
        except pd.io.sql.DatabaseError as err:
            print(f"Error fetching employee salaries: {err}")
        finally:
            db_connection.close()
            
    return pd.DataFrame(columns=['person_name', 'monthly_salary', 'mobile_no'])

def push_to_odoo(row):
    try:
        local_tz = pytz.timezone('Asia/Kolkata')
        date_val = str(row['date'])
        date_str = date_val.split('T')[0] if 'T' in date_val else date_val.split()[0]
        in_dt_str = f"{date_str} {row['first_in']}"
        out_dt_str = f"{date_str} {row['last_out']}"
    
        dt_in = datetime.datetime.strptime(in_dt_str, "%Y-%m-%d %H:%M:%S")
        dt_in = local_tz.localize(dt_in)
        
        dt_out = datetime.datetime.strptime(out_dt_str, "%Y-%m-%d %H:%M:%S")
        dt_out = local_tz.localize(dt_out)
        
        is_single_punch = abs((dt_out - dt_in).total_seconds()) < 60
        
        utc_in = dt_in.astimezone(pytz.utc).strftime('%Y-%m-%d %H:%M:%S')
        utc_out = False
        
        if not is_single_punch:
            utc_out = dt_out.astimezone(pytz.utc).strftime('%Y-%m-%d %H:%M:%S')

        common = xmlrpc.client.ServerProxy('{}/xmlrpc/2/common'.format(ODOO_URL))
        uid = common.authenticate(ODOO_DB, ODOO_USER, ODOO_PASS, {})
        
        if uid:
            print(f"Odoo Login Successful! UID = {uid}")
        else:
            return False, "Odoo Authentication Failed"

        
        # if not uid:
        #     return False, "Odoo Authentication Failed"

        models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(ODOO_URL))
        emp_badge_id = str(row['id']) 
        emp_ids = models.execute_kw(ODOO_DB, uid, ODOO_PASS, 'hr.employee', 'search', [[
            ['barcode', '=', emp_badge_id] 
        ]])
        
        if not emp_ids:
            return False, f"Employee with Badge ID '{emp_badge_id}' not found in odoo"
        
        odoo_employee_id = emp_ids[0]

        existing = models.execute_kw(ODOO_DB, uid, ODOO_PASS, 'hr.attendance', 'search', [[
            ['employee_id', '=', odoo_employee_id],
            ['check_in', '=', utc_in]
        ]])

        open_attendance=models.execute_kw(ODOO_DB, uid, ODOO_PASS,'hr.attendance', 'search_read',[[
        ['employee_id', '=', odoo_employee_id],
        ['check_out', '=', False]
            ]],{'fields': ['id', 'check_in']})
        if open_attendance:
            last_open=open_attendance[0]
            last_open_datetime = datetime.datetime.strptime(last_open['check_in'], "%Y-%m-%d %H:%M:%S")
            last_open_date = last_open_datetime.date()
            today=datetime.date.today()
            
            if last_open_date<today:
                checkout_date=last_open_datetime.replace(hour=19, minute=0, second=0)
                checkout_str=checkout_date.strftime("%Y-%m-%d %H:%M:%S")
                models.execute_kw( ODOO_DB, uid, ODOO_PASS,'hr.attendance', 'write', [[ last_open['id'] ], {'check_out': checkout_str}]
        )
            
        if existing:
            if utc_out:
                models.execute_kw(ODOO_DB, uid, ODOO_PASS, 'hr.attendance', 'write', [[existing[0]],{'check_out': utc_out}])
                return True, "Updated CheckOut"
            return True, "No Change"
        else:
            vals={
                'employee_id': odoo_employee_id,
                'check_in': utc_in,
            }
            if utc_out:
                vals['check_out']=utc_out
                
            models.execute_kw(ODOO_DB, uid, ODOO_PASS, 'hr.attendance', 'create', [[vals]])
            return True, "New Entry Created"
            
    except Exception as e:
        print(f"Sync Error: {e}")
        return False, str(e)
    
SYNC_EMP_IDS = ['152', 'WL64', 'WL62', 'AI96', 'WL54']

def auto_sync():
    try:
        while True:
            df = fetch_data()

            if not df.empty:
                df['date'] = pd.to_datetime(df['date'])
                today = date.today()
                df = df[df['date'].dt.date == today]
                df = df[df['id'].astype(str).isin(SYNC_EMP_IDS)]
                complete_records = df.dropna(subset=['first_in', 'last_out']).copy()
                if not complete_records.empty:
                    for _, row in complete_records.iterrows():
                        success, msg = push_to_odoo(row)
                        print(f"[{success} | {row['id']} | {row['date'].date()}] {msg}")
            time.sleep(60)
    except Exception as e:
        print(f"Background Sync Error: {e}") 
                     
app = dash.Dash(__name__,
                external_stylesheets=['https://codepen.io/chriddyp/pen/bWLwgP.css'],
                title='AtyaInno Attendance Dashboard',
                suppress_callback_exceptions=True)

today = date.today()
current_year = today.year
current_month = today.month

month_options = [{'label': calendar.month_name[i], 'value': i} for i in range(1, 13)]
year_options_default = [{'label': str(y), 'value': y} for y in range(current_year - 2, current_year + 2)]
app.layout = get_dashboard_layout(
    role=DEFAULT_ROLE,
    username=DEFAULT_USERNAME
)

def get_dashboard_layout(role='employee', username='User'):
    if role == 'admin':
        dropdown_value = 'all'
        dropdown_disabled = False
        dropdown_options = [{'label': 'All Employees', 'value': 'all'}] 
    else:
        dropdown_value = username 
        dropdown_disabled = True
        dropdown_options = [{'label': username, 'value': username}]

    download_btn_style = {'width': '100%', 'margin-top': '5px'}
    month_btn_style = {'flex': 1}
    
    if role == 'employee':
        download_btn_style = {'display': 'none'}
        month_btn_style = {'display': 'none'}
        
    tabs_children = []
    dashboard_tab = dcc.Tab(label='Dashboard', value='tab-dashboard',
                style={'padding': '0px', 'line-height': '40px'},
                selected_style={'padding': '0px', 'line-height': '40px'},
                children=[
            html.Div(style={
                'display': 'flex', 'height': '90vh', 'width': '100%',
                'padding': '10px', 'gap': '10px', 'box-sizing': 'border-box'
            }, children=[
                html.Div(style={
                    'flex': 1, 'display': 'flex', 'flex-direction': 'column',
                    'border': '1px solid #ddd', 'padding': '10px',
                    'gap': '10px', 'box-shadow': '0 2px 4px rgba(0,0,0,0.1)', 'overflow': 'hidden'
                }, children=[
                    html.H3("Daywise Report", style={'text-align': 'center', 'margin': '0 0 10px 0'}),
                    html.Div([
                        html.Label("Select Date:", style={'font-weight': 'bold'}),
                        dcc.DatePickerSingle(id='day-picker', date=today, display_format='DD-MM-YYYY', style={'width': '100%'}),
                    ]),
                    html.Div([
                        html.Label("Select Employee:", style={'font-weight': 'bold'}),
                        dcc.Dropdown(id='day-employee-filter', options=dropdown_options, value=dropdown_value, disabled=dropdown_disabled, clearable=False)
                    ]),
                    html.Button("Download Day Report", id='btn-download-day', style=download_btn_style),
                    dcc.Graph(id='daily-attendance-gauge', style={'height': '35%'}, config={'responsive': True}),
                    dcc.Graph(id='daily-hours-indicator', style={'height': "10%"}, config={'responsive': True}),
                    html.Div(style={'display': 'flex', 'flex': 1.5, 'gap': '10px', 'overflow': 'hidden', 'min-height': '100px'}, children=[
                        html.Div(style={'flex': 1, 'border': '1px solid #eee', 'padding': '5px', 'overflowY': 'auto'}, children=[
                            html.H5("Present", style={'text-align': 'center', 'margin': '5px'}),
                            html.Ul(id='present-list', style={'padding': '0 10px', 'margin': 0, 'list-style-type': 'none', 'font-size': '14px'})
                        ]),
                        html.Div(style={'flex': 1, 'border': '1px solid #eee', 'padding': '5px', 'overflowY': 'auto'}, children=[
                            html.H5("Absent", style={'text-align': 'center', 'margin': '5px'}),
                            html.Ul(id='absent-list', style={'padding': '0 10px', 'margin': 0, 'list-style-type': 'none', 'font-size': '14px'})
                        ]),
                    ])
                ]),
                html.Div(style={
                    'flex': 2, 'display': 'flex', 'flex-direction': 'column',
                    'border': '1px solid #ddd', 'padding': '10px',
                    'gap': '10px', 'box-shadow': '0 2px 4px rgba(0,0,0,0.1)'
                }, children=[
                    html.H3("Monthwise Report", style={'text-align': 'center', 'margin': '0 0 10px 0'}),
                    html.Div(style={'display': 'flex', 'gap': '10px', 'align-items': 'flex-end'}, children=[
                        html.Div(style={'flex': 1}, children=[
                            html.Label("Month:", style={'font-weight': 'bold'}),
                            dcc.Dropdown(id='month-dropdown', options=month_options, value=current_month, clearable=False),
                        ]),
                        html.Div(style={'flex': 1}, children=[
                            html.Label("Year:", style={'font-weight': 'bold'}),
                            dcc.Dropdown(id='year-dropdown', options=year_options_default, value=current_year, clearable=False),
                        ]),
                        html.Div(style={'flex': 1}, children=[
                            html.Label("Employee (Month):", style={'font-weight': 'bold'}),
                            dcc.Dropdown(id='month-employee-filter', options=dropdown_options, value=dropdown_value, disabled=dropdown_disabled, clearable=False),
                        ]),
                    ]),
                    html.Div(style={'display': 'flex', 'gap': '10px', 'margin-top': '5px'}, children=[
                        html.Button("Download Monthly Summary", id='btn-download-month', style=month_btn_style),
                        html.Button("Download Monthly Detailed Summary", id='btn-download-detailed-month', style=month_btn_style),
                    ]),
                    html.Div(style={'display': 'flex', 'flex': 0.9, 'gap': '10px'}, children=[
                        dcc.Graph(id='hours-gauge', style={'flex': 1, 'height': "70%"}, config={'responsive': True}),
                        dcc.Graph(id='attendance-gauge', style={'flex': 1, "height": "70%"}, config={'responsive': True}),
                    ]),
                    html.Div(style={'display': 'flex', 'flex': 0.8, 'gap': '10px', 'overflow': 'hidden'}, children=[
                        dcc.Graph(id='live-work-hours-pie', style={'flex': 1,"height": "110%"}, config={'responsive': True}),
                        html.Div(style={'flex': 1, 'overflowY': 'auto', 'height': '100%'}, children=[
                            dash_table.DataTable(id='monthly-summary-table', style_table={'height': '100%', 'overflowY': 'auto', 'border': 'none'}, style_cell={'textAlign': 'left', 'padding': '5px', 'border': 'none'}, style_header={'backgroundColor': 'rgb(230, 230, 230)', 'fontWeight': 'bold', 'border': 'none'})
                        ])
                    ]),
                ]),
            ])
        ])
    tabs_children.append(dashboard_tab)
    holiday_add_style = {'padding': '20px'}
    holiday_table_editable = True
    holiday_row_deletable = True
    
    if role == 'employee':
        holiday_add_style = {'display': 'none'} 
        holiday_table_editable = False
        holiday_row_deletable = False

    holiday_tab = dcc.Tab(label='Holiday Management', value='tab-admin',
            style={'padding': '0px', 'line-height': '40px'},
            selected_style={'padding': '0px', 'line-height': '40px'},
            children=[
        html.Div(style={'padding': '20px'}, children=[
            
            html.Div(style=holiday_add_style, children=[
                html.H3("Add New Holiday"),
                html.Div(style={'display': 'flex', 'gap': '10px', 'align-items': 'flex-end'}, children=[
                    html.Div([html.Label("Holiday Date:"), dcc.DatePickerSingle(id='holiday-date-picker', date=date.today(), display_format='DD-MM-YYYY')]),
                    html.Div(style={'flex': 1}, children=[html.Label("Description:"), dcc.Input(id='holiday-desc-input', type='text', placeholder='e.g., New Year', style={'width': '100%'})]),
                    html.Button('Add Holiday', id='add-holiday-button'),
                ]),
                html.Div(id='holiday-add-status', style={'margin-top': '10px'}),
                html.Hr(style={'margin': '20px 0'}),
            ]),
            
            html.H3("Current Holiday List"),
            dash_table.DataTable(
                id='holiday-table', 
                columns=[{'name': 'Date', 'id': 'holiday_date', 'editable': holiday_table_editable}, 
                         {'name': 'Description', 'id': 'description', 'editable': holiday_table_editable}], 
                data=[], 
                row_deletable=holiday_row_deletable,
                page_action='native', page_current=0, page_size=10, style_cell={'textAlign': 'left'}
            ),
            html.Div(id='holiday-delete-status', style={'margin-top': '10px'})
        ])
    ])
    tabs_children.append(holiday_tab)

    if role == 'admin':
        salary_tab = dcc.Tab(label='Salary Management', value='tab-salary',
                style={'padding': '0px', 'line-height': '40px'},
                selected_style={'padding': '0px', 'line-height': '40px'},
                children=[
            html.Div(style={'padding': '20px', 'display': 'flex', 'gap': '20px'}, children=[
                html.Div(style={'flex': 1, 'border': '1px solid #ddd', 'padding': '10px', 'border-radius': '5px'}, children=[
                    html.H3("Employee Salary Management"),
                    html.H5("Add New Employee Salary"),
                    html.Div(style={'display': 'flex', 'gap': '10px', 'align-items': 'center'}, children=[
                        dcc.Input(id='new-emp-name', placeholder='Type or Select Employee Name', style={'flex': 2}, list='list-employee-names'),
                        html.Datalist(id='list-employee-names', children=[]),
                        dcc.Input(id='new-emp-salary', placeholder='Monthly Salary', type='number', style={'flex': 1}),
                        html.Button('Add', id='btn-add-employee', style={'flex': 0.5})
                    ]),
                    html.Div(id='add-employee-status', style={'margin-top': '5px', 'margin-bottom': '15px'}),
                    html.Hr(),
                    html.H5("Edit Existing Salaries"),
                    html.Button('Load Employee Salaries', id='btn-load-salaries', style={'margin-bottom': '10px', 'width': '100%'}),
                    dash_table.DataTable(id='editable-salary-table', columns=[{'name': 'Employee Name', 'id': 'person_name', 'editable': False}, {'name': 'Monthly Salary', 'id': 'monthly_salary', 'editable': True, 'type': 'numeric'}], data=[], editable=True, style_cell={'textAlign': 'left'}, style_header={'backgroundColor': 'rgb(240, 240, 240)', 'fontWeight': 'bold'}),
                    html.Button('Save Salary Changes', id='btn-save-salaries', style={'margin-top': '10px', 'width': '100%'}),
                    html.Div(id='save-salary-status', style={'margin-top': '5px'})
                ]),
                html.Div(style={'flex': 2, 'border': '1px solid #ddd', 'padding': '10px', 'border-radius': '5px'}, children=[
                    html.H3("Generate Salary Report"),
                    html.Div(style={'display': 'flex', 'gap': '10px', 'align-items': 'flex-end', 'margin-bottom': '10px'}, children=[
                        html.Div(style={'flex': 1}, children=[html.Label("Month:", style={'font-weight': 'bold'}), dcc.Dropdown(id='salary-month-dropdown', options=month_options, value=current_month, clearable=False)]),
                        html.Div(style={'flex': 1}, children=[html.Label("Year:", style={'font-weight': 'bold'}), dcc.Dropdown(id='salary-year-dropdown', options=year_options_default, value=current_year, clearable=False)]),
                        html.Div(style={'flex': 1}, children=[html.Label("Exception Days (Grace):", style={'font-weight': 'bold'}), dcc.Input(id='salary-exception-days', type='number', value=0, min=0, step=1, style={'width': '100%'})]),
                    ]),
                    
                    html.Div(style={'display': 'flex', 'gap': '10px'}, children=[
                        html.Button('Generate Salary Report', id='btn-generate-salary', style={'flex': 1}),
                        html.Button("Download (CSV)", id='btn-download-salary', style={'flex': 1})
                    ]),
                    html.Hr(),
                    dash_table.DataTable(id='salary-table', columns=[], data=[], page_action='native', page_current=0, page_size=15, style_table={'overflowX': 'auto'}, style_cell={'textAlign': 'left', 'padding': '5px', 'font-family': 'sans-serif', 'fontSize': '12px', 'whiteSpace': 'normal', 'height': 'auto', 'minWidth': '40px', 'maxWidth': '90px', 'width': 'auto'}, style_header={'backgroundColor': 'rgb(230, 230, 230)', 'fontWeight': 'bold', 'textAlign': 'center', 'whiteSpace': 'normal', 'height': 'auto'}, style_data_conditional=[{'if': {'row_index': 'odd'}, 'backgroundColor': 'rgb(248, 248, 248)'}])
                ])
            ])
        ])
        tabs_children.append(salary_tab)

    hidden_admin_components = []
    if role != 'admin':
        hidden_admin_components = [
            html.Button(id='btn-save-salaries'),
            html.Button(id='btn-add-employee'),
            html.Button(id='btn-sync-odoo'),
            html.Button(id='btn-load-salaries'),
            html.Button(id='btn-generate-salary'),
            html.Button(id='btn-download-salary'),
            dcc.Input(id='new-emp-name'),
            dcc.Input(id='new-emp-salary'),
            html.Div(id='list-employee-names', style={'display': 'none'}),
            dash_table.DataTable(id='editable-salary-table'),
            dash_table.DataTable(id='salary-table'),
            dcc.Dropdown(id='salary-month-dropdown', value=current_month), 
            dcc.Dropdown(id='salary-year-dropdown', value=current_year), 
            dcc.Input(id='salary-exception-days', value=0)
        ]

    return html.Div([
        html.Div(style={'display': 'flex', 'justifyContent': 'space-between', 'alignItems': 'center', 'padding': '10px', 'backgroundColor': '#f8f9fa', 'borderBottom': '1px solid #ddd'}, children=[
            html.H4(f"Welcome, {username}", style={'margin': 0}),
            html.Button("Logout", id='btn-logout', style={'backgroundColor': '#dc3545', 'color': 'white'})
        ]),
        
        dcc.Store(id='data-store'),
        dcc.Store(id='holiday-store'),
        dcc.Store(id='employee-store'),
        dcc.Interval(id='interval-component', interval=300 * 1000, n_intervals=0),
        dcc.Download(id='download-daywise-xlsx'),
        dcc.Download(id='download-monthwise-xlsx'),
        dcc.Download(id='download-detailed-month-xlsx'),
        dcc.Download(id='download-salary-csv'),
        
        dcc.Tabs(id='main-tabs', value='tab-dashboard', style={'height': '40px'}, children=tabs_children)
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
    [Output('month-employee-filter', 'options'),
     Output('day-employee-filter', 'options'),
     Output('year-dropdown', 'options'),
     Output('salary-year-dropdown', 'options'),
     Output('list-employee-names', 'children')],
    [Input('data-store', 'data')],
)
def update_dropdowns(json_data, session_data):
    user_role = 'employee'
    user_name = ''
    if session_data:
        user_role = DEFAULT_ROLE
        user_name = DEFAULT_USERNAME
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

def generate_day_report_excel(json_data, selected_date):
    df = pd.read_json(io.StringIO(json_data), orient='split')
    df['date'] = pd.to_datetime(df['date'])

    selected_date_dt = pd.to_datetime(selected_date).date()
    day_filtered_df = df[df['date'].dt.date == selected_date_dt].copy()
    
    day_filtered_df['Status'] = ''
    day_filtered_df.loc[day_filtered_df['work_duration_hours'] < HOURS_THRESHOLD, 'Status'] += 'Short Hours '
    day_filtered_df.loc[day_filtered_df['first_in'] > LATE_THRESHOLD_STR, 'Status'] += 'Late '
    day_filtered_df['Status'] = day_filtered_df['Status'].str.strip()

    final_columns = ['Employee', 'Date', 'First In', 'Last Out', 'Hours Done', 'Hours Expected', 'Status']
    
    if day_filtered_df.empty:
        summary_df_final = pd.DataFrame(columns=final_columns)
    else:
        day_filtered_df['Hours Done'] = day_filtered_df['work_duration_hours'].apply(format_hours)
        day_filtered_df['Hours Expected'] = HOURS_THRESHOLD
        day_filtered_df = day_filtered_df.rename(columns={
            'person_name': 'Employee', 
            'date': 'Date',
            'first_in': 'First In',  
            'last_out': 'Last Out'   
        })
        summary_df_final = day_filtered_df[final_columns]
    
    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='xlsxwriter') as writer:
        
        df_for_excel = summary_df_final.drop(columns=['Status'])
        df_for_excel.to_excel(writer, sheet_name='Day Report', index=False)
        
        workbook = writer.book
        worksheet = writer.sheets['Day Report']
        
        late_format = workbook.add_format({'bg_color': '#FFC7CE', 'font_color': '#9C0006'})
        short_format = workbook.add_format({'bg_color': '#FFEB9C', 'font_color': '#9C6500'})

        first_in_col_idx = df_for_excel.columns.get_loc('First In')
        hours_done_col_idx = df_for_excel.columns.get_loc('Hours Done')
        
        for row_num, status in enumerate(summary_df_final['Status'], 1):
            if "Late" in status:
                cell_value = summary_df_final.iloc[row_num-1]['First In']
                worksheet.write(row_num, first_in_col_idx, cell_value, late_format)
                
            if "Short Hours" in status:
                cell_value = summary_df_final.iloc[row_num-1]['Hours Done']
                worksheet.write(row_num, hours_done_col_idx, cell_value, short_format)
                
        worksheet.set_column('A:A', 20)
        worksheet.set_column('B:D', 12)
        worksheet.set_column('E:F', 15)

    output.seek(0)
    return output.getvalue()

def generate_summary_report_excel(json_data, holiday_data, selected_month, selected_year):
    df = pd.read_json(io.StringIO(json_data), orient='split')
    df['date'] = pd.to_datetime(df['date'])

    date_filtered_df = df[
        (df['date'].dt.month == selected_month) &
        (df['date'].dt.year == selected_year)
    ]
    
    holidays_list = holiday_data.get('date_list', [])
    
    today_obj = date.today()
    end_day_to_check = None
    if selected_year == today_obj.year and selected_month == today_obj.month:
        end_day_to_check = today_obj.day
        date_filtered_df = date_filtered_df[date_filtered_df['date'].dt.date <= today_obj]
    
    total_working_days_in_range = get_working_days(selected_year, selected_month, holidays_list, end_day_to_check)

    late_days_df = date_filtered_df[date_filtered_df['first_in'] > LATE_THRESHOLD_STR].copy()
    late_days_summary = late_days_df.groupby('person_name')['date'].count().reset_index().rename(columns={'date': 'Late Days'})

    short_days_df = date_filtered_df[date_filtered_df['work_duration_hours'] < HOURS_THRESHOLD].copy()
    short_days_summary = short_days_df.groupby('person_name')['date'].count().reset_index().rename(columns={'date': 'Short Hour Days'})

    summary_df = date_filtered_df.groupby('person_name').agg(
        Total_Hours_Done_Decimal=('work_duration_hours', 'sum'),
        Total_Days_Attended=('date', 'count')
    ).reset_index()

    summary_df = summary_df.merge(late_days_summary, on='person_name', how='left')
    summary_df = summary_df.merge(short_days_summary, on='person_name', how='left')
    summary_df['Late Days'] = summary_df['Late Days'].fillna(0).astype(int)
    summary_df['Short Hour Days'] = summary_df['Short Hour Days'].fillna(0).astype(int)

    summary_df['Total_Hours_Done'] = summary_df['Total_Hours_Done_Decimal'].apply(format_hours)
    summary_df['Total_Hours_To_Be_Done'] = total_working_days_in_range * HOURS_THRESHOLD
    summary_df['Total_Days_To_Be_Attended'] = total_working_days_in_range
    
    summary_df_final = summary_df.rename(columns={
        'person_name': 'Employee',
        'Total_Days_Attended': 'Days Attended',
        'Total_Days_To_Be_Attended': 'Total Work Days',
        'Total_Hours_Done': 'Hours Done',
        'Total_Hours_To_Be_Done': 'Hours Expected (Month)',
        'Late Days': 'Late Days',
        'Short Hour Days': 'Short Hour Days'
    })
    
    summary_df_final = summary_df_final[
        ['Employee', 'Days Attended', 'Total Work Days', 'Hours Done',
         'Hours Expected (Month)', 'Late Days', 'Short Hour Days']
    ]

    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='xlsxwriter') as writer:
        summary_df_final.to_excel(writer, sheet_name='Month Summary', index=False)
        
        workbook = writer.book
        worksheet = writer.sheets['Month Summary']
        
        late_format = workbook.add_format({'bg_color': '#FFC7CE', 'font_color': '#9C0006'})
        short_format = workbook.add_format({'bg_color': '#FFEB9C', 'font_color': '#9C6500'})
        
        (max_row, max_col) = summary_df_final.shape
        
        late_col_idx = summary_df_final.columns.get_loc('Late Days')
        short_col_idx = summary_df_final.columns.get_loc('Short Hour Days')
        
        worksheet.conditional_format(1, late_col_idx, max_row, late_col_idx, {
            'type': 'cell',
            'criteria': '>',
            'value': 0,
            'format': late_format
        })
        
        worksheet.conditional_format(1, short_col_idx, max_row, short_col_idx, {
            'type': 'cell',
            'criteria': '>',
            'value': 0,
            'format': short_format
        })
        
        worksheet.set_column('A:A', 20)
        worksheet.set_column('B:G', 18)

    output.seek(0)
    return output.getvalue()

def generate_detailed_report_excel(json_data, holiday_data, selected_month, selected_year, selected_employee):
    df = pd.read_json(io.StringIO(json_data), orient='split')
    df['date'] = pd.to_datetime(df['date'])
    
    holidays_list = holiday_data.get('date_list', [])
    holidays_set = set(holidays_list)

    date_filtered_df = df[
        (df['date'].dt.month == selected_month) &
        (df['date'].dt.year == selected_year)
    ].copy()

    if selected_employee and selected_employee != 'all':
        all_employees = [selected_employee]
        date_filtered_df = date_filtered_df[date_filtered_df['person_name'] == selected_employee]
    else:
        all_employees = sorted(df['person_name'].unique())

    if not all_employees:
        return io.BytesIO().getvalue() 

    date_filtered_df['Notes'] = ''
    date_filtered_df.loc[date_filtered_df['work_duration_hours'] < HOURS_THRESHOLD, 'Notes'] += 'Short Hours '
    date_filtered_df.loc[date_filtered_df['first_in'] > LATE_THRESHOLD_STR, 'Notes'] += 'Late '
    date_filtered_df['Notes'] = date_filtered_df['Notes'].str.strip()
    date_filtered_df['Hours_Worked_Str'] = date_filtered_df['work_duration_hours'].apply(format_hours)

    start_date = date(selected_year, selected_month, 1)
    end_day = calendar.monthrange(selected_year, selected_month)[1]
    end_date = date(selected_year, selected_month, end_day)
    all_days_in_month = pd.date_range(start=start_date, end=end_date)
    
    full_calendar_df = pd.DataFrame(
        [(day, emp) for day in all_days_in_month for emp in all_employees],
        columns=['date', 'person_name']
    )
    
    report_df = pd.merge(full_calendar_df, date_filtered_df, on=['date', 'person_name'], how='left')

    report_df['day_name'] = report_df['date'].dt.day_name()
    report_df['date_str'] = report_df['date'].dt.strftime('%Y-%m-%d')
    report_df['day_of_month'] = report_df['date'].dt.day
    
    report_df['Attendance_Status'] = 'Absent'
    report_df.loc[~report_df['first_in'].isna(), 'Attendance_Status'] = 'Present'
    report_df.loc[report_df['day_name'] == 'Sunday', 'Attendance_Status'] = 'Sunday'
    report_df.loc[report_df['date_str'].isin(holidays_set), 'Attendance_Status'] = 'Holiday'
    
    report_df.loc[(report_df['Attendance_Status'] == 'Present') & 
                   ((report_df['day_name'] == 'Sunday') | (report_df['date_str'].isin(holidays_set))), 
                   'Attendance_Status'] = 'Present (on Holiday/Sunday)'
    
    report_df.loc[(report_df['Attendance_Status'] == 'Absent') & 
                   ((report_df['day_name'] == 'Sunday') | (report_df['date_str'].isin(holidays_set))), 
                   'Attendance_Status'] = report_df['day_name'].apply(lambda x: 'Sunday' if x == 'Sunday' else 'Holiday')

    pivot_in = report_df.pivot(index='person_name', columns='day_of_month', values='first_in').fillna('-')
    pivot_out = report_df.pivot(index='person_name', columns='day_of_month', values='last_out').fillna('-')
    pivot_hours = report_df.pivot(index='person_name', columns='day_of_month', values='Hours_Worked_Str').fillna('-')
    pivot_notes = report_df.pivot(index='person_name', columns='day_of_month', values='Notes').fillna('')
    pivot_status = report_df.pivot(index='person_name', columns='day_of_month', values='Attendance_Status').fillna('Absent')

    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='xlsxwriter') as writer:
        workbook = writer.book
        worksheet = writer.sheets.get('Sheet1')
        if not worksheet:
            worksheet = workbook.add_worksheet('Detailed Report')
        
        header_format = workbook.add_format({'bold': True, 'align': 'center', 'valign': 'vcenter', 'border': 1, 'bg_color': '#D9D9D9'})
        emp_format = workbook.add_format({'bold': True, 'valign': 'vcenter', 'border': 1})
        type_format = workbook.add_format({'bold': True, 'align': 'right', 'border': 1, 'bg_color': '#F2F2F2'})
        center_format = workbook.add_format({'align': 'center', 'border': 1})
        late_format = workbook.add_format({'bg_color': '#FFC7CE', 'font_color': '#9C0006', 'align': 'center', 'border': 1})
        short_format = workbook.add_format({'bg_color': '#FFEB9C', 'font_color': '#9C6500', 'align': 'center', 'border': 1})
        sunday_format = workbook.add_format({'bold': True, 'align': 'center', 'valign': 'vcenter', 'bg_color': '#C9DAF8', 'border': 1})
        holiday_format = workbook.add_format({'bold': True, 'align': 'center', 'valign': 'vcenter', 'bg_color': '#D9EAD3', 'border': 1})
        absent_format = workbook.add_format({'bold': True, 'align': 'center', 'valign': 'vcenter', 'bg_color': '#F3F3F3', 'font_color': '#A6A6A6', 'border': 1})
        
        worksheet.write('A1', 'Employee', header_format)
        worksheet.write('B1', 'Type', header_format)
        
        days_in_month = list(pivot_in.columns)
        for day in days_in_month:
            excel_col_idx = day + 1
            worksheet.write(0, excel_col_idx, day, header_format)
            worksheet.set_column(excel_col_idx, excel_col_idx, 10)

        worksheet.set_column('A:A', 25)
        worksheet.set_column('B:B', 12)

        excel_row = 1
        for emp in all_employees:
            worksheet.merge_range(excel_row, 0, excel_row + 2, 0, emp, emp_format)
            
            worksheet.write(excel_row, 1, "First In", type_format)
            worksheet.write(excel_row + 1, 1, "Last Out", type_format)
            worksheet.write(excel_row + 2, 1, "Hours Worked", type_format)
            
            for day in days_in_month:
                excel_col = day + 1
                status = pivot_status.loc[emp, day]
                
                if status == 'Sunday':
                    worksheet.merge_range(excel_row, excel_col, excel_row + 2, excel_col, 'Sunday', sunday_format)
                elif status == 'Holiday':
                    worksheet.merge_range(excel_row, excel_col, excel_row + 2, excel_col, 'Holiday', holiday_format)
                elif status == 'Absent':
                    worksheet.merge_range(excel_row, excel_col, excel_row + 2, excel_col, 'Absent', absent_format)
                else:
                    in_time = pivot_in.loc[emp, day]
                    out_time = pivot_out.loc[emp, day]
                    hours_str = pivot_hours.loc[emp, day]
                    notes = pivot_notes.loc[emp, day]
                    in_format = center_format
                    hours_format = center_format
                    
                    if 'Late' in notes:
                        in_format = late_format
                    if 'Short Hours' in notes:
                        hours_format = short_format
                        
                    worksheet.write(excel_row, excel_col, in_time, in_format)
                    worksheet.write(excel_row + 1, excel_col, out_time, center_format)
                    worksheet.write(excel_row + 2, excel_col, hours_str, hours_format)
            
            excel_row += 3
            
    output.seek(0)
    return output.getvalue()


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
    Output('sync-odoo-status', 'children', allow_duplicate=True),
    Input('data-store', 'data'),
    prevent_initial_call='initial_duplicate'
)
def auto_sync_today(json_data):
    print("callback function called")
    if not json_data:
        return dash.no_update
    
    df = pd.read_json(io.StringIO(json_data), orient='split')
    df['date'] = pd.to_datetime(df['date'])
    today_date = date.today()
    todays_records = df[df['date'].dt.date == today_date].copy()

    if todays_records.empty:
        return "Auto-Sync: No data for today yet."

    complete_records = todays_records.dropna(subset=['first_in', 'last_out'])

    if complete_records.empty:
        return "Auto-Sync: No completed entries yet."

    success_count = 0
    for index, row in complete_records.iterrows():
        success, msg = push_to_odoo(row)
        if success:
            success_count += 1
            
    print(f"Sync Processed {len(complete_records)} records. Success: {success_count}")
    return f"Last Auto-Sync: {datetime.datetime.now().strftime('%H:%M')} ({success_count} records)"
       
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

def start_watcher_thread():
    watcher_thread = threading.Thread(target=watcher.run_watcher, daemon=False)
    watcher_thread.start()

if __name__ == '__main__':
    # start_watcher_thread()
    # print("Watcher and Dashboard started")
    sync_thread = threading.Thread(target=auto_sync, daemon=True)
    sync_thread.start()
    print("Thread Started")
    app.run(host='0.0.0.0', debug=False)
    
