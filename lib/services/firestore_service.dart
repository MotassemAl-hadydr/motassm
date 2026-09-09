import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/subscriber.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get subscribers =>
      _firestore.collection('subscribers');

  // إضافة مشترك
  Future<void> addSubscriber(Subscriber subscriber) async {
    await subscribers.add({
      ...subscriber.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // جلب المشتركين
  Future<List<Subscriber>> getSubscribers() async {
    final snapshot =
        await subscribers.orderBy('createdAt', descending: true).get();

    return snapshot.docs.map((doc) {
      return Subscriber.fromMap(doc.id, doc.data());
    }).toList();
  }

  // الاستماع للمشتركين لحظيًا
  Stream<List<Subscriber>> watchSubscribers() {
    return subscribers.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return Subscriber.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // تعديل مشترك
  Future<void> updateSubscriber(Subscriber subscriber) async {
    await subscribers.doc(subscriber.id).update(subscriber.toMap());
  }

  // حذف مشترك
  Future<void> deleteSubscriber(String id) async {
    await subscribers.doc(id).delete();
  }
}
