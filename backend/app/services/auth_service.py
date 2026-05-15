from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.user import User, UserRole
from app.schemas.user import UserCreate
from app.core.security import hash_password, verify_password, create_access_token


def register_user(db: Session, payload: UserCreate) -> User:
    normalized_email = payload.email.strip().lower()
    if db.query(User).filter(User.email == normalized_email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    user = User(
        full_name=payload.full_name,
        email=normalized_email,
        password=hash_password(payload.password),
        role=payload.role,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def login_user(db: Session, email: str, password: str) -> dict:
    normalized_email = email.strip().lower()
    user = db.query(User).filter(User.email == normalized_email).first()
    if not user or not verify_password(password, user.password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if not user.is_active:
        raise HTTPException(status_code=403, detail="Account is disabled")
    token = create_access_token({"sub": str(user.id), "role": user.role.value})
    return {
        "access_token": token,
        "token_type": "bearer",
        "full_name": user.full_name,
        "email": user.email,
        "role": user.role,
    }


def ensure_default_admin(db: Session, *, full_name: str, email: str, password: str) -> None:
    normalized_email = email.strip().lower()
    if not normalized_email or not password.strip():
        return
    if db.query(User).filter(User.email == normalized_email).first():
        return

    user = User(
        full_name=full_name.strip() or "CyberSentinel Admin",
        email=normalized_email,
        password=hash_password(password),
        role=UserRole.ADMIN,
    )
    db.add(user)
    db.commit()