import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String username;
  String userPhotoUrl;
  String thumbnailUserPhotoUrl;
  String aboutYou;
  String email;
  bool isOnline;
  Timestamp recentOnline;
  bool active;
  String androidNotificationToken;
  List subscribers;
  Timestamp timestamp;

  User(
      {this.id,
      this.username,
      this.userPhotoUrl,
      this.thumbnailUserPhotoUrl,
      this.aboutYou,
      this.email,
      this.isOnline,
      this.recentOnline,
      this.active,
      this.androidNotificationToken,
      this.subscribers,
      this.timestamp});

  Map toMap(User user) {
    var data = Map<String, dynamic>();
    data['id'] = user.id;
    data['username'] = user.username;
    data['userPhotoUrl'] = user.userPhotoUrl;
    data['thumbnailUserPhotoUrl'] = user.thumbnailUserPhotoUrl;
    data['aboutYou'] = user.aboutYou;
    data['email'] = user.email;
    return data;
  }

  User.fromMap(Map<String, dynamic> mapData) {
    this.id = mapData['id'];
    this.username = mapData["username"];
    this.userPhotoUrl = mapData["userPhotoUrl"];
    this.thumbnailUserPhotoUrl = mapData["thumbnailUserPhotoUrl"];
    this.aboutYou = mapData["aboutYou"];
    this.email = mapData["email"];
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc["id"],
        username: doc['username'],
        userPhotoUrl: doc['userPhotoUrl'],
        thumbnailUserPhotoUrl: doc['thumbnailUserPhotoUrl'],
        aboutYou: doc['aboutYou'],
        email: doc['email'],
        isOnline: doc['isOnline'],
        recentOnline: doc['recentOnline'],
        active: doc['active'],
        androidNotificationToken: doc['androidNotificationToken'],
        subscribers: doc['subscribers'],
        timestamp: doc['timestamp']);
  }
}
