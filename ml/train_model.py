import pandas as pd
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import LabelEncoder
import joblib
import os

# Correct NSL-KDD column names
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

print("Dataset loaded successfully!")

# Encode ALL categorical columns
categorical_columns = [
    "protocol_type",
    "service",
    "flag",
    "label"
]

encoder = LabelEncoder()

for col in categorical_columns:
    data[col] = encoder.fit_transform(data[col])

print("Categorical columns encoded!")

# Remove label and difficulty columns
X = data.drop(["label", "difficulty"], axis=1)

print("Training model...")

# Train Isolation Forest
model = IsolationForest(
    contamination=0.05,
    random_state=42
)

model.fit(X)

print("Model trained successfully!")

# Ensure models folder exists
os.makedirs("models", exist_ok=True)

# Save model
joblib.dump(
    model,
    "models/isolation_forest_model.pkl"
)

print("Model saved successfully!")