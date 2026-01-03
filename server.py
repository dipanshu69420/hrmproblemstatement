# # from flask import Flask, session, redirect
# # from auth.routes import login_bp

# # from dashboard import app as dash_app 

# # def create_app():
# #     flask_app = Flask(__name__)
# #     flask_app.secret_key = "super-secret-key"
# #     flask_app.register_blueprint(login_bp)
# #     flask_app.register_blueprint(login_bp.register_bp)
# #     flask_app.register_blueprint(login_bp.verification_bp)
# #     flask_app.register_blueprint(login_bp.approval_bp)
# #     dash_app.init_app(flask_app, url_base_pathname="/dashboard/")

# #     return flask_app

# # app = create_app()

# # if __name__ == "__main__":
# #     app.run(debug=True)


# from flask import Flask
# from auth.routes import login_bp
# from dashboard import app as dash_app 


# def create_app():
#     flask_app = Flask(__name__)
#     flask_app.secret_key = "super-secret-key"

#     flask_app.register_blueprint(login_bp)

#     dash_app.init_app(flask_app)


# @server.route("/", methods=["GET", "POST"])
# @server.route("/login", methods=["GET", "POST"])
# def login():
#     if request.method == "POST":
#         email = request.form.get("email")
#         password = request.form.get("password")

#         result = authenticate_user(email, password)

#         if isinstance(result, str):
#             return render_template("login.html", error=result)

#         session["user"] = {
#             "name": result["person_name"],
#             "role": result["role"],
#             "is_hr_approved": result["is_hr_approved"]
#         }

#         return redirect("/dashboard")


#     return render_template("login.html")



# @server.route("/register", methods=["GET", "POST"])
# def register():
#     if request.method == "POST":
#         success, message = register_candidate(
#             request.form.get("name"),
#             request.form.get("email"),
#             request.form.get("password")
#         )

#         if not success:
#             return render_template("register.html", error=message)

#         return redirect(f"/verify?email={request.form.get('email')}")

#     return render_template("register.html")



# @server.route("/verify", methods=["GET", "POST"])
# def verify():
#     email = request.args.get("email")

#     if request.method == "POST":
#         email = request.form["email"]
#         otp = request.form["otp"]

#         success = verify_email_otp(email, otp)

#         if success:
#             return redirect("/login")

#         return render_template(
#             "verify.html",
#             email=email,
#             error="Invalid or expired OTP"
#         )

#     return render_template("verify.html", email=email)



# @server.route("/logout")
# def logout():
#     session.clear()
#     return redirect("/login")



# @server.before_request
# def protect_dashboard():
#     if request.path.startswith("/dashboard") or request.path.startswith("/dash"):
#         if "user" not in session:
#             return redirect("/login")


# @server.route("/dashboard")
# def dashboard():
#     if "user" not in session:
#         return redirect("/login")

#     if not session["user"]["is_hr_approved"]:
#         return render_template("pending_approval.html")

#     return redirect("/dashboard/")

# @server.before_request
# def protect_dashboard():
#     if request.path.startswith("/dash"):
#         if "user" not in session:
#             return redirect("/login")

#         if not session["user"].get("is_hr_approved"):
#             return redirect("/dashboard")
        
# @server.route("/forgot-password", methods=["GET", "POST"])
# def forgot_password():
#     if request.method == "POST":
#         success, msg = send_reset_otp(request.form["email"])
#         if success:
#             return redirect(f"/reset-password?email={request.form['email']}")
#         return render_template("forget_password.html", error=msg)

#     return render_template("forget_password.html")

# @server.route("/reset-password", methods=["GET", "POST"])
# def reset_password_page():
#     email = request.args.get("email")

#     if request.method == "POST":
#         email = request.form["email"]
#         otp = request.form["otp"]
#         password = request.form["password"]

#         success, msg = reset_password(email, otp, password)
#         if success:
#             return redirect("/login")

#         return render_template("reset_password.html", email=email, error=msg)

#     return render_template("reset_password.html", email=email)



# if __name__ == "__main__":
#     server.run(debug=True)

from flask import Flask, request, session, redirect, render_template
from auth.login import authenticate_user
from auth.register import register_candidate
from auth.otp import verify_email_otp
from dashboard import app as dash_app
from auth.reset_password import send_reset_otp, reset_password

server = Flask(__name__)
server.secret_key = "super-secret-key"

# Attach Dash safely
dash_app.init_app(server)


# ---------------- LOGIN ----------------
@server.route("/", methods=["GET", "POST"])
@server.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        email = request.form.get("email")
        password = request.form.get("password")

        result = authenticate_user(email, password)

        # ❌ LOGIN FAILED
        if isinstance(result, str):
            return render_template("login.html", error=result)

        # ✅ LOGIN SUCCESS
        session["user"] = {
            "name": result["person_name"],
            "role": result["role"],
            "is_hr_approved": result["is_hr_approved"]
        }

        return redirect("/dashboard")

    # GET REQUEST
    return render_template("login.html")


# ---------------- REGISTER ----------------
@server.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        success, message = register_candidate(
            request.form.get("name"),
            request.form.get("email"),
            request.form.get("password")
        )

        if not success:
            return render_template("register.html", error=message)

        return redirect(f"/verify?email={request.form.get('email')}")

    return render_template("register.html")


# ---------------- OTP VERIFY ----------------
@server.route("/verify", methods=["GET", "POST"])
def verify():
    email = request.args.get("email")

    if request.method == "POST":
        email = request.form["email"]
        otp = request.form["otp"]

        success = verify_email_otp(email, otp)

        if success:
            return redirect("/login")

        return render_template(
            "verify.html",
            email=email,
            error="Invalid or expired OTP"
        )

    return render_template("verify.html", email=email)


# ---------------- LOGOUT ----------------
@server.route("/logout")
def logout():
    session.clear()
    return redirect("/login")


# ---------------- DASHBOARD PROTECTION ----------------
@server.before_request
def protect_dashboard():
    if request.path.startswith("/dashboard") or request.path.startswith("/dash"):
        if "user" not in session:
            return redirect("/login")


@server.route("/dashboard")
def dashboard():
    if "user" not in session:
        return redirect("/login")

    if not session["user"]["is_hr_approved"]:
        return render_template("pending_approval.html")

    return redirect("/dashboard/")

@server.before_request
def protect_dashboard():
    if request.path.startswith("/dash"):
        if "user" not in session:
            return redirect("/login")

        if not session["user"].get("is_hr_approved"):
            return redirect("/dashboard")
        
@server.route("/forgot-password", methods=["GET", "POST"])
def forgot_password():
    if request.method == "POST":
        success, msg = send_reset_otp(request.form["email"])
        if success:
            return redirect(f"/reset-password?email={request.form['email']}")
        return render_template("forget_password.html", error=msg)

    return render_template("forget_password.html")

@server.route("/reset-password", methods=["GET", "POST"])
def reset_password_page():
    email = request.args.get("email")

    if request.method == "POST":
        email = request.form["email"]
        otp = request.form["otp"]
        password = request.form["password"]

        success, msg = reset_password(email, otp, password)
        if success:
            return redirect("/login")

        return render_template("reset_password.html", email=email, error=msg)

    return render_template("reset_password.html", email=email)



# ---------------- START SERVER ----------------
if __name__ == "__main__":
    server.run(debug=True)