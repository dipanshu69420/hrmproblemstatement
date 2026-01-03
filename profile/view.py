from dash import html

def profile_card(title, data_dict):
    return html.Div(
        style={
            "border": "1px solid #ddd",
            "padding": "10px",
            "borderRadius": "6px",
            "marginBottom": "10px",
        },
        children=[
            html.H4(title),
            html.Ul([
                html.Li(f"{k}: {v}") for k, v in data_dict.items()
            ])
        ]
    )


from dash import html

def employee_profile_layout(profile):
    if not profile:
        return html.Div("No profile data found")

    return html.Div(
        style={
            "padding": "20px",
            "maxWidth": "600px",
            "border": "1px solid #ddd",
            "borderRadius": "8px",
            "boxShadow": "0 2px 6px rgba(0,0,0,0.1)"
        },
        children=[
            html.H3(profile["person_name"]),

            html.P(f"Username: {profile['username']}"),
            html.P(f"Role: {profile['role']}"),
            html.P(f"Mobile: {profile.get('mobile_no', '-') }"),
            html.P(f"Email: {profile.get('email', '-') }"),
            html.P(f"Monthly Salary: ₹{profile.get('monthly_salary', '-')}")
        ]
    )
