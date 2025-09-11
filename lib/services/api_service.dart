import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

var logger = Logger();

class ApiService {
  // static const String baseUrl = "http://127.0.0.1:8000"; // Localhost for desktop
  // static final baseUrl = "http://10.0.2.2:8000"; // Android emulator localhost
  static final baseUrl = "http://192.168.100.41:8000";

  /// Get prediction from FastAPI
  /// [inputData] should include main required fields:
  /// price, discount, qty_last_7d, qty_last_30d, dow, month
  /// Optional fields will be added automatically if missing
  static Future<double?> getPrediction(Map<String, dynamic> inputData) async {
    // Ensure optional fields exist, assign 0 if missing
    final Map<String, dynamic> payload = {
      "price": inputData["price"] ?? 0,
      "discount": inputData["discount"] ?? 0,
      "qty_last_7d": inputData["qty_last_7d"] ?? 0,
      "qty_last_30d": inputData["qty_last_30d"] ?? 0,
      "dow": inputData["dow"] ?? 0,
      "month": inputData["month"] ?? 0,

      // Optional fields with default 0
      "sales_lag_1": inputData["sales_lag_1"] ?? 0,
      "sales_lag_7": inputData["sales_lag_7"] ?? 0,
      "sales_lag_14": inputData["sales_lag_14"] ?? 0,
      "sales_lag_30": inputData["sales_lag_30"] ?? 0,
      "sales_roll_mean_7": inputData["sales_roll_mean_7"] ?? 0,
      "sales_roll_mean_30": inputData["sales_roll_mean_30"] ?? 0,
      "sales_roll_std_7": inputData["sales_roll_std_7"] ?? 0,
      "sales_roll_std_30": inputData["sales_roll_std_30"] ?? 0,
      "day_of_week": inputData["day_of_week"] ?? 0,
      "week_of_year": inputData["week_of_year"] ?? 0,
      "quarter": inputData["quarter"] ?? 0,
      "is_holiday": inputData["is_holiday"] ?? 0,
      "is_special_occasion": inputData["is_special_occasion"] ?? 0,
      "is_peak_season": inputData["is_peak_season"] ?? 0,
      "is_off_season": inputData["is_off_season"] ?? 0,
    };

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.i("Prediction received: ${data["prediction"]}");
        return (data["prediction"] as num).toDouble();
      } else {
        logger.e("Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      logger.e("Exception while fetching prediction: $e");
      return null;
    }
  }
}
