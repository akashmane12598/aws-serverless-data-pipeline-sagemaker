import shutil
import argparse
import os
import joblib
import pandas as pd

from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score


def find_csv_file(input_dir):
    for root, _, files in os.walk(input_dir):
        for file in files:
            if file.endswith(".csv"):
                return os.path.join(root, file)
    raise FileNotFoundError("No CSV file found in training input directory")


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument("--n-estimators", type=int, default=100)
    parser.add_argument("--test-size", type=float, default=0.2)

    args = parser.parse_args()

    train_dir = os.environ.get("SM_CHANNEL_TRAIN", "/opt/ml/input/data/train")
    model_dir = os.environ.get("SM_MODEL_DIR", "/opt/ml/model")

    csv_path = find_csv_file(train_dir)

    df = pd.read_csv(csv_path)

    features = ["temperature", "humidity", "pressure"]
    target = "status"

    df = df.dropna(subset=features + [target])

    X = df[features]
    y = df[target]

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=args.test_size,
        random_state=42
    )

    model = RandomForestClassifier(
        n_estimators=args.n_estimators,
        random_state=42
    )

    model.fit(X_train, y_train)

    predictions = model.predict(X_test)
    accuracy = accuracy_score(y_test, predictions)

    print(f"Model accuracy: {accuracy}")

    model_path = os.path.join(model_dir, "model.joblib")
    joblib.dump(model, model_path)

    model_path = os.path.join(model_dir, "model.joblib")
    joblib.dump(model, model_path)

    code_dir = os.path.join(model_dir, "code")
    os.makedirs(code_dir, exist_ok=True)

    current_dir = os.path.dirname(os.path.abspath(__file__))
    inference_script = os.path.join(current_dir, "inference.py")

    if os.path.exists(inference_script):
        shutil.copy(inference_script, os.path.join(code_dir, "inference.py"))

    print(f"Saved model to {model_path}")
    print(f"Saved inference.py to {code_dir}")


if __name__ == "__main__":
    main()