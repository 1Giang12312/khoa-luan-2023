import 'package:shared_preferences/shared_preferences.dart';

Future<void> clearUserCredentials() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('username');
  await prefs.remove('password');
}
