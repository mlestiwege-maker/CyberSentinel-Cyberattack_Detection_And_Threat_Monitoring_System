import importlib
import os
from pathlib import Path

from app.core.config import settings
from app.models.threat import ThreatSeverity, ThreatType

# Optional ML dependencies. In constrained deploy targets (e.g., Python 3.14 wheels-only),
# these packages may be unavailable. We gracefully degrade to rule-based detection.
try:
    np = importlib.import_module("numpy")
    joblib = importlib.import_module("joblib")
    sklearn_ensemble = importlib.import_module("sklearn.ensemble")
    sklearn_preprocessing = importlib.import_module("sklearn.preprocessing")

    RandomForestClassifier = sklearn_ensemble.RandomForestClassifier
    StandardScaler = sklearn_preprocessing.StandardScaler
    _ML_LIBS_AVAILABLE = True
except Exception:
    np = None
    joblib = None
    RandomForestClassifier = None
    StandardScaler = None
    _ML_LIBS_AVAILABLE = False


FEATURE_COLUMNS = [
    "duration",
    "src_bytes",
    "dst_bytes",
    "land",
    "wrong_fragment",
    "urgent",
    "count",
    "srv_count",
]


def _severity_from_confidence(confidence: float) -> ThreatSeverity:
    if confidence >= 0.90:
        return ThreatSeverity.CRITICAL
    elif confidence >= 0.75:
        return ThreatSeverity.HIGH
    elif confidence >= 0.55:
        return ThreatSeverity.MEDIUM
    return ThreatSeverity.LOW


def _infer_threat_type(features: dict) -> ThreatType:
    count = features.get("count", 0)
    src_bytes = features.get("src_bytes", 0)
    wrong_fragment = features.get("wrong_fragment", 0)

    if count > 400:
        return ThreatType.DDOS
    if src_bytes > 30000:
        return ThreatType.RANSOMWARE
    if wrong_fragment > 2:
        return ThreatType.PORT_SCAN
    return ThreatType.ANOMALY


def _heuristic_predict(features: dict) -> dict:
    # Rule-based fallback when ML stack is unavailable.
    count = float(features.get("count", 0) or 0)
    src_bytes = float(features.get("src_bytes", 0) or 0)
    wrong_fragment = float(features.get("wrong_fragment", 0) or 0)
    urgent = float(features.get("urgent", 0) or 0)

    score = 0.0
    score += min(count / 600.0, 1.0) * 0.45
    score += min(src_bytes / 50000.0, 1.0) * 0.30
    score += min(wrong_fragment / 5.0, 1.0) * 0.15
    score += min(urgent / 5.0, 1.0) * 0.10

    is_threat = score >= 0.35
    confidence = 0.55 + min(score, 0.45) if is_threat else max(0.50, 0.70 - score)

    if not is_threat:
        return {
            "is_threat": False,
            "confidence": float(confidence),
            "threat_type": ThreatType.NORMAL,
            "severity": None,
        }

    return {
        "is_threat": True,
        "confidence": float(confidence),
        "threat_type": _infer_threat_type(features),
        "severity": _severity_from_confidence(float(confidence)),
    }


def _train_demo_model():
    if not _ML_LIBS_AVAILABLE:
        return None, None

    rng = np.random.default_rng(42)
    normal = rng.normal(loc=[0.5, 500, 300, 0, 0, 0, 10, 8], scale=0.2, size=(800, 8))
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
        self.model = None
        self.scaler = None
        self.ml_enabled = _ML_LIBS_AVAILABLE
        self._load()

    def _load(self):
        if not self.ml_enabled:
            print("⚠️  Optional ML libs not installed; using heuristic threat detection.")
            return

        scaler_path = settings.MODEL_PATH.replace("threat_model", "scaler")
        if os.path.exists(settings.MODEL_PATH) and os.path.exists(scaler_path):
            self.model = joblib.load(settings.MODEL_PATH)
            self.scaler = joblib.load(scaler_path)
        else:
            print("⚠️  No model found — training demo model...")
            self.model, self.scaler = _train_demo_model()
            print("✅ Demo model trained and saved.")

    def predict(self, features: dict) -> dict:
        if not self.ml_enabled or self.model is None or self.scaler is None:
            return _heuristic_predict(features)

        X = np.array([[features.get(col, 0) for col in FEATURE_COLUMNS]])
        X_scaled = self.scaler.transform(X)
        prediction = self.model.predict(X_scaled)[0]
        probabilities = self.model.predict_proba(X_scaled)[0]
        confidence = float(probabilities[prediction])
        is_threat = bool(prediction == 1)

        if not is_threat:
            return {
                "is_threat": False,
                "confidence": confidence,
                "threat_type": ThreatType.NORMAL,
                "severity": None,
            }

        return {
            "is_threat": True,
            "confidence": confidence,
            "threat_type": _infer_threat_type(features),
            "severity": _severity_from_confidence(confidence),
        }


ml_service = MLService()