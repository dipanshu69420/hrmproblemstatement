from flask import Flask, session, redirect
from auth.login import login_bp
from auth.register import register_bp
from auth.verification import verification_bp
from auth.approval import approval_bp

from dashboard import app as dash_app 

def create_app():
    flask_app = Flask(__name__)
    flask_app.secret_key = "super-secret-key"
    flask_app.register_blueprint(login_bp)
    flask_app.register_blueprint(register_bp)
    flask_app.register_blueprint(verification_bp)
    flask_app.register_blueprint(approval_bp)
    dash_app.init_app(flask_app, url_base_pathname="/dashboard/")

    return flask_app

app = create_app()

if __name__ == "__main__":
    app.run(debug=True)
