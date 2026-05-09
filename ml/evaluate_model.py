import pandas as pd
import joblib

# Load trained model
model = joblib.load("models/isolation_forest_model.pkl")

# NSL-KDD column names
columns = [
    "duration", "protocol_type", "service", "flag",
    "src_bytes", "dst_bytes", "land", "wrong_fragment",
    "urgent", "hot", "num_failed_logins", "logged_in",
    "num_compromised", "root_shell", "su_attempted",
    "num_root", "num_file_creations", "num_shells",
    "num_access_files", "num_outbound_cmds",
    "is_host_login", "is_guest_login", "count",
    "srv_count", "serror_rate", "srv_serror_rate",
    "rerror_rate", "srv_rerror_rate", "same_srv_rate",
    "diff_srv_rate", "srv_diff_host_rate",
    "dst_host_count", "dst_host_srv_count",
    "dst_host_same_srv_rate",
    "dst_host_diff_srv_rate",
    "dst_host_same_src_port_rate",
    "dst_host_srv_diff_host_rate",
    "dst_host_serror_rate",
    "dst_host_srv_serror_rate",
    "dst_host_rerror_rate",
    "dst_host_srv_rerror_rate",
    "label",
    "difficulty"
]

# Load dataset
data = pd.read_csv(
    "data/KDDTrain+.txt",
    names=columns
)

print("Dataset loaded!")

# Encode categorical features
from sklearn.preprocessing import LabelEncoder

encoder = LabelEncoder()

for col in ["protocol_type", "service", "flag", "label"]:
    data[col] = encoder.fit_transform(data[col])

# Prepare features
X = data.drop(["label", "difficulty"], axis=1)

# Run predictions
predictions = model.predict(X)

# Count results
normal = (predictions == 1).sum()
anomalies = (predictions == -1).sum()

total = len(predictions)

# Calculate percentages
normal_percent = (normal / total) * 100
anomaly_percent = (anomalies / total) * 100

print("\n===== MODEL EVALUATION =====")

print(f"Total Records: {total}")
print(f"Normal Traffic: {normal}")
print(f"Detected Anomalies: {anomalies}")

print(f"\nNormal Percentage: {normal_percent:.2f}%")
print(f"Anomaly Percentage: {anomaly_percent:.2f}%")