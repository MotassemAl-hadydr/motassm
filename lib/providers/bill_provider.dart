import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bill.dart';

class BillProvider with ChangeNotifier {
  List<Bill> _bills = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Bill> get bills => _bills;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchBills() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot =
          await _firestore
              .collection('bills')
              .orderBy('issueDate', descending: true)
              .get();

      _bills =
          snapshot.docs.map((doc) => Bill.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء جلب الفواتير: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addBill(Bill bill) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore.collection('bills').doc(bill.id).set(bill.toMap());
      _bills.insert(0, bill);
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء إصدار الفاتورة: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // الدالة الجديدة: تسجيل دفعة مالية (سواء كانت جزئية أو كلية)
  Future<bool> recordPayment(String billId, double paymentAmount) async {
    try {
      final index = _bills.indexWhere((b) => b.id == billId);
      if (index == -1) return false;

      final oldBill = _bills[index];

      // حساب المبالغ الجديدة
      final newPaidAmount = oldBill.paidAmount + paymentAmount;
      final newRemainingAmount = oldBill.totalAmount - newPaidAmount;

      // إذا كان المتبقي صفر أو أقل، تصبح الفاتورة مدفوعة بالكامل
      final isFullyPaid = newRemainingAmount <= 0;

      // التحديث في قاعدة البيانات
      await _firestore.collection('bills').doc(billId).update({
        'paidAmount': newPaidAmount,
        'remainingAmount': newRemainingAmount > 0 ? newRemainingAmount : 0.0,
        'isPaid': isFullyPaid,
      });

      // التحديث محلياً في التطبيق
      _bills[index] = Bill(
        id: oldBill.id,
        subscriberId: oldBill.subscriberId,
        subscriberName: oldBill.subscriberName,
        meterId: oldBill.meterId,
        readingId: oldBill.readingId,
        consumption: oldBill.consumption,
        totalAmount: oldBill.totalAmount,
        paidAmount: newPaidAmount,
        remainingAmount: newRemainingAmount > 0 ? newRemainingAmount : 0.0,
        issueDate: oldBill.issueDate,
        isPaid: isFullyPaid,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تسجيل الدفعة: $e';
      return false;
    }
  }

  // تعديل بيانات الفاتورة
  Future<bool> updateBill(Bill bill) async {
    try {
      await _firestore.collection('bills').doc(bill.id).update(bill.toMap());
      final index = _bills.indexWhere((b) => b.id == bill.id);
      if (index != -1) {
        _bills[index] = bill;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء التعديل: $e';
      return false;
    }
  }

  // حذف الفاتورة
  Future<bool> deleteBill(String id) async {
    try {
      await _firestore.collection('bills').doc(id).delete();
      _bills.removeWhere((b) => b.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء الحذف: $e';
      return false;
    }
  }
}
