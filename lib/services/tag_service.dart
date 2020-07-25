import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keptoon/config/collections.dart';
import 'package:keptoon/models/tag.dart';
import 'package:uuid/uuid.dart';

class TagsServices {
  Future<QuerySnapshot> tagCheckSe(String tag) async {
    final result = await tagsRef.where('tag', isEqualTo: tag).getDocuments();
    return result;
  }

  Future<Tag> addNewTag(String tag, String currentUserId) async {
    var uuid = Uuid();
    DocumentReference doc = await tagsRef.add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "ownerId": currentUserId,
      "usedCount": 0,
      "tag": tag,
      "taggedUserIds": null,
      "timestamp": timestamp,
    });

    DocumentSnapshot tagSDoc = await getTagDocSnp(doc.documentID);

    return Tag.fromDocument(tagSDoc);
  }

  getTagDocSnp(String docId) async {
    return tagsRef.document(docId).get();
  }

  Future<QuerySnapshot> getAllTaqgs() async {
    return await tagsRef.getDocuments();
  }

  Stream<QuerySnapshot> streamingTags() {
    return tagsRef.orderBy('timestamp', descending: false).snapshots();
  }

  updateTagsCount(String currentUserId, String tag) async {
    QuerySnapshot snp =
        await tagsRef.where('tag', isEqualTo: tag).getDocuments();

    Tag tagRe = Tag.fromDocument(snp.documents[0]);
    List users = [];
    int count = tagRe.usedCount + 1;

    if (tagRe.taggedUserIds != null) {
      users = tagRe.taggedUserIds;
      if (!tagRe.taggedUserIds.contains(currentUserId)) {
        users.add(currentUserId);
      }
    } else {
      users.add(currentUserId);
    }

    tagsRef.document(snp.documents[0].documentID).updateData({
      "usedCount": count,
      "taggedUserIds": users,
    });
  }
}
