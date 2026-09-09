import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/subscriber.dart';
import '../../providers/subscriber_provider.dart';

class EditSubscriberScreen extends StatefulWidget {
  final Subscriber subscriber;

  const EditSubscriberScreen({super.key, required this.subscriber});

  @override
  State<EditSubscriberScreen> createState() => _EditSubscriberScreenState();
}

class _EditSubscriberScreenState extends State<EditSubscriberScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _meterController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.subscriber.name);

    _phoneController = TextEditingController(text: widget.subscriber.phone);

    _addressController = TextEditingController(text: widget.subscriber.address);

    _meterController = TextEditingController(
      text: widget.subscriber.meterNumber,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _meterController.dispose();

    super.dispose();
  }

  Future<void> _updateSubscriber() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updatedSubscriber = Subscriber(
      id: widget.subscriber.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      meterNumber: _meterController.text.trim(),
      createdAt: widget.subscriber.createdAt,
    );

    final success = await context.read<SubscriberProvider>().updateSubscriber(
      updatedSubscriber,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تعديل بيانات المشترك بنجاح')),
      );

      Navigator.pop(context);
    } else {
      final errorMessage = context.read<SubscriberProvider>().errorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'تعذر تعديل بيانات المشترك')),
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
            'تعديل المشترك',
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
                  'تعديل بيانات المشترك',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  'قم بتعديل البيانات المطلوبة ثم احفظ التغييرات',
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 28),

                _label('اسم المشترك'),

                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,

                  decoration: InputDecoration(
                    hintText: 'اسم المشترك',
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

                _label('رقم الهاتف'),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,

                  decoration: InputDecoration(
                    hintText: 'رقم الهاتف',
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

                _label('العنوان'),

                TextFormField(
                  controller: _addressController,
                  textInputAction: TextInputAction.next,

                  decoration: InputDecoration(
                    hintText: 'العنوان',
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

                _label('رقم العداد'),

                TextFormField(
                  controller: _meterController,
                  textInputAction: TextInputAction.done,

                  decoration: InputDecoration(
                    hintText: 'رقم العداد',
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
                    onPressed: _isSaving ? null : _updateSubscriber,

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
                            : const Icon(Icons.save_rounded),

                    label: Text(
                      _isSaving ? 'جاري الحفظ...' : 'حفظ التعديلات',

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}
