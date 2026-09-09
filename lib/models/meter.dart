import 'package:cloud_firestore/cloud_firestore.dart';

class Meter {
  final String id;
  final String meterNumber;
  final String subscriberId;
  final String subscriberName;
  final String type;
  final String status;
  final DateTime createdAt;

  const Meter({
    required this.id,
    required this.meterNumber,
    required this.subscriberId,
    required this.subscriberName,
    required this.type,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'meterNumber': meterNumber,
      'subscriberId': subscriberId,
      'subscriberName': subscriberName,
      'type': type,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory Meter.fromMap(String id, Map<String, dynamic> map) {
    return Meter(
      id: id,
      meterNumber: map['meterNumber'] ?? '',
      subscriberId: map['subscriberId'] ?? '',
      subscriberName: map['subscriberName'] ?? '',
      type: map['type'] ?? 'منزلي',
      status: map['status'] ?? 'نشط',
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : map['createdAt'] is DateTime
              ? map['createdAt'] as DateTime
              : DateTime.now(),
    );
  }
}
