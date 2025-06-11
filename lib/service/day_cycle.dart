import 'package:shared_preferences/shared_preferences.dart';

class DayCycle {
  DayCycle();

  Future<void> saveCurrentDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('date', DateTime.now().toUtc().toIso8601String());
  }

  Future<DateTime?> getCurrentDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? date = prefs.getString('date');
    if (date != null) {
      return DateTime.parse(date).toLocal();
    } else {
      return null;
    }
  }

  Future<bool> checkNewDay() async {
    int currentDay = DateTime.now().day;
    DateTime? dateTime = await getCurrentDate();

    if (dateTime?.day != currentDay) {
      return true;
    } else {
      return false;
    }
  }
}