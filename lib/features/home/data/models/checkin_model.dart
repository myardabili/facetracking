import 'dart:convert';

class CheckinModel {
  final String? message;
  final Attendance? attendance;

  CheckinModel({
    this.message,
    this.attendance,
  });

  factory CheckinModel.fromJson(String str) =>
      CheckinModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CheckinModel.fromMap(Map<String, dynamic> json) => CheckinModel(
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
  final int? userId;
  final DateTime? date;
  final String? timeIn;
  final String? latlongIn;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int? id;

  Attendance({
    this.userId,
    this.date,
    this.timeIn,
    this.latlongIn,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory Attendance.fromJson(String str) =>
      Attendance.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Attendance.fromMap(Map<String, dynamic> json) => Attendance(
        userId: json["user_id"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        timeIn: json["time_in"],
        latlongIn: json["latlong_in"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        id: json["id"],
      );

  Map<String, dynamic> toMap() => {
        "user_id": userId,
        "date":
            "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "time_in": timeIn,
        "latlong_in": latlongIn,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "id": id,
      };
}
