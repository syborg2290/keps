import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:keptoon/config/collections.dart';

class UserService {
  Stream<QuerySnapshot> streamingUser(String currentUserId) {
    return userRef
        .where('id', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot> getUser(String currentUserId) {
    return userRef.document(currentUserId).get();
  }

  updateUserImage(
      String userId, String userImageUrl, String thumbnailUrl) async {
    userRef.document(userId).updateData({
      'userPhotoUrl': userImageUrl,
      "thumbnailUserPhotoUrl": thumbnailUrl,
    });
  }

  Future<List<DocumentSnapshot>> getAllUsers() async {
    QuerySnapshot qsnap = await userRef.getDocuments();
    return qsnap.documents;
  }

  Future<String> uploadImageProfilePic(String userId, File imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("user_image/user_$userId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadImageProfilePicThumbnail(
      String userId, File imageFile) async {
    StorageUploadTask uploadTask = storageRef
        .child("user_image_thumbnail/user_$userId.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }
}
