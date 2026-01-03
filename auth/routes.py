from flask import Blueprint, request, session, redirect, jsonify
from auth.login import authenticate_user
from auth.register import register_candidate
from auth.verification import verify_email_otp
from auth.approval import approve_employee
from dash import html


login_bp = Blueprint("login", __name__)

@login_bp.route("/login", methods=["POST"])
def login():
    data = request.json
    email = data.get("email")
    password = data.get("password")

    result = authenticate_user(email, password)

    if isinstance(result, str):
        return jsonify({"error": result}), 401

    session["user"] = result
    return jsonify({"message": "Login successful", "user": result})


@login_bp.route("/register", methods=["POST"])
def register():
    data = request.json

    result = register_candidate(
        data.get("name"),
        data.get("email"),
        data.get("password")
    )

    return jsonify({"message": result})

@login_bp.route("/verify-email", methods=["POST"])
def verify_email():
    data = request.json

    result = verify_email_otp(
        data.get("email"),
        data.get("code")
    )

    if isinstance(result, str):
        return jsonify({"message": result})

    return jsonify({"message": "Email verified"})

@login_bp.route("/hr/approve", methods=["POST"])
def approve():
    data = request.json

    emp_id = data.get("employee_id")
    approve_flag = data.get("approve", True)

    if not emp_id:
        return jsonify({"error": "employee_id is required"}), 400

    approve_employee(emp_id, approve_flag)

    return jsonify({"message": "Employee approval processed"})

