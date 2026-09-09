import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  double _pricePerKwh = 150.0; // السعر الافتراضي

  double get pricePerKwh => _pricePerKwh;

  SettingsProvider() {
    _loadSettings();
  }

  // تحميل السعر المحفوظ من الذاكرة
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // إذا لم يكن هناك سعر محفوظ، سيستخدم 150
    _pricePerKwh = prefs.getDouble('pricePerKwh') ?? 150.0;
    notifyListeners();
  }

  // حفظ السعر الجديد في الذاكرة
  Future<void> updatePrice(double newPrice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('pricePerKwh', newPrice);
    _pricePerKwh = newPrice;
    notifyListeners();
  }
}
