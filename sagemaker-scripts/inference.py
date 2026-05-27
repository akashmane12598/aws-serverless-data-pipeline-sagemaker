import os
import joblib
import pandas as pd


def model_fn(model_dir):
    model_path = os.path.join(model_dir, "model.joblib")
    return joblib.load(model_path)


def input_fn(request_body, request_content_type):
    if request_content_type == "text/csv":
        values = [float(x) for x in request_body.strip().split(",")]
        return pd.DataFrame(
            [values],
            columns=["temperature", "humidity", "pressure"]
        )

    raise ValueError(f"Unsupported content type: {request_content_type}")


def predict_fn(input_data, model):
    return model.predict(input_data)


def output_fn(prediction, response_content_type):
    return ",".join(prediction.tolist())