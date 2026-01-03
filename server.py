# from flask import Flask, session, redirect
# from auth.routes import login_bp

# from dashboard import app as dash_app 

# def create_app():
#     flask_app = Flask(__name__)
#     flask_app.secret_key = "super-secret-key"
#     flask_app.register_blueprint(login_bp)
#     flask_app.register_blueprint(login_bp.register_bp)
#     flask_app.register_blueprint(login_bp.verification_bp)
#     flask_app.register_blueprint(login_bp.approval_bp)
#     dash_app.init_app(flask_app, url_base_pathname="/dashboard/")

#     return flask_app

# app = create_app()

# if __name__ == "__main__":
#     app.run(debug=True)


from flask import Flask
from auth.routes import login_bp
from dashboard import app as dash_app 


def create_app():
    flask_app = Flask(__name__)
    flask_app.secret_key = "super-secret-key"

    flask_app.register_blueprint(login_bp)

    dash_app.init_app(flask_app)


    return flask_app

app = create_app()

if __name__ == "__main__":
    app.run(debug=True)
