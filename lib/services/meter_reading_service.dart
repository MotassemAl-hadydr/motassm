import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/meter_reading.dart';

class MeterReadingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get readings =>
      _firestore.collection('meter_readings');

  Future<void> addReading(MeterReading reading) async {
    await readings.add({
      ...reading.toMap(),
      'readingDate': FieldValue.serverTimestamp(),
    });
  }

  Future<List<MeterReading>> getReadings() async {
    final snapshot =
        await readings.orderBy('readingDate', descending: true).get();

    return snapshot.docs.map((doc) {
      return MeterReading.fromMap(doc.id, doc.data());
    }).toList();
  }

  Stream<List<MeterReading>> watchReadings() {
    return readings.orderBy('readingDate', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return MeterReading.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> updateReading(MeterReading reading) async {
    await readings.doc(reading.id).update(reading.toMap());
  }

  Future<void> deleteReading(String id) async {
    await readings.doc(id).delete();
  }

  Future<double> getLastReading(String meterId) async {
    final snapshot =
        await readings
            .where('meterId', isEqualTo: meterId)
            .orderBy('readingDate', descending: true)
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) {
      return 0;
    }

    final data = snapshot.docs.first.data();

    return (data['currentReading'] ?? 0).toDouble();
  }
}
