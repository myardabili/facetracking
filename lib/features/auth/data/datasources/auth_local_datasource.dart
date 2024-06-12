import 'package:facetracking/features/auth/data/models/login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDatasource {
  final key = 'auth_data';

  Future<void> saveAuthData(LoginModel loginModel) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString(key, loginModel.toJson());
  }

  Future<void> removeAuthData() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(key);
  }

  Future<LoginModel?> getAuthData() async {
    final pref = await SharedPreferences.getInstance();
    final data = pref.getString(key);
    if (data != null) {
      return LoginModel.fromJson(data);
    } else {
      return null;
    }
  }

  Future<bool> isAuth() async {
    final pref = await SharedPreferences.getInstance();
    final data = pref.getString(key);
    return data != null;
  }
}
