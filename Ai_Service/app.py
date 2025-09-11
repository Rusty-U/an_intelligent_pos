from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import pandas as pd
from typing import Optional

# FastAPI app create
app = FastAPI(title="Sales Forecast API")

# Model load karo (sirf ek dafa, startup pe)
try:
    model = joblib.load("optimized_sales_model.pkl")
except Exception as e:
    raise RuntimeError(f"Model load karne me error: {e}")

# ✅ Request ka format define karo
class InputData(BaseModel):
    price: float
    discount: float
    qty_last_7d: float
    qty_last_30d: float
    dow: int   # day of week
    month: int # month
    
    # 🔥 Optional fields with default values
    sales_lag_1: Optional[float] = 0
    sales_lag_7: Optional[float] = 0
    sales_lag_14: Optional[float] = 0
    sales_lag_30: Optional[float] = 0
    sales_roll_mean_7: Optional[float] = 0
    sales_roll_mean_30: Optional[float] = 0
    sales_roll_std_7: Optional[float] = 0
    sales_roll_std_30: Optional[float] = 0
    day_of_week: Optional[int] = 0
    week_of_year: Optional[int] = 0
    quarter: Optional[int] = 0
    is_holiday: Optional[int] = 0
    is_special_occasion: Optional[int] = 0
    is_peak_season: Optional[int] = 0
    is_off_season: Optional[int] = 0

@app.get("/")
def home():
    return {"message": "API is running"}

@app.post("/predict")
def predict(data: InputData):
    # Input ko DataFrame me convert karo
    df = pd.DataFrame([data.dict()])

    # Prediction
    try:
        prediction = model.predict(df)
        return {"prediction": float(prediction[0])}
    except Exception as e:
        return {"error": f"Prediction failed: {str(e)}"}
