import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/meter.dart';
import '../../models/subscriber.dart';
import '../../providers/meter_provider.dart';
import '../../providers/subscriber_provider.dart';

class EditMeterScreen extends StatefulWidget {
  final Meter meter;

  const EditMeterScreen({super.key, required this.meter});

  @override
  State<EditMeterScreen> createState() => _EditMeterScreenState();
}

class _EditMeterScreenState extends State<EditMeterScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _meterNumberController;

  late String _selectedType;
  late String _selectedStatus;
  late String _selectedSubscriberId;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _meterNumberController = TextEditingController(
      text: widget.meter.meterNumber,
    );

    _selectedType = widget.meter.type;
    _selectedStatus = widget.meter.status;
    _selectedSubscriberId = widget.meter.subscriberId;
  }

  @override
  void dispose() {
    _meterNumberController.dispose();
    super.dispose();
  }

  Future<void> _updateMeter() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final subscriberProvider = context.read<SubscriberProvider>();

    Subscriber? selectedSubscriber;

    for (final subscriber in subscriberProvider.subscribers) {
      if (subscriber.id == _selectedSubscriberId) {
        selectedSubscriber = subscriber;
        break;
      }
    }

    if (selectedSubscriber == null) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر العثور على المشترك')));

      return;
    }

    final updatedMeter = Meter(
      id: widget.meter.id,
      meterNumber: _meterNumberController.text.trim(),
      subscriberId: selectedSubscriber.id,
      subscriberName: selectedSubscriber.name,
      type: _selectedType,
      status: _selectedStatus,
      createdAt: widget.meter.createdAt,
    );

    final success = await context.read<MeterProvider>().updateMeter(
      updatedMeter,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تعديل بيانات العداد بنجاح')),
      );

      Navigator.pop(context);
    } else {
      final error = context.read<MeterProvider>().errorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'تعذر تعديل بيانات العداد')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriberProvider = context.watch<SubscriberProvider>();

    final subscribers = subscriberProvider.subscribers;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تعديل العداد',
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
                'تعديل بيانات العداد',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                'قم بتعديل بيانات العداد ثم اضغط حفظ',
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
                          if (value == null) {
                            return;
                          }

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
                  onPressed: _isSaving ? null : _updateMeter,
                  icon:
                      _isSaving
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ التعديلات'),
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
