import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication
import config

def _send(msg, recipients):
    server = smtplib.SMTP("smtp.gmail.com", 587)
    server.starttls()
    server.login(config.EMAIL_SENDER, config.EMAIL_PASSWORD)
    server.sendmail(config.EMAIL_SENDER, recipients, msg.as_string())
    server.quit()

def send_report_email(recipient_list, subject, body, attachments):
    msg = MIMEMultipart()
    msg["From"] = config.EMAIL_SENDER
    msg["To"] = ", ".join(recipient_list)
    msg["Subject"] = subject
    msg.attach(MIMEText(body, "plain"))

    for filename, file_bytes in attachments:
        part = MIMEApplication(file_bytes, Name=filename)
        part["Content-Disposition"] = f'attachment; filename="{filename}"'
        msg.attach(part)

    _send(msg, recipient_list)
    return True

def send_verification_email(email, code, purpose="verify"):
    subject = "Verify Your Employee Account"
    heading = "Email Verification"
    message = "Use the code below to verify your account."

    if purpose == "reset":
        subject = "Reset Your Employee Account Password"
        heading = "Password Reset"
        message = "Use the code below to reset your password."

    html = f"""
    <h3>{heading}</h3>
    <p>{message}</p>
    <h1>{code}</h1>
    <p>Valid for 10 minutes.</p>
    """

    msg = MIMEMultipart()
    msg["From"] = config.EMAIL_SENDER
    msg["To"] = email
    msg["Subject"] = subject
    msg.attach(MIMEText(html, "html"))

    _send(msg, [email])
    return True

def notify_hr(employee_name, employee_email):
    html = f"""
    <h3>New Registration Approval</h3>
    <p><b>{employee_name}</b> ({employee_email})</p>
    <p>Please login to approve.</p>
    """
    msg = MIMEMultipart()
    msg["From"] = config.EMAIL_SENDER
    msg["To"] = config.EMAIL_SENDER
    msg["Subject"] = "HR Approval Required"
    msg.attach(MIMEText(html, "html"))
    _send(msg, [config.EMAIL_SENDER])
