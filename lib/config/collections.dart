import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final StorageReference storageRef = FirebaseStorage.instance.ref();
final Firestore firestore = Firestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
final DateTime timestamp = DateTime.now();
final userRef = Firestore.instance.collection('user');
final tagsRef = Firestore.instance.collection('tags');
final postsRef = Firestore.instance.collection('posts');
