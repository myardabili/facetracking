import 'dart:convert';

import '../../../auth/data/models/login_model.dart';

class RegisterFaceModel {
  final String? message;
  final User? user;

  RegisterFaceModel({
    this.message,
    this.user,
  });

  factory RegisterFaceModel.fromJson(String str) =>
      RegisterFaceModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RegisterFaceModel.fromMap(Map<String, dynamic> json) =>
      RegisterFaceModel(
        message: json["message"],
        user: json["user"] == null ? null : User.fromMap(json["user"]),
      );

  Map<String, dynamic> toMap() => {
        "message": message,
        "user": user?.toMap(),
      };
}
