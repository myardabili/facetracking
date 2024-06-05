import 'package:dartz/dartz.dart';
import 'package:facetracking/api/urls.dart';
import 'package:facetracking/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:facetracking/features/auth/data/models/login_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDatasource {
  Future<Either<String, LoginModel>> login(
      String email, String password) async {
    const url = '${URLs.base}/api/login';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'email': email,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      return Right(LoginModel.fromJson(response.body));
    } else {
      return const Left('Login failed');
    }
  }

  Future<Either<String, String>> logout() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${URLs.base}/api/logout');
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
    );
    if (response.statusCode == 200) {
      return const Right('Logout success');
    } else {
      return const Left('Logout failed');
    }
  }
}
