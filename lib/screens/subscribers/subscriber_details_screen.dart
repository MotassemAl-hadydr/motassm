import 'package:flutter/material.dart';

import '../../models/subscriber.dart';

class SubscriberDetailsScreen extends StatelessWidget {
  final Subscriber subscriber;

  const SubscriberDetailsScreen({super.key, required this.subscriber});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تفاصيل المشترك',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // بطاقة التعريف
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      subscriber.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'مشترك في نظام إدارة الكهرباء',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'بيانات المشترك',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 14),

              _InfoCard(
                icon: Icons.person_outline_rounded,
                title: 'اسم المشترك',
                value: subscriber.name,
              ),

              _InfoCard(
                icon: Icons.phone_outlined,
                title: 'رقم الهاتف',
                value: subscriber.phone,
              ),

              _InfoCard(
                icon: Icons.location_on_outlined,
                title: 'العنوان',
                value: subscriber.address,
              ),

              _InfoCard(
                icon: Icons.electric_meter_outlined,
                title: 'رقم العداد',
                value: subscriber.meterNumber,
              ),

              _InfoCard(
                icon: Icons.calendar_month_outlined,
                title: 'تاريخ الإضافة',
                value:
                    subscriber.createdAt != null
                        ? _formatDate(subscriber.createdAt!)
                        : 'غير محدد',
              ),

              _InfoCard(
                icon: Icons.fingerprint_rounded,
                title: 'معرف المشترك',
                value: subscriber.id,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('العودة إلى المشتركين'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: primaryColor),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
