import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/meter.dart';
import '../../models/subscriber.dart';
import '../../providers/meter_provider.dart';
import '../../providers/subscriber_provider.dart';

class AddMeterScreen extends StatefulWidget {
  const AddMeterScreen({super.key});

  @override
  State<AddMeterScreen> createState() => _AddMeterScreenState();
}

class _AddMeterScreenState extends State<AddMeterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _meterNumberController = TextEditingController();

  String? _selectedSubscriberId;

  String _selectedType = 'منزلي';

  String _selectedStatus = 'نشط';

  bool _isSaving = false;

  @override
  void dispose() {
    _meterNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveMeter() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSubscriberId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار المشترك')));
      return;
    }

    final subscriberProvider = context.read<SubscriberProvider>();

    Subscriber? selectedSubscriber;

    for (final subscriber in subscriberProvider.subscribers) {
      if (subscriber.id == _selectedSubscriberId) {
        selectedSubscriber = subscriber;
        break;
      }
    }

    if (selectedSubscriber == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر العثور على المشترك')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final meter = Meter(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      meterNumber: _meterNumberController.text.trim(),
      subscriberId: selectedSubscriber.id,
      subscriberName: selectedSubscriber.name,
      type: _selectedType,
      status: _selectedStatus,
      createdAt: DateTime.now(),
    );

    final success = await context.read<MeterProvider>().addMeter(meter);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تمت إضافة العداد بنجاح')));

      Navigator.pop(context);
    } else {
      final error = context.read<MeterProvider>().errorMessage;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'تعذر إضافة العداد')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriberProvider = context.watch<SubscriberProvider>();

    final subscribers = subscriberProvider.subscribers;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إضافة عداد',
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
                'بيانات العداد',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                'أدخل بيانات العداد واربطه بالمشترك',
                style: TextStyle(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 28),

              _buildLabel('رقم العداد'),

              TextFormField(
                controller: _meterNumberController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'مثال: M-1001',
                  prefixIcon: Icon(Icons.electric_meter_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال رقم العداد';
                  }

                  if (value.trim().length < 3) {
                    return 'رقم العداد غير صحيح';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              _buildLabel('المشترك'),

              DropdownButtonFormField<String>(
                value: _selectedSubscriberId,
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: 'اختر المشترك',
                ),
                items:
                    subscribers.map((subscriber) {
                      return DropdownMenuItem<String>(
                        value: subscriber.id,
                        child: Text(
                          '${subscriber.name} - ${subscriber.meterNumber}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                onChanged:
                    _isSaving
                        ? null
                        : (value) {
                          setState(() {
                            _selectedSubscriberId = value;
                          });
                        },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى اختيار المشترك';
                  }

                  return null;
                },
              ),

              if (subscribers.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'لا يوجد مشتركون. أضف مشتركًا أولًا.',
                  style: TextStyle(color: Colors.red.shade600, fontSize: 13),
                ),
              ],

              const SizedBox(height: 18),

              _buildLabel('نوع العداد'),

              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.home_work_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'منزلي', child: Text('منزلي')),
                  DropdownMenuItem(value: 'تجاري', child: Text('تجاري')),
                  DropdownMenuItem(value: 'صناعي', child: Text('صناعي')),
                ],
                onChanged:
                    _isSaving
                        ? null
                        : (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _selectedType = value;
                          });
                        },
              ),

              const SizedBox(height: 18),

              _buildLabel('حالة العداد'),

              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.power_settings_new),
                ),
                items: const [
                  DropdownMenuItem(value: 'نشط', child: Text('نشط')),
                  DropdownMenuItem(value: 'متوقف', child: Text('متوقف')),
                  DropdownMenuItem(value: 'معطل', child: Text('معطل')),
                ],
                onChanged:
                    _isSaving
                        ? null
                        : (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _selectedStatus = value;
                          });
                        },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveMeter,
                  icon:
                      _isSaving
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.add_circle_outline),
                  label: Text(_isSaving ? 'جاري الحفظ...' : 'إضافة العداد'),
                ),
              ),
            ],
          ),
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
