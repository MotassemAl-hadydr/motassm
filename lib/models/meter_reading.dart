import 'package:cloud_firestore/cloud_firestore.dart';

class MeterReading {
  final String id;
  final String meterId;
  final String meterNumber;
  final String subscriberId;
  final String subscriberName;
  final double previousReading;
  final double currentReading;
  final double consumption;
  final DateTime readingDate;

  const MeterReading({
    required this.id,
    required this.meterId,
    required this.meterNumber,
    required this.subscriberId,
    required this.subscriberName,
    required this.previousReading,
    required this.currentReading,
    required this.consumption,
    required this.readingDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'meterId': meterId,
      'meterNumber': meterNumber,
      'subscriberId': subscriberId,
      'subscriberName': subscriberName,
      'previousReading': previousReading,
      'currentReading': currentReading,
      'consumption': consumption,
      'readingDate': readingDate,
    };
  }

  factory MeterReading.fromMap(String id, Map<String, dynamic> map) {
    final readingDate = map['readingDate'];

    return MeterReading(
      id: id,
      meterId: map['meterId'] ?? '',
      meterNumber: map['meterNumber'] ?? '',
      subscriberId: map['subscriberId'] ?? '',
      subscriberName: map['subscriberName'] ?? '',
      previousReading: (map['previousReading'] ?? 0).toDouble(),
      currentReading: (map['currentReading'] ?? 0).toDouble(),
      consumption: (map['consumption'] ?? 0).toDouble(),
      readingDate:
          readingDate is Timestamp
              ? readingDate.toDate()
              : readingDate is DateTime
              ? readingDate
              : DateTime.now(),
    );
  }
}
