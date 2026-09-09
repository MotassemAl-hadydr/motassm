import 'package:electricity_management/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/subscriber_provider.dart';
import '../../providers/meter_provider.dart';
import '../../providers/meter_reading_provider.dart';
import '../../providers/bill_provider.dart';
import '../settings/settings_screen.dart';
// استيراد شاشة إضافة موظف

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillProvider>().fetchBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    // جلب البيانات من المزودات
    final subscribersCount =
        context.watch<SubscriberProvider>().subscribers.length;
    final metersCount = context.watch<MeterProvider>().meters.length;
    final readingsCount = context.watch<MeterReadingProvider>().readings.length;
    final bills = context.watch<BillProvider>().bills;

    // حساب الإحصائيات المالية والاستهلاك
    int paidBillsCount = 0;
    int unpaidBillsCount = 0;
    double totalConsumption = 0;
    double totalAmounts = 0;
    double collectedAmounts = 0;
    double remainingAmounts = 0;

    for (var bill in bills) {
      totalConsumption += bill.consumption;
      totalAmounts += bill.totalAmount;
      collectedAmounts += bill.paidAmount;
      remainingAmounts += bill.remainingAmount;

      if (bill.isPaid) {
        paidBillsCount++;
      } else {
        unpaidBillsCount++;
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'لوحة التحكم',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await context.read<BillProvider>().fetchBills();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'البيانات الأساسية',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildMiniStat(
                    'المشتركين',
                    subscribersCount.toString(),
                    Icons.people_rounded,
                    Colors.blue,
                  ),
                  _buildMiniStat(
                    'العدادات',
                    metersCount.toString(),
                    Icons.electric_meter_rounded,
                    Colors.indigo,
                  ),
                  _buildMiniStat(
                    'القراءات',
                    readingsCount.toString(),
                    Icons.speed_rounded,
                    Colors.orange,
                  ),
                  _buildMiniStat(
                    'إجمالي الاستهلاك',
                    '$totalConsumption ك.و',
                    Icons.bolt_rounded,
                    Colors.amber,
                  ),
                ],
              ),

              const Divider(height: 32),

              const Text(
                'حالة الفواتير',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStat(
                      'مدفوعة',
                      paidBillsCount.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMiniStat(
                      'غير مدفوعة',
                      unpaidBillsCount.toString(),
                      Icons.cancel,
                      Colors.red,
                    ),
                  ),
                ],
              ),

              const Divider(height: 32),

              const Text(
                'الملخص المالي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildFinancialCard(
                'إجمالي المبالغ',
                totalAmounts,
                Colors.blue.shade50,
                Colors.blue.shade700,
                Icons.account_balance_wallet,
              ),
              const SizedBox(height: 12),
              _buildFinancialCard(
                'المبالغ المحصلة',
                collectedAmounts,
                Colors.green.shade50,
                Colors.green.shade700,
                Icons.payments,
              ),
              const SizedBox(height: 12),
              _buildFinancialCard(
                'الديون المتبقية',
                remainingAmounts,
                Colors.red.shade50,
                Colors.red.shade700,
                Icons.money_off,
              ),

              const SizedBox(
                height: 80,
              ), // مساحة إضافية في الأسفل حتى لا يغطي الزر العائم على البيانات
            ],
          ),
        ),

        // الزر العائم الخاص بالمدير لإضافة الموظفين
        // الزر العائم المزدوج (تسجيل خروج + إضافة موظف)
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min, // لعدم أخذ عرض الشاشة بالكامل
          children: [
            // 1. زر تسجيل الخروج (سيكون في الجهة اليمنى لأن التطبيق RTL)
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard(
    String title,
    double amount,
    Color bgColor,
    Color textColor,
    IconData icon,
  ) {
    return Card(
      elevation: 1,
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(icon, color: textColor),
        ),
        title: Text(
          title,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        ),
        trailing: Text(
          '$amount ريال',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
