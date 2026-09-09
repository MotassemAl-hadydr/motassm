import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/meter.dart';
import '../../models/meter_reading.dart';
import '../../providers/meter_provider.dart';
import '../../providers/meter_reading_provider.dart';
import '../../providers/subscriber_provider.dart'; // تمت إضافة هذا الاستيراد
// الاستيرادات الجديدة الخاصة بالفواتير
import '../../models/bill.dart';
import '../../providers/bill_provider.dart';
import '../../providers/settings_provider.dart';

class AddReadingScreen extends StatefulWidget {
  const AddReadingScreen({super.key});

  @override
  State<AddReadingScreen> createState() => _AddReadingScreenState();
}

class _AddReadingScreenState extends State<AddReadingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentReadingController = TextEditingController();

  String? _selectedMeterId;

  Meter? _selectedMeter;

  double _previousReading = 0;

  double _consumption = 0;

  bool _isLoadingPrevious = false;

  bool _isSaving = false;

  // تمت إضافة دالة initState هنا لجلب البيانات عند فتح الشاشة
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // إجبار التطبيق على تحميل العدادات والمشتركين لتظهر في القائمة المنسدلة
      context.read<MeterProvider>().startListening();
      context.read<SubscriberProvider>().startListening();
      context.read<MeterReadingProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _currentReadingController.dispose();
    super.dispose();
  }

  Future<void> _selectMeter(String? meterId) async {
    if (meterId == null) {
      return;
    }

    final meterProvider = context.read<MeterProvider>();

    Meter? selectedMeter;

    for (final meter in meterProvider.meters) {
      if (meter.id == meterId) {
        selectedMeter = meter;
        break;
      }
    }

    if (selectedMeter == null) {
      return;
    }

    setState(() {
      _selectedMeterId = meterId;
      _selectedMeter = selectedMeter;
      _previousReading = 0;
      _consumption = 0;
      _isLoadingPrevious = true;
    });

    final previous = await context.read<MeterReadingProvider>().getLastReading(
      selectedMeter.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _previousReading = previous;
      _isLoadingPrevious = false;
    });

    _calculateConsumption();
  }

  void _calculateConsumption() {
    final currentText = _currentReadingController.text.trim();

    final current = double.tryParse(currentText);

    if (current == null) {
      setState(() {
        _consumption = 0;
      });
      return;
    }

    setState(() {
      _consumption = current - _previousReading;
    });
  }

  Future<void> _saveReading() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMeter == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار العداد')));
      return;
    }

    final currentReading = double.tryParse(
      _currentReadingController.text.trim(),
    );

    if (currentReading == null) {
      return;
    }

    if (currentReading < _previousReading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'القراءة الحالية لا يمكن أن تكون أقل من القراءة السابقة',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final meter = _selectedMeter!;

    final reading = MeterReading(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      meterId: meter.id,
      meterNumber: meter.meterNumber,
      subscriberId: meter.subscriberId,
      subscriberName: meter.subscriberName,
      previousReading: _previousReading,
      currentReading: currentReading,
      consumption: currentReading - _previousReading,
      readingDate: DateTime.now(),
    );

    final success = await context.read<MeterReadingProvider>().addReading(
      reading,
    );

    if (!mounted) {
      return;
    }

    // -- بداية التعديل الخاص بإصدار الفاتورة تلقائياً --
    if (success) {
      // 1. حساب قيمة الفاتورة (تم تحديد سعر الكيلوواط بـ 150 ريال كمثال)
      // جلب السعر المتغير بدلاً من السعر الثابت
      final pricePerKwh = context.read<SettingsProvider>().pricePerKwh;
      final totalAmount = reading.consumption * pricePerKwh;

      // 2. إنشاء كائن الفاتورة
      final bill = Bill(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        subscriberId: reading.subscriberId,
        subscriberName: reading.subscriberName,
        meterId: reading.meterId,
        readingId: reading.id,
        consumption: reading.consumption,
        totalAmount: totalAmount,
        paidAmount: 0.0, // جديد: يبدأ المدفوع بصفر
        remainingAmount: totalAmount, // جديد: المتبقي هو المبلغ الإجمالي كاملاً
        issueDate: DateTime.now(),
      );

      // 3. حفظ الفاتورة في قاعدة البيانات
      await context.read<BillProvider>().addBill(bill);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت إضافة القراءة وإصدار الفاتورة بنجاح 🧾'),
        ),
      );

      Navigator.pop(context);
    } else {
      setState(() {
        _isSaving = false;
      });

      final error = context.read<MeterReadingProvider>().errorMessage;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'تعذر إضافة القراءة')));
    }
    // -- نهاية التعديل --
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final meterProvider = context.watch<MeterProvider>();

    final meters = meterProvider.meters;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'إضافة قراءة',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تسجيل قراءة جديدة',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  'اختر العداد وأدخل القراءة الحالية',
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 28),

                _buildLabel('العداد'),

                DropdownButtonFormField<String>(
                  value: _selectedMeterId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.electric_meter_outlined),
                    hintText: 'اختر العداد',
                  ),
                  items:
                      meters.map((meter) {
                        return DropdownMenuItem<String>(
                          value: meter.id,
                          child: Text(
                            '${meter.meterNumber} - ${meter.subscriberName}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                  onChanged: _isSaving ? null : _selectMeter,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى اختيار العداد';
                    }

                    return null;
                  },
                ),

                if (meters.isEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'لا توجد عدادات. أضف عدادًا أولًا.',
                    style: TextStyle(color: Colors.red.shade600, fontSize: 13),
                  ),
                ],

                const SizedBox(height: 24),

                if (_selectedMeter != null) _buildMeterInfo(),

                const SizedBox(height: 20),

                _buildLabel('القراءة السابقة'),

                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.history),
                    suffixText: 'كيلوواط',
                    hintText:
                        _isLoadingPrevious
                            ? 'جاري التحميل...'
                            : _formatNumber(_previousReading),
                  ),
                  controller: TextEditingController(
                    text:
                        _isLoadingPrevious
                            ? ''
                            : _formatNumber(_previousReading),
                  ),
                ),

                const SizedBox(height: 20),

                _buildLabel('القراءة الحالية'),

                TextFormField(
                  controller: _currentReadingController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  enabled: !_isSaving,
                  onChanged: (_) {
                    _calculateConsumption();
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.speed_rounded),
                    suffixText: 'كيلوواط',
                    hintText: 'مثال: 1250',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال القراءة الحالية';
                    }

                    final number = double.tryParse(value.trim());

                    if (number == null) {
                      return 'يرجى إدخال رقم صحيح';
                    }

                    if (number < _previousReading) {
                      return 'القراءة الحالية أقل من السابقة';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                _buildConsumptionCard(),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveReading,
                    icon:
                        _isSaving
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.save_outlined),
                    label: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ القراءة'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeterInfo() {
    final meter = _selectedMeter!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(child: const Icon(Icons.electric_meter_rounded)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meter.meterNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meter.subscriberName,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildSmallInfo('النوع', meter.type)),
                Expanded(child: _buildSmallInfo('الحالة', meter.status)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallInfo(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildConsumptionCard() {
    final validConsumption = _consumption >= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: const Icon(Icons.bolt_rounded, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الاستهلاك',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    validConsumption
                        ? '${_formatNumber(_consumption)} كيلوواط'
                        : 'غير صحيح',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'القراءة الحالية − القراءة السابقة',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}
