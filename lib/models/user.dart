import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String profileName;
  final String username;
  final String url;
  final String email;
  final String bio;
  final int state;

  User({
    this.id,
    this.profileName,
    this.username,
    this.url,
    this.email,
    this.bio,
    this.state,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
      email: doc['email'],
      username: doc['username'],
      url: doc['url'],
      profileName: doc['profileName'],
      bio: doc['bio'] == null ? '' : doc['bio'],
      state: doc['state'],
    );
  }

  static User fromJson(Map<dynamic, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    username: json['username'],
    url: json['url'],
    profileName: json['profileName'],
    bio: json['bio'],
    state: json['state'],
  );
}