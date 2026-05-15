"""Email service for sending alerts and notifications."""

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from typing import List, Optional
import logging

logger = logging.getLogger(__name__)


class EmailService:
    """Handles email sending via SMTP."""
    
    def __init__(
        self,
        smtp_server: str,
        smtp_port: int,
        sender_email: str,
        sender_password: str,
        use_tls: bool = True,
    ):
        """
        Initialize email service.
        
        Args:
            smtp_server: SMTP server hostname (e.g., 'smtp.gmail.com')
            smtp_port: SMTP port (e.g., 587 for TLS, 465 for SSL)
            sender_email: Sender email address
            sender_password: Sender password or app-specific password
            use_tls: Whether to use TLS (True for 587, False for 465)
        """
        self.smtp_server = smtp_server
        self.smtp_port = smtp_port
        self.sender_email = sender_email
        self.sender_password = sender_password
        self.use_tls = use_tls

    def send_email(
        self,
        to_emails: List[str],
        subject: str,
        body: str,
        html_body: Optional[str] = None,
    ) -> bool:
        """
        Send email to recipients.
        
        Args:
            to_emails: List of recipient email addresses
            subject: Email subject
            body: Plain text email body
            html_body: Optional HTML email body
            
        Returns:
            True if email sent successfully, False otherwise
        """
        try:
            # Create message
            message = MIMEMultipart("alternative")
            message["Subject"] = subject
            message["From"] = self.sender_email
            message["To"] = ", ".join(to_emails)

            # Attach plain text body
            part1 = MIMEText(body, "plain")
            message.attach(part1)

            # Attach HTML body if provided
            if html_body:
                part2 = MIMEText(html_body, "html")
                message.attach(part2)

            # Send email
            with smtplib.SMTP(self.smtp_server, self.smtp_port, timeout=10) as server:
                if self.use_tls:
                    server.starttls()
                server.login(self.sender_email, self.sender_password)
                server.sendmail(self.sender_email, to_emails, message.as_string())

            logger.info(f"Email sent successfully to {to_emails}")
            return True

        except smtplib.SMTPAuthenticationError:
            logger.error("SMTP authentication failed. Check email credentials.")
            return False
        except smtplib.SMTPException as e:
            logger.error(f"SMTP error: {e}")
            return False
        except Exception as e:
            logger.error(f"Failed to send email: {e}")
            return False

    def send_threat_alert(
        self,
        to_emails: List[str],
        threat_type: str,
        threat_severity: str,
        threat_description: str,
        threat_source: str,
    ) -> bool:
        """
        Send formatted threat alert email.
        
        Args:
            to_emails: List of recipient email addresses
            threat_type: Type of threat (e.g., 'Brute Force', 'SQL Injection')
            threat_severity: Severity level (e.g., 'HIGH', 'MEDIUM', 'LOW')
            threat_description: Description of the threat
            threat_source: Source of the threat (e.g., IP address)
            
        Returns:
            True if email sent successfully, False otherwise
        """
        subject = f"🚨 CyberSentinel Alert: {threat_type} ({threat_severity})"
        
        body = f"""
CyberSentinel Threat Alert

Threat Type: {threat_type}
Severity: {threat_severity}
Source: {threat_source}
Description: {threat_description}

Please check the CyberSentinel dashboard for more details.
        """.strip()
        
        html_body = f"""
        <html>
            <body style="font-family: Arial, sans-serif;">
                <h2 style="color: #d32f2f;">🚨 CyberSentinel Threat Alert</h2>
                <table style="width: 100%; border-collapse: collapse;">
                    <tr style="background-color: #f5f5f5;">
                        <td style="padding: 10px; border: 1px solid #ddd;"><strong>Threat Type</strong></td>
                        <td style="padding: 10px; border: 1px solid #ddd;">{threat_type}</td>
                    </tr>
                    <tr>
                        <td style="padding: 10px; border: 1px solid #ddd;"><strong>Severity</strong></td>
                        <td style="padding: 10px; border: 1px solid #ddd; color: #d32f2f;"><strong>{threat_severity}</strong></td>
                    </tr>
                    <tr style="background-color: #f5f5f5;">
                        <td style="padding: 10px; border: 1px solid #ddd;"><strong>Source</strong></td>
                        <td style="padding: 10px; border: 1px solid #ddd;">{threat_source}</td>
                    </tr>
                    <tr>
                        <td style="padding: 10px; border: 1px solid #ddd;"><strong>Description</strong></td>
                        <td style="padding: 10px; border: 1px solid #ddd;">{threat_description}</td>
                    </tr>
                </table>
                <p style="margin-top: 20px; color: #666;">Please check the CyberSentinel dashboard for more details.</p>
            </body>
        </html>
        """.strip()
        
        return self.send_email(to_emails, subject, body, html_body)
