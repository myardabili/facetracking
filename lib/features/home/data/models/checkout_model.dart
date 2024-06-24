import 'dart:convert';

class CheckoutModel {
  final String? message;
  final Attendance? attendance;

  CheckoutModel({
    this.message,
    this.attendance,
  });

  factory CheckoutModel.fromJson(String str) =>
      CheckoutModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CheckoutModel.fromMap(Map<String, dynamic> json) => CheckoutModel(
        message: json["message"],
        attendance: json["attendance"] == null
            ? null
            : Attendance.fromMap(json["attendance"]),
      );

  Map<String, dynamic> toMap() => {
        "message": message,
        "attendance": attendance?.toMap(),
      };
}

class Attendance {
  final int? id;
  final int? userId;
  final DateTime? date;
  final String? timeIn;
  final String? timeOut;
  final String? latlongIn;
  final String? latlongOut;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Attendance({
    this.id,
    this.userId,
    this.date,
    this.timeIn,
    this.timeOut,
    this.latlongIn,
    this.latlongOut,
    this.createdAt,
    this.updatedAt,
  });

  factory Attendance.fromJson(String str) =>
      Attendance.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Attendance.fromMap(Map<String, dynamic> json) => Attendance(
        id: json["id"],
        userId: json["user_id"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        timeIn: json["time_in"],
        timeOut: json["time_out"],
        latlongIn: json["latlong_in"],
        latlongOut: json["latlong_out"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "user_id": userId,
        "date":
            "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "time_in": timeIn,
        "time_out": timeOut,
        "latlong_in": latlongIn,
        "latlong_out": latlongOut,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
