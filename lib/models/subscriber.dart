import 'package:cloud_firestore/cloud_firestore.dart';

class Subscriber {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String meterNumber;
  final DateTime? createdAt;

  const Subscriber({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.meterNumber,
    this.createdAt,
  });

  // تحويل بيانات Firestore إلى Subscriber
  factory Subscriber.fromMap(String id, Map<String, dynamic> map) {
    return Subscriber(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      meterNumber: map['meterNumber'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // تحويل Subscriber إلى Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'meterNumber': meterNumber,
      'createdAt': createdAt,
    };
  }
}
