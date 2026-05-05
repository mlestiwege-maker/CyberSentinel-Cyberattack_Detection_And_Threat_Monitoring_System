import os
import numpy as np
import joblib
from pathlib import Path
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
from app.core.config import settings
from app.models.threat import ThreatSeverity, ThreatType

FEATURE_COLUMNS = [
    "duration", "src_bytes", "dst_bytes",
    "land", "wrong_fragment", "urgent",
    "count", "srv_count",
]


def _severity_from_confidence(confidence: float) -> ThreatSeverity:
    if confidence >= 0.90:
        return ThreatSeverity.CRITICAL
    elif confidence >= 0.75:
        return ThreatSeverity.HIGH
    elif confidence >= 0.55:
        return ThreatSeverity.MEDIUM
    return ThreatSeverity.LOW


def _train_demo_model():
    rng = np.random.default_rng(42)
    normal  = rng.normal(loc=[0.5, 500, 300, 0, 0, 0, 10, 8],   scale=0.2, size=(800, 8))
    attacks = rng.normal(loc=[5.0, 50000, 0, 1, 3, 2, 500, 400], scale=1.0, size=(200, 8))
    X = np.vstack([normal, attacks])
    y = np.array([0] * 800 + [1] * 200)

    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    clf = RandomForestClassifier(n_estimators=50, random_state=42)
    clf.fit(X_scaled, y)

    Path(settings.MODEL_PATH).parent.mkdir(parents=True, exist_ok=True)
    scaler_path = settings.MODEL_PATH.replace("threat_model", "scaler")
    joblib.dump(clf, settings.MODEL_PATH)
    joblib.dump(scaler, scaler_path)
    return clf, scaler


class MLService:
    def __init__(self):
        self.model  = None
        self.scaler = None
        self._load()

    def _load(self):
        scaler_path = settings.MODEL_PATH.replace("threat_model", "scaler")
        if os.path.exists(settings.MODEL_PATH) and os.path.exists(scaler_path):
            self.model  = joblib.load(settings.MODEL_PATH)
            self.scaler = joblib.load(scaler_path)
        else:
            print("⚠️  No model found — training demo model...")
            self.model, self.scaler = _train_demo_model()
            print("✅ Demo model trained and saved.")

    def predict(self, features: dict) -> dict:
        X = np.array([[features.get(col, 0) for col in FEATURE_COLUMNS]])
        X_scaled = self.scaler.transform(X)
        prediction    = self.model.predict(X_scaled)[0]
        probabilities = self.model.predict_proba(X_scaled)[0]
        confidence    = float(probabilities[prediction])
        is_threat     = bool(prediction == 1)

        if not is_threat:
            return {
                "is_threat":   False,
                "confidence":  confidence,
                "threat_type": ThreatType.NORMAL,
                "severity":    None,
            }

        count     = features.get("count", 0)
        src_bytes = features.get("src_bytes", 0)
        if count > 400:
            threat_type = ThreatType.DDOS
        elif src_bytes > 30000:
            threat_type = ThreatType.RANSOMWARE
        elif features.get("wrong_fragment", 0) > 2:
            threat_type = ThreatType.PORT_SCAN
        else:
            threat_type = ThreatType.ANOMALY

        return {
            "is_threat":   True,
            "confidence":  confidence,
            "threat_type": threat_type,
            "severity":    _severity_from_confidence(confidence),
        }


ml_service = MLService()