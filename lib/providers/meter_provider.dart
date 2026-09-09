import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/meter.dart';
import '../services/meter_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MeterProvider extends ChangeNotifier {
  final MeterService _meterService = MeterService();

  List<Meter> _meters = [];

  bool _isLoading = false;

  String? _errorMessage;

  String _searchQuery = '';

  StreamSubscription<List<Meter>>? _subscription;

  List<Meter> get meters => List.unmodifiable(_meters);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int get metersCount => _meters.length;

  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Meter> get filteredMeters {
    if (_searchQuery.trim().isEmpty) {
      return meters;
    }

    final searchText = _searchQuery.trim().toLowerCase();

    return _meters.where((meter) {
      return meter.meterNumber.toLowerCase().contains(searchText) ||
          meter.subscriberName.toLowerCase().contains(searchText) ||
          meter.type.toLowerCase().contains(searchText) ||
          meter.status.toLowerCase().contains(searchText);
    }).toList();
  }

  void startListening() {
    _subscription?.cancel();

    _setLoading(true);
    _clearError();

    _subscription = _meterService.watchMeters().listen(
      (data) {
        _meters = data;
        _setLoading(false);
      },
      onError: (error) {
        _setLoading(false);

        _errorMessage = 'حدث خطأ أثناء تحميل العدادات';

        notifyListeners();
      },
    );
  }

  Future<bool> addMeter(Meter meter) async {
    debugPrint('Firebase user: ${FirebaseAuth.instance.currentUser?.uid}');
    try {
      _setLoading(true);
      _clearError();

      final meterExists = await _meterService.meterNumberExists(
        meter.meterNumber,
      );

      if (meterExists) {
        _setLoading(false);
        _errorMessage = 'رقم العداد موجود مسبقًا';
        notifyListeners();
        return false;
      }

      final subscriberHasMeter = await _meterService.subscriberHasMeter(
        meter.subscriberId,
      );

      if (subscriberHasMeter) {
        _setLoading(false);
        _errorMessage = 'هذا المشترك مرتبط بعداد بالفعل';
        notifyListeners();
        return false;
      }

      await _meterService.addMeter(meter);

      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _errorMessage =
          'خطأ Firebase: ${e.code}\n${e.message ?? 'لا توجد تفاصيل'}';
      notifyListeners();
      return false;
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'خطأ: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMeter(Meter meter) async {
    try {
      _setLoading(true);
      _clearError();

      await _meterService.updateMeter(meter);

      _setLoading(false);

      return true;
    } catch (e) {
      _setLoading(false);

      _errorMessage = 'تعذر تعديل بيانات العداد';

      notifyListeners();

      return false;
    }
  }

  Future<bool> deleteMeter(String id) async {
    try {
      _setLoading(true);
      _clearError();

      await _meterService.deleteMeter(id);

      _setLoading(false);

      return true;
    } catch (e) {
      _setLoading(false);

      _errorMessage = 'تعذر حذف العداد';

      notifyListeners();

      return false;
    }
  }

  List<Meter> searchMeters(String query) {
    final searchText = query.trim().toLowerCase();

    if (searchText.isEmpty) {
      return meters;
    }

    return _meters.where((meter) {
      return meter.meterNumber.toLowerCase().contains(searchText) ||
          meter.subscriberName.toLowerCase().contains(searchText) ||
          meter.type.toLowerCase().contains(searchText) ||
          meter.status.toLowerCase().contains(searchText);
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
