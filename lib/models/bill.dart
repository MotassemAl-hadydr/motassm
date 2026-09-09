import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  final String id;
  final String subscriberId;
  final String subscriberName;
  final String meterId;
  final String readingId;
  final double consumption;
  final double totalAmount;
  final double paidAmount; // جديد: المبلغ المدفوع
  final double remainingAmount; // جديد: المبلغ المتبقي
  final DateTime issueDate;
  final bool isPaid;

  Bill({
    required this.id,
    required this.subscriberId,
    required this.subscriberName,
    required this.meterId,
    required this.readingId,
    required this.consumption,
    required this.totalAmount,
    this.paidAmount = 0.0, // الافتراضي عند الإصدار صفر
    required this.remainingAmount,
    required this.issueDate,
    this.isPaid = false,
  });

  // تحويل البيانات للحفظ في فايربيز
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subscriberId': subscriberId,
      'subscriberName': subscriberName,
      'meterId': meterId,
      'readingId': readingId,
      'consumption': consumption,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'issueDate': Timestamp.fromDate(issueDate),
      'isPaid': isPaid,
    };
  }

  // استرجاع البيانات من فايربيز
  factory Bill.fromMap(Map<String, dynamic> map, String documentId) {
    return Bill(
      id: documentId,
      subscriberId: map['subscriberId'] ?? '',
      subscriberName: map['subscriberName'] ?? '',
      meterId: map['meterId'] ?? '',
      readingId: map['readingId'] ?? '',
      consumption: (map['consumption'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      paidAmount: (map['paidAmount'] ?? 0).toDouble(),
      remainingAmount: (map['remainingAmount'] ?? 0).toDouble(),
      issueDate: (map['issueDate'] as Timestamp).toDate(),
      isPaid: map['isPaid'] ?? false,
    );
  }
}
