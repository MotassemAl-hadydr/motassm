import 'package:flutter/material.dart';

import '../../models/meter.dart';
import 'edit_meter_screen.dart';

class MeterDetailsScreen extends StatelessWidget {
  final Meter meter;

  const MeterDetailsScreen({super.key, required this.meter});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تفاصيل العداد',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'تعديل العداد',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditMeterScreen(meter: meter),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.electric_meter_rounded,
                size: 52,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              meter.meterNumber,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              meter.subscriberName,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 28),

            _buildInfoCard(
              context,
              icon: Icons.electric_meter_outlined,
              title: 'رقم العداد',
              value: meter.meterNumber,
            ),

            _buildInfoCard(
              context,
              icon: Icons.person_outline,
              title: 'المشترك',
              value: meter.subscriberName,
            ),

            _buildInfoCard(
              context,
              icon: Icons.category_outlined,
              title: 'نوع العداد',
              value: meter.type,
            ),

            _buildInfoCard(
              context,
              icon: Icons.power_settings_new_outlined,
              title: 'حالة العداد',
              value: meter.status,
            ),

            _buildInfoCard(
              context,
              icon: Icons.calendar_today_outlined,
              title: 'تاريخ الإضافة',
              value: _formatDate(meter.createdAt),
            ),

            _buildInfoCard(
              context,
              icon: Icons.fingerprint,
              title: 'معرف العداد',
              value: meter.id,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditMeterScreen(meter: meter),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('تعديل بيانات العداد'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(value),
        ),
      ),
    );
  }
}
