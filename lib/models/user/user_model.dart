// ignore_for_file: public_member_api_docs

import 'package:uuid/uuid.dart';

class User {
  User({
    required this.username,
    required this.password,
    required this.createdAt,
    required this.updatedAt,
    String? uid,
  }) {
    this.uid = uid ?? const Uuid().v4();
  }

  User.fromJson(Map<String, dynamic> json) {
    username = json['username'] as String;
    password = json['password'] as String;
    createdAt = json['created_at'] as String;
    updatedAt = json['updated_at'] as String;
    uid = json['uid'] as String;
  }
  String? username;
  String? password;
  String? createdAt;
  String? updatedAt;
  String? uid;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['username'] = username;
    data['password'] = password;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['uid'] = uid;
    return data;
  }
}
