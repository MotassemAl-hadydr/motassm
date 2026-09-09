import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/meter.dart';

class MeterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get meters =>
      _firestore.collection('meters');

  // التحقق من وجود رقم العداد
  Future<bool> meterNumberExists(String meterNumber) async {
    final snapshot =
        await meters
            .where('meterNumber', isEqualTo: meterNumber.trim())
            .limit(1)
            .get();

    return snapshot.docs.isNotEmpty;
  }

  // التحقق من وجود عداد مرتبط بالمشترك
  Future<bool> subscriberHasMeter(String subscriberId) async {
    final snapshot =
        await meters
            .where('subscriberId', isEqualTo: subscriberId)
            .limit(1)
            .get();

    return snapshot.docs.isNotEmpty;
  }

  // إضافة عداد
  Future<void> addMeter(Meter meter) async {
    await meters.add({
      ...meter.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // جلب جميع العدادات
  Future<List<Meter>> getMeters() async {
    final snapshot = await meters.orderBy('createdAt', descending: true).get();

    return snapshot.docs.map((doc) {
      return Meter.fromMap(doc.id, doc.data());
    }).toList();
  }

  // الاستماع للعدادات بشكل مباشر
  Stream<List<Meter>> watchMeters() {
    return meters.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return Meter.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // تعديل العداد
  Future<void> updateMeter(Meter meter) async {
    await meters.doc(meter.id).update(meter.toMap());
  }

  // حذف العداد
  Future<void> deleteMeter(String id) async {
    await meters.doc(id).delete();
  }
}
