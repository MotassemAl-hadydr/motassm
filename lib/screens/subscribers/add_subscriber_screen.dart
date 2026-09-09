import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/subscriber.dart';
import '../../providers/subscriber_provider.dart';

class AddSubscriberScreen extends StatefulWidget {
  const AddSubscriberScreen({super.key});

  @override
  State<AddSubscriberScreen> createState() => _AddSubscriberScreenState();
}

class _AddSubscriberScreenState extends State<AddSubscriberScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _meterController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _meterController.dispose();
    super.dispose();
  }

  Future<void> _saveSubscriber() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final subscriber = Subscriber(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      meterNumber: _meterController.text.trim(),
      createdAt: DateTime.now(),
    );

    final success = await context.read<SubscriberProvider>().addSubscriber(
      subscriber,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تمت إضافة المشترك بنجاح')));

      Navigator.pop(context);
    } else {
      final errorMessage = context.read<SubscriberProvider>().errorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'تعذر إضافة المشترك')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'إضافة مشترك',
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
                  'بيانات المشترك',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  'أدخل بيانات المشترك والعداد',
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 28),

                _buildLabel('اسم المشترك'),

                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'مثال: أحمد محمد',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال اسم المشترك';
                    }

                    if (value.trim().length < 3) {
                      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _buildLabel('رقم الهاتف'),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'مثال: 777123456',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال رقم الهاتف';
                    }

                    if (value.trim().length < 9) {
                      return 'رقم الهاتف غير صحيح';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _buildLabel('العنوان'),

                TextFormField(
                  controller: _addressController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'مثال: صنعاء - حدة',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال العنوان';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _buildLabel('رقم العداد'),

                TextFormField(
                  controller: _meterController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'مثال: M-1004',
                    prefixIcon: const Icon(Icons.electric_meter_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال رقم العداد';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveSubscriber,
                    icon:
                        _isSaving
                            ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.person_add_alt_1),
                    label: Text(_isSaving ? 'جاري الحفظ...' : 'إضافة المشترك'),
                  ),
                ),
              ],
            ),
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
