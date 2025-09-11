import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder, FunctionTransformer
from sklearn.ensemble import RandomForestRegressor, StackingRegressor
from sklearn.linear_model import ElasticNet
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.metrics import r2_score, mean_absolute_error, mean_squared_error
from xgboost import XGBRegressor
from lightgbm import LGBMRegressor
import joblib
import optuna

# ========================
# Load Data
# ========================
df = pd.read_csv("sales_data_ready_dynamic.csv")

# ========================
# Custom Preprocessing Function
# ========================
def feature_engineering(df: pd.DataFrame):
    df = df.copy()

    if "date" in df.columns:
        df["date"] = pd.to_datetime(df["date"])
        df["year"] = df["date"].dt.year
        df["month"] = df["date"].dt.month
        df["day"] = df["date"].dt.day
        df["dayofweek"] = df["date"].dt.dayofweek
        df.drop(columns=["date"], inplace=True)

    # Encode categorical
    for col in df.select_dtypes(include=["object"]).columns:
        if col != "sales":
            le = LabelEncoder()
            df[col] = le.fit_transform(df[col].astype(str))

    df = df.sort_values(["year", "month", "day"]).reset_index(drop=True)

    # Lag & Rolling Features
    df["lag_1"] = df["sales"].shift(1).fillna(method="bfill")
    df["lag_7"] = df["sales"].shift(7).fillna(method="bfill")
    df["rolling_7"] = df["sales"].rolling(7, min_periods=1).mean().fillna(method="bfill")

    return df

# Apply preprocessing
df = feature_engineering(df)

# Split Features and Target
X = df.drop(columns=["sales"])
y = df["sales"]

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, shuffle=False
)

# ========================
# Base Models
# ========================
rf_model = RandomForestRegressor(n_estimators=500, max_depth=10, random_state=42, n_jobs=-1)
xgb_model = XGBRegressor(
    n_estimators=500, learning_rate=0.05, max_depth=6,
    subsample=0.9, colsample_bytree=0.8, random_state=42,
    eval_metric="rmse", n_jobs=-1
)
lgbm_model = LGBMRegressor(
    n_estimators=600, num_leaves=64, learning_rate=0.05,
    subsample=0.9, colsample_bytree=0.8, random_state=42, n_jobs=-1
)

meta_model = ElasticNet(alpha=0.01, l1_ratio=0.5, random_state=42, max_iter=5000)

# ========================
# Final Stacking Model
# ========================
stack_model = StackingRegressor(
    estimators=[("rf", rf_model), ("xgb", xgb_model), ("lgbm", lgbm_model)],
    final_estimator=meta_model,
    cv=5,
    n_jobs=-1
)

# ========================
# Pipeline: Scaling + Model
# ========================
stack_pipeline = Pipeline(steps=[
    ("scaler", StandardScaler()),
    ("model", stack_model)
])

# Fit pipeline
stack_pipeline.fit(X_train, y_train)

# Evaluate
y_pred_train = stack_pipeline.predict(X_train)
y_pred_test = stack_pipeline.predict(X_test)

print("\n📊 Final Ensemble Performance:")
print("Train R²:", r2_score(y_train, y_pred_train))
print("Test R² :", r2_score(y_test, y_pred_test))
print("MAE:", mean_absolute_error(y_test, y_pred_test))
print("RMSE:", np.sqrt(mean_squared_error(y_test, y_pred_test)))

# ========================
# Save Pipeline
# ========================
joblib.dump(stack_pipeline, "optimized_sales_pipeline.pkl")
print("\n✅ Saved Pipeline as optimized_sales_pipeline.pkl")
