import joblib
import pandas as pd

# Load trained model
model = joblib.load("models/isolation_forest_model.pkl")


def calculate_severity(score):
    """
    Convert threat score into severity level
    """

    if score < -0.15:
        return "HIGH"

    elif score < -0.05:
        return "MEDIUM"

    else:
        return "LOW"


def predict_threat(data):

    # Convert incoming data into DataFrame
    features = pd.DataFrame([data])

    # Prediction
    prediction = model.predict(features)[0]

    # Threat score
    score = float(model.decision_function(features)[0])

    # Human-readable result
    result = {
        "status": "THREAT DETECTED" if prediction == -1 else "NORMAL TRAFFIC",
        "severity": calculate_severity(score),
        "threat_score": score
    }

    return result


# Test sample
if __name__ == "__main__":

    sample_data = {
        "duration": 0,
        "protocol_type": 1,
        "service": 20,
        "flag": 9,
        "src_bytes": 491,
        "dst_bytes": 0,
        "land": 0,
        "wrong_fragment": 0,
        "urgent": 0,
        "hot": 0,
        "num_failed_logins": 0,
        "logged_in": 0,
        "num_compromised": 0,
        "root_shell": 0,
        "su_attempted": 0,
        "num_root": 0,
        "num_file_creations": 0,
        "num_shells": 0,
        "num_access_files": 0,
        "num_outbound_cmds": 0,
        "is_host_login": 0,
        "is_guest_login": 0,
        "count": 2,
        "srv_count": 2,
        "serror_rate": 0.0,
        "srv_serror_rate": 0.0,
        "rerror_rate": 0.0,
        "srv_rerror_rate": 0.0,
        "same_srv_rate": 1.0,
        "diff_srv_rate": 0.0,
        "srv_diff_host_rate": 0.0,
        "dst_host_count": 150,
        "dst_host_srv_count": 25,
        "dst_host_same_srv_rate": 0.17,
        "dst_host_diff_srv_rate": 0.03,
        "dst_host_same_src_port_rate": 0.17,
        "dst_host_srv_diff_host_rate": 0.0,
        "dst_host_serror_rate": 0.0,
        "dst_host_srv_serror_rate": 0.0,
        "dst_host_rerror_rate": 0.05,
        "dst_host_srv_rerror_rate": 0.0
    }

    result = predict_threat(sample_data)

    print(result)
   