import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/meter_reading.dart';
import '../services/meter_reading_service.dart';

class MeterReadingProvider extends ChangeNotifier {
  final MeterReadingService _readingService = MeterReadingService();

  List<MeterReading> _readings = [];

  bool _isLoading = false;

  String? _errorMessage;

  String _searchQuery = '';

  StreamSubscription<List<MeterReading>>? _subscription;

  List<MeterReading> get readings => List.unmodifiable(_readings);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int get readingsCount => _readings.length;

  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<MeterReading> get filteredReadings {
    if (_searchQuery.trim().isEmpty) {
      return readings;
    }

    final searchText = _searchQuery.trim().toLowerCase();

    return _readings.where((reading) {
      return reading.meterNumber.toLowerCase().contains(searchText) ||
          reading.subscriberName.toLowerCase().contains(searchText);
    }).toList();
  }

  void startListening() {
    _subscription?.cancel();

    _setLoading(true);

    _clearError();

    _subscription = _readingService.watchReadings().listen(
      (data) {
        _readings = data;

        _setLoading(false);
      },
      onError: (error) {
        _setLoading(false);

        _errorMessage = 'حدث خطأ أثناء تحميل القراءات';

        notifyListeners();
      },
    );
  }

  Future<bool> addReading(MeterReading reading) async {
    try {
      _setLoading(true);

      _clearError();

      if (reading.currentReading < reading.previousReading) {
        _setLoading(false);

        _errorMessage =
            'القراءة الحالية لا يمكن أن تكون أقل من القراءة السابقة';

        notifyListeners();

        return false;
      }

      await _readingService.addReading(reading);

      _setLoading(false);

      return true;
    } catch (e) {
      _setLoading(false);

      _errorMessage = 'تعذر إضافة القراءة: $e';

      notifyListeners();

      return false;
    }
  }

  Future<bool> updateReading(MeterReading reading) async {
    try {
      _setLoading(true);

      _clearError();

      if (reading.currentReading < reading.previousReading) {
        _setLoading(false);

        _errorMessage =
            'القراءة الحالية لا يمكن أن تكون أقل من القراءة السابقة';

        notifyListeners();

        return false;
      }

      await _readingService.updateReading(reading);

      _setLoading(false);

      return true;
    } catch (e) {
      _setLoading(false);

      _errorMessage = 'تعذر تعديل القراءة: $e';

      notifyListeners();

      return false;
    }
  }

  Future<bool> deleteReading(String id) async {
    try {
      _setLoading(true);

      _clearError();

      await _readingService.deleteReading(id);

      _setLoading(false);

      return true;
    } catch (e) {
      _setLoading(false);

      _errorMessage = 'تعذر حذف القراءة: $e';

      notifyListeners();

      return false;
    }
  }

  // تأكد من وجود استيراد فايربيس أعلى الملف
  // import 'package:cloud_firestore/cloud_firestore.dart';
  Future<double> getLastReading(String meterId) async {
    try {
      // 1. فلترة القراءات المحملة مسبقاً لجلب قراءات هذا العداد فقط
      // استخدمنا المتغير readings الذي يعيد القائمة الحالية
      final previousReadings =
          readings.where((r) => r.meterId == meterId).toList();

      if (previousReadings.isNotEmpty) {
        // 2. ترتيب القراءات حسب التاريخ (من الأحدث إلى الأقدم)
        previousReadings.sort((a, b) => b.readingDate.compareTo(a.readingDate));

        // 3. إرجاع القراءة "الحالية" لأحدث سجل، لتصبح هي "السابقة" للعملية الجديدة
        return previousReadings.first.currentReading;
      }
    } catch (e) {
      debugPrint('حدث خطأ أثناء فلترة القراءات: $e');
    }

    // إرجاع صفر فقط إذا كان العداد لم يسجل له أي قراءة من قبل
    return 0.0;
  }

  List<MeterReading> searchReadings(String query) {
    final searchText = query.trim().toLowerCase();

    if (searchText.isEmpty) {
      return readings;
    }

    return _readings.where((reading) {
      return reading.meterNumber.toLowerCase().contains(searchText) ||
          reading.subscriberName.toLowerCase().contains(searchText);
    }).toList();
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;

    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
