import 'package:cloud_firestore/cloud_firestore.dart';

class Tag {
  String id;
  String ownerId;
  String tag;
  int usedCount;
  List taggedUserIds;
  Timestamp timestamp;

  Tag({
    this.id,
    this.ownerId,
    this.usedCount,
    this.tag,
    this.taggedUserIds,
    this.timestamp,
  });

  Map toMap(Tag tagM) {
    var data = Map<String, dynamic>();
    data['id'] = tagM.id;
    data['ownerId'] = tagM.ownerId;
    data['usedCount'] = tagM.usedCount;
    data['tag'] = tagM.tag;
    data['taggedUserIds'] = tagM.taggedUserIds;
    return data;
  }

  factory Tag.fromDocument(DocumentSnapshot doc) {
    return Tag(
        id: doc["id"],
        ownerId: doc['ownerId'],
        usedCount: doc['usedCount'],
        tag: doc['tag'],
        taggedUserIds: doc['taggedUserIds'],
        timestamp: doc['timestamp']);
  }
}
