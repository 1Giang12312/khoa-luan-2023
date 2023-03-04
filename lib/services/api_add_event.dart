import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> addCollection({String}) async {
  CollectionReference user = FirebaseFirestore.instance.collection('tai_khoan');
  return 'Created';
}
