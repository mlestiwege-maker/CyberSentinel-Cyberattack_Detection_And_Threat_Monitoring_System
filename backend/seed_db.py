"""
Seed script for CyberSentinel database.
Creates the default admin user if it doesn't exist.
"""
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.chdir(os.path.dirname(os.path.abspath(__file__)))

from app.db.database import SessionLocal, engine
from app.models.user import User, UserRole
from app.core.security import hash_password
from sqlalchemy.orm import Session


def seed_default_user():
    """Create the default admin user if it doesn't exist."""
    db: Session = SessionLocal()
    try:
        existing = db.query(User).filter(User.email == "mlestiwege@gmail.com").first()
        if existing:
            print("✅ Default admin user already exists.")
            return

        admin = User(
            full_name="Moses Lestiwege",
            email="mlestiwege@gmail.com",
            password=hash_password("1011011"),
            role=UserRole.ADMIN,
            is_active=True,
        )
        db.add(admin)
        db.commit()
        db.refresh(admin)
        print(f"✅ Default admin user created successfully (ID: {admin.id})")
        print(f"   Email: mlestiwege@gmail.com | Password: 1011011 | Role: ADMIN")
    except Exception as e:
        print(f"❌ Error seeding database: {e}")
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    from app.models import user, threat, alert  # noqa
    from app.db.database import Base
    Base.metadata.create_all(bind=engine)
    print("📦 Database tables ensured.")
    seed_default_user()