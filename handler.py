import requests
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
import config

def send_sms(phone_number, template_id, **kwargs):
    if not phone_number or not template_id:
        print("Missing phone number or template ID.")
        return False

    url = "http://api.msg91.com/api/v5/flow/"

    payload = {
        "flow_id": template_id,
        "sender": config.MSG91_SENDER_ID,
        "mobiles": f"91{phone_number}",
        **kwargs 
    }
    
    headers = {
        'authkey': config.MSG91_AUTH_KEY,
        'content-type': "application/JSON"
    }

    try:
        response = requests.post(url, json=payload, headers=headers)
        response.raise_for_status() 
        
        result = response.json()
        if result.get("type") == "success":
            print(f"Successfully sent SMS to {phone_number}")
            return True
        else:
            print(f"Error sending SMS: {result.get('message', 'Unknown error')}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"SMS HTTP Request failed: {e}")
        return False

def send_report_email(recipient_list, subject, body, attachments):
    if not recipient_list:
        print("No recipients provided for email.")
        return False

    try:
        msg = MIMEMultipart()
        msg['From'] = config.EMAIL_SENDER
        msg['To'] = ", ".join(recipient_list)
        msg['Subject'] = subject

        msg.attach(MIMEText(body, 'plain'))

        for filename, file_bytes in attachments:
            if file_bytes:
                part = MIMEApplication(
                    file_bytes,
                    Name=filename
                )
                part['Content-Disposition'] = f'attachment; filename="{filename}"'
                msg.attach(part)

        print(f"Connecting to Gmail SMTP to send email to: {', '.join(recipient_list)}...")
        
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(config.EMAIL_SENDER, config.EMAIL_PASSWORD)
        text = msg.as_string()
        server.sendmail(config.EMAIL_SENDER, recipient_list, text)
        server.quit()
        
        print("Email sent successfully.")
        return True

    except smtplib.SMTPAuthenticationError:
        print("SMTP Authentication Error: Check your Email and App Password in config.py.")
        return False
    except Exception as e:
        print(f"Failed to send email: {e}")
        return False