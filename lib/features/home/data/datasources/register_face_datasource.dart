// import 'package:camera/camera.dart';
// import 'package:camera/camera.dart';
import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:facetracking/api/urls.dart';
import 'package:facetracking/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:facetracking/features/home/data/models/register_face_model.dart';
import 'package:http/http.dart' as http;

class RegisterFaceDatasource {
  Future<Either<String, RegisterFaceModel>> registerFace(
      String embedding, XFile image) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${URLs.base}/api/update-profile');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer ${authData?.token}'
      ..fields['face_embedding'] = embedding
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    print('URL: $url');
    print('Headers: ${request.headers}');
    print('Fields: ${request.fields}');

    final response = await request.send();
    final responseString = await response.stream.bytesToString();

    print('Status Code: ${response.statusCode}');
    print('Response: $responseString');

    if (response.statusCode == 200) {
      return Right(RegisterFaceModel.fromJson(responseString));
    } else {
      return const Left('Failed to update profile');
    }
  }
}
