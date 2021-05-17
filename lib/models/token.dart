import 'package:cloud_firestore/cloud_firestore.dart';

class Token {
  String token;
  DateTime createdAt;

  Token({
    this.token,
    this.createdAt,
  });

  Token.fromData(Map<String, dynamic> data)
      : token = data['token'],
        createdAt = data['createdAt'];

  static Token fromMap(Map<String, dynamic> map) {
    if (map == null) {
      return null;
    }
    return Token(
        token: map['token'],
        createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'createdAt': createdAt,
    };
  }

}