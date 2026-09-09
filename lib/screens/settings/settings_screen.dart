import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

// الاستيرادات الجديدة الخاصة بالمصادقة والشاشات
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // وضع السعر الحالي داخل الحقل عند فتح الشاشة
    final currentPrice = context.read<SettingsProvider>().pricePerKwh;
    _priceController.text = currentPrice.toString();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'الإعدادات',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          // تمت إضافة ScrollView لتجنب مشكلة الشاشة الصغيرة
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------- قسم إعدادات الفواتير -----------------
              const Text(
                'إعدادات الفواتير',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'سعر الكيلوواط (ريال)',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final newPrice = double.tryParse(
                      _priceController.text.trim(),
                    );
                    if (newPrice != null && newPrice > 0) {
                      context.read<SettingsProvider>().updatePrice(newPrice);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم حفظ السعر بنجاح 💾')),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('يرجى إدخال سعر صحيح')),
                      );
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ التعديلات'),
                ),
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),

              // ----------------- قسم إدارة النظام -----------------
              const Text(
                'إدارة النظام',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 1. زر إضافة موظف جديد
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue.shade200),
                ),
                tileColor: Colors.blue.shade50,
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.person_add_alt_1,
                    color: Colors.blue.shade700,
                  ),
                ),
                title: const Text(
                  'إضافة موظف جديد',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
              ),

              const SizedBox(height: 16),

              // 2. زر تسجيل الخروج
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.shade200),
                ),
                tileColor: Colors.red.shade50,
                leading: CircleAvatar(
                  backgroundColor: Colors.red.shade100,
                  child: Icon(Icons.logout, color: Colors.red.shade700),
                ),
                title: Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
