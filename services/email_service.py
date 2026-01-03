import smtplib
import random
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import config

def send_otp_email(to_email, otp):
    try:
        msg = MIMEMultipart()
        msg["From"] = config.EMAIL_SENDER
        msg["To"] = to_email
        msg["Subject"] = "Email Verification OTP"

        body = f"""
Hello,

Your OTP for email verification is:

{otp}

This OTP is valid for 5 minutes.
Do not share it with anyone.

Regards,
HRMS Team
"""
        msg.attach(MIMEText(body, "plain"))

        server = smtplib.SMTP(config.SMTP_SERVER, config.SMTP_PORT)
        server.starttls()
        server.login(config.EMAIL_SENDER, config.EMAIL_PASSWORD)
        server.sendmail(config.EMAIL_SENDER, to_email, msg.as_string())
        server.quit()

        print("✅ OTP email sent successfully")
        return True

    except Exception as e:
        print("❌ OTP Email Error:", e)
        return False
    
def send_password_reset_email(email, otp):
    subject = "Password Reset OTP"
    body = f"""
Your password reset OTP is: {otp}

This OTP is valid for 10 minutes.
If you did not request this, ignore this email.
"""
    return send_report_email(
        recipient_list=[email],
        subject=subject,
        body=body,
        attachments=[]
    )

