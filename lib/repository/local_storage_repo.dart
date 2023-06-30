import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  //function to set token into local storage using the shared preferences
  void saveToken(String token) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("User_token", token);
  }

  //function to get token
  Future<String?> getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString("User_token");
    return token; //can be null too (if not stored there)
  }
}
