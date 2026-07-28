from pathlib import Path

import joblib
import numpy as np

from tensorflow.keras.models import load_model

# =====================================
# Locate ML folder
# =====================================

BASE_DIR = Path(__file__).resolve().parent.parent.parent

ML_DIR = BASE_DIR / "ml"

# =====================================
# Load Models
# =====================================

print("Loading AI models...")

lstm_model = load_model(
    ML_DIR / "LSTM_Lettuce.keras"
)

scaler = joblib.load(
    ML_DIR / "Scaler.pkl"
)

lstm_encoder = joblib.load(
    ML_DIR / "LabelEncoder.pkl"
)

rf_model = joblib.load(
    ML_DIR / "RandomForest_Lettuce.pkl"
)

rf_encoder = joblib.load(
    ML_DIR / "RF_LabelEncoder.pkl"
)

print("AI models loaded successfully.")


def standardize_label(label):
    """Expose only the three classifications used by the application."""
    normalized = str(label).strip().lower()
    if normalized in {"fresh", "safe", "good", "normal", "healthy"}:
        return "Fresh"
    if normalized in {"spoiled", "spoil", "spoiled produce"}:
        return "Spoiled"
    return "At Risk"

# LSTM Prediction Function
# LSTM Prediction Function
def predict_lstm(temperature, humidity, co2):

    sample = np.array([
        [
            temperature,
            humidity,
            co2,
        ]
    ])

    sample = scaler.transform(sample)

    sample = sample.reshape(
        1,
        1,
        sample.shape[1]
    )

    prediction = lstm_model.predict(
        sample,
        verbose=0
    )

    prediction_class = np.argmax(prediction)

    confidence = float(np.max(prediction))

    label = lstm_encoder.inverse_transform(
        [prediction_class]
    )[0]

    return {
        "label": standardize_label(label),
        "confidence": confidence,
    }

# Random Forest Prediction Function
# Random Forest Prediction Function
def predict_random_forest(temperature, humidity, co2):

    sample = np.array([
        [
            temperature,
            humidity,
            co2,
        ]
    ])

    prediction = rf_model.predict(sample)

    probabilities = rf_model.predict_proba(sample)

    confidence = float(np.max(probabilities))

    label = rf_encoder.inverse_transform(
        prediction
    )[0]

    return {
        "label": standardize_label(label),
        "confidence": confidence,
    }

# =====================================
# Combined AI Prediction
# =====================================

def predict_combined(temperature, humidity, co2):

    lstm = predict_lstm(
        temperature,
        humidity,
        co2,
    )

    rf = predict_random_forest(
        temperature,
        humidity,
        co2,
    )

    # Choose the prediction with the higher confidence
    if lstm["confidence"] >= rf["confidence"]:
        final_prediction = lstm["label"]
    else:
        final_prediction = rf["label"]

    return {
        "lstm": lstm,
        "random_forest": rf,
        "final": final_prediction,
    }
