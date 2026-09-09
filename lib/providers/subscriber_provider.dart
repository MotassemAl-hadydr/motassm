import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/subscriber.dart';
import '../services/firestore_service.dart';

class SubscriberProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Subscriber> _subscribers = [];

  bool _isLoading = false;

  String? _errorMessage;

  String _searchQuery = '';

  StreamSubscription<List<Subscriber>>? _subscription;

  // ==============================
  // Getters
  // ==============================

  List<Subscriber> get subscribers => List.unmodifiable(_subscribers);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int get subscribersCount => _subscribers.length;

  // ==============================
  // البحث
  // ==============================

  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ==============================
  // البيانات المفلترة
  // ==============================

  List<Subscriber> get filteredSubscribers {
    if (_searchQuery.trim().isEmpty) {
      return subscribers;
    }

    final searchText = _searchQuery.trim().toLowerCase();

    return _subscribers.where((subscriber) {
      return subscriber.name.toLowerCase().contains(searchText) ||
          subscriber.phone.toLowerCase().contains(searchText) ||
          subscriber.meterNumber.toLowerCase().contains(searchText) ||
          subscriber.address.toLowerCase().contains(searchText);
    }).toList();
  }

  // ==============================
  // الاستماع للمشتركين
  // ==============================

  void startListening() {
    _subscription?.cancel();

    _setLoading(true);
    _clearError();

    _subscription = _firestoreService.watchSubscribers().listen(
      (data) {
        _subscribers = data;
        _setLoading(false);
      },
      onError: (error) {
        _setLoading(false);

        _errorMessage = 'حدث خطأ أثناء تحميل المشتركين';

        notifyListeners();
      },
    );
  }

  // ==============================
  // إضافة مشترك
  // ==============================

  Future<bool> addSubscriber(Subscriber subscriber) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.addSubscriber(subscriber);

      _setLoading(false);

      return true;
    } catch (e) {
      _setLoading(false);

      _errorMessage = 'خطأ Firebase:\n$e';

      notifyListeners();

      return false;
    }
  }

  // ==============================
  // تعديل مشترك
  // ==============================

  Future<bool> updateSubscriber(Subscriber subscriber) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.updateSubscriber(subscriber);

      _setLoading(false);

      return true;
    } catch (e) {
      _setLoading(false);

      _errorMessage = 'تعذر تعديل بيانات المشترك';

      notifyListeners();

      return false;
    }
  }

  // ==============================
  // حذف مشترك
  // ==============================

  Future<bool> deleteSubscriber(String id) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.deleteSubscriber(id);

      _setLoading(false);

      return true;
    } catch (e) {
      _setLoading(false);

      _errorMessage = 'تعذر حذف المشترك';

      notifyListeners();

      return false;
    }
  }

  // ==============================
  // الاسم القديم المستخدم في الشاشة
  // ==============================

  Future<bool> removeSubscriber(String id) async {
    return await deleteSubscriber(id);
  }

  // ==============================
  // البحث المباشر
  // ==============================

  List<Subscriber> searchSubscribers(String query) {
    final searchText = query.trim().toLowerCase();

    if (searchText.isEmpty) {
      return subscribers;
    }

    return _subscribers.where((subscriber) {
      return subscriber.name.toLowerCase().contains(searchText) ||
          subscriber.phone.toLowerCase().contains(searchText) ||
          subscriber.meterNumber.toLowerCase().contains(searchText) ||
          subscriber.address.toLowerCase().contains(searchText);
    }).toList();
  }

  // ==============================
  // Dispose
  // ==============================

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // ==============================
  // Helpers
  // ==============================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
