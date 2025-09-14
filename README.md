An Intelligent POS
An Intelligent POS (Point of Sale) system built using **Flutter** for the frontend and integrated with
**Python ML models** for sales forecasting and analytics. This project helps businesses manage
sales efficiently while providing future demand predictions.
■ Features
- User-friendly POS interface (built in Flutter)
- Product & sales management
- Sales reports (daily, weekly, monthly)
- AI-based sales forecasting (Python model)
- Export reports for business analysis
■ Project Structure
an_intelligent_pos/
■-- lib/ # Flutter frontend code
■-- assets/ # Images & resources
■-- models/ # ML model files (Python)
■-- backend/ # Python API (Flask/FastAPI)
■-- pubspec.yaml # Flutter dependencies
■-- requirements.txt # Python dependencies
■■ Installation & Setup
1. Clone the Repository
```
git clone https://github.com/your-username/an_intelligent_pos.git
cd an_intelligent_pos
```
2. Run Flutter Frontend
```
flutter pub get
flutter run
```
3. Run Backend (Python API)
```
cd backend
pip install -r requirements.txt
python app.py
```
■ Flutter ↔ Backend Connection
Flutter frontend fetches data from the backend API (`http://127.0.0.1:5000`). Ensure backend is
running before starting the Flutter app.
■ Dependencies
Flutter
- http
- provider
- shared_preferences
- charts_flutter
Python
- Flask / FastAPI
- pandas
- scikit-learn
- matplotlib
■■■ Author
Developed by Muhammad Umar Bilal
