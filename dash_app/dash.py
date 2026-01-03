import dash_app.dash as dash
from flask import session
from dash_app.dash import html

def init_dash(flask_app):
    dash_app = dash.Dash(
        __name__,
        server=flask_app,
        url_base_pathname="/dash/",
        suppress_callback_exceptions=True
    )

    @dash_app.server.before_request
    def protect_dash():
        if not session.get("user"):
            return redirect("/login")

    user = session.get("user", {})
    role = user.get("role", "employee")
    name = user.get("name", "User")

    dash_app.layout = get_dashboard_layout(role=role, username=name)
