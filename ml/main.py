from fastapi import FastAPI
from detect import predict_threat

app = FastAPI()

@app.get("/")
def home():
    return {
        "message": "CyberSentinel ML API Running"
    }

@app.post("/predict")
def predict(data: dict):

    result = predict_threat(data)

    return result