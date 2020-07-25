import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String id;
  String ownerId;
  String postType;
  double postLatitide;
  double postLongitude;
  List postMediaUrls;
  List postMediathumbnailUrls;
  List mediaTypes;
  List tags;
  List likes;
  List comments;
  Timestamp timestamp;

  Post({
    this.id,
    this.ownerId,
    this.postType,
    this.postLatitide,
    this.postLongitude,
    this.postMediaUrls,
    this.postMediathumbnailUrls,
    this.mediaTypes,
    this.tags,
    this.likes,
    this.comments,
    this.timestamp,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
        id: doc["id"],
        ownerId: doc['ownerId'],
        postType: doc['postType'],
        postLatitide: doc['postLatitide'],
        postLongitude: doc['postLongitude'],
        postMediaUrls: doc['postMediaUrls'],
        postMediathumbnailUrls: doc['postMediathumbnailUrls'],
        mediaTypes: doc['mediaTypes'],
        tags: doc['tags'],
        likes: doc['likes'],
        comments: doc['comments'],
        timestamp: doc['timestamp']);
  }
}
