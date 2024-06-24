// import 'package:camera/camera.dart';
// import 'package:camera/camera.dart';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:facetracking/api/urls.dart';
import 'package:facetracking/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:facetracking/features/home/data/models/checkin_model.dart';
import 'package:facetracking/features/home/data/models/checkout_model.dart';
import 'package:facetracking/features/home/data/models/company_model.dart';
import 'package:facetracking/features/home/data/models/register_face_model.dart';
import 'package:http/http.dart' as http;

class AttendanceRemoteDatasource {
  Future<Either<String, RegisterFaceModel>> registerFace(
      String embedding, XFile image) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${URLs.base}/api/update-profile');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer ${authData?.token}'
      ..fields['face_embedding'] = embedding
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    // print('URL: $url');
    // print('Headers: ${request.headers}');
    // print('Fields: ${request.fields}');

    final response = await request.send();
    final responseString = await response.stream.bytesToString();

    // print('Status Code: ${response.statusCode}');
    // print('Response: $responseString');

    if (response.statusCode == 200) {
      return Right(RegisterFaceModel.fromJson(responseString));
    } else {
      return const Left('Failed to update profile');
    }
  }

  Future<Either<String, CompanyModel>> getCompany() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${URLs.base}/api/company');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
    );
    if (response.statusCode == 200) {
      return Right(CompanyModel.fromJson(response.body));
    } else {
      return const Left('Failed to get company profile');
    }
  }

  Future<Either<String, CheckinModel>> checkin(
      String latitude, String longitude) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${URLs.base}/api/checkin');
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
      }),
    );
    if (response.statusCode == 200) {
      return Right(CheckinModel.fromJson(response.body));
    } else {
      return const Left('Checkin failed');
    }
  }

  Future<Either<String, CheckoutModel>> checkout(
      String latitude, String longitude) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${URLs.base}/api/checkout');
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
      }),
    );
    if (response.statusCode == 200) {
      return Right(CheckoutModel.fromJson(response.body));
    } else {
      return const Left('Checkout failed');
    }
  }

  Future<Either<String, bool>> isCheckedin() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${URLs.base}/api/is-checkin');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return Right(responseData['message'] as bool);
    } else {
      return const Left('Failed to get checkedin status');
    }
  }
}
