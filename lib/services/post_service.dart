import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:keptoon/config/collections.dart';
import 'package:uuid/uuid.dart';

class PostService {
  Stream<QuerySnapshot> streamPosts(String postType) {
    return postsRef
        .where("postType", isEqualTo: postType)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  addPost(
      String currentUserId,
      String postType,
      double latitude,
      double longitude,
      List mediaUrls,
      List thumbnail,
      List mediaTypes,
      List tags) async {
    var uuid = Uuid();
    postsRef.add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "ownerId": currentUserId,
      "postType": postType,
      "postLatitide": latitude,
      "postLongitude": longitude,
      "postMediaUrls": mediaUrls,
      "postMediathumbnailUrls": thumbnail,
      "mediaTypes": mediaTypes,
      "tags": tags,
      "likes": null,
      "comments": null,
      "timestamp": timestamp,
    });
  }

  Future<String> uploadImagePost(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child("post/post_image/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadImagePostThumbnail(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child("post/post_image_thumbnail/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToPost(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child("post/post_video/user_$path${uuid.v1().toString()}.mp4")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToPostThumb(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child("post/post_videoThumb/user_$path${uuid.v1().toString()}.jpg")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }
}
