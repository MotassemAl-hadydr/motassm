import 'package:electricity_management/screens/readings/add_reading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/meter_reading.dart';
import '../../providers/meter_reading_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ReadingsScreen extends StatefulWidget {
  const ReadingsScreen({super.key});

  @override
  State<ReadingsScreen> createState() => _ReadingsScreenState();
}

class _ReadingsScreenState extends State<ReadingsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeterReadingProvider>().startListening();
    });
  }

  void _showReadingDetails(MeterReading reading) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'تفاصيل القراءة',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildDetailTile(
                  icon: Icons.electric_meter_outlined,
                  title: 'رقم العداد',
                  value: reading.meterNumber,
                ),
                _buildDetailTile(
                  icon: Icons.person_outline,
                  title: 'المشترك',
                  value: reading.subscriberName,
                ),
                _buildDetailTile(
                  icon: Icons.history,
                  title: 'القراءة السابقة',
                  value: _formatNumber(reading.previousReading),
                ),
                _buildDetailTile(
                  icon: Icons.speed,
                  title: 'القراءة الحالية',
                  value: _formatNumber(reading.currentReading),
                ),
                _buildDetailTile(
                  icon: Icons.bolt,
                  title: 'الاستهلاك',
                  value: _formatNumber(reading.consumption),
                ),
                _buildDetailTile(
                  icon: Icons.calendar_today_outlined,
                  title: 'تاريخ القراءة',
                  value: _formatDate(reading.readingDate),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteReading(MeterReading reading) async {
    final provider = context.read<MeterReadingProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف القراءة'),
          content: Text(
            'هل أنت متأكد من حذف قراءة العداد ${reading.meterNumber}؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final success = await provider.deleteReading(reading.id);

    if (!mounted) {
      return;
    }

    final error = provider.errorMessage;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'تم حذف القراءة بنجاح' : error ?? 'تعذر حذف القراءة',
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }

  Widget _buildReadingCard(MeterReading reading) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showReadingDetails(reading),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    child: const Icon(Icons.speed_rounded),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reading.meterNumber,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reading.subscriberName,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'details') {
                        _showReadingDetails(reading);
                      } else if (value == 'delete') {
                        _deleteReading(reading);
                      }
                    },
                    itemBuilder:
                        (context) => const [
                          PopupMenuItem(
                            value: 'details',
                            child: Row(
                              children: [
                                Icon(Icons.visibility_outlined),
                                SizedBox(width: 10),
                                Text('التفاصيل'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline),
                                SizedBox(width: 10),
                                Text('حذف'),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildReadingValue(
                      title: 'السابقة',
                      value: reading.previousReading,
                      icon: Icons.history,
                    ),
                  ),
                  Expanded(
                    child: _buildReadingValue(
                      title: 'الحالية',
                      value: reading.currentReading,
                      icon: Icons.speed,
                    ),
                  ),
                  Expanded(
                    child: _buildReadingValue(
                      title: 'الاستهلاك',
                      value: reading.consumption,
                      icon: Icons.bolt,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'تاريخ القراءة: ${_formatDate(reading.readingDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingValue({
    required String title,
    required double value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 3),
        Text(
          _formatNumber(value),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeterReadingProvider>();
    final readings = provider.filteredReadings;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'القراءات', // أو 'الفواتير' في شاشة الفواتير
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            // هذا الشرط سيخفي الزر إذا كان المستخدم "مدير نظام"
            if (context.watch<AuthProvider>().currentUser?.role != 'admin')
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                onPressed: () async {
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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                onChanged: provider.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'البحث برقم العداد أو اسم المشترك',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      provider.searchQuery.isNotEmpty
                          ? IconButton(
                            onPressed: () {
                              provider.setSearchQuery('');
                            },
                            icon: const Icon(Icons.clear),
                          )
                          : null,
                ),
              ),
            ),
            Expanded(
              child:
                  provider.isLoading && readings.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : readings.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                        onRefresh: () async {
                          provider.startListening();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: readings.length,
                          itemBuilder: (context, index) {
                            return _buildReadingCard(readings[index]);
                          },
                        ),
                      ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddReadingScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('إضافة قراءة'),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.speed_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            const Text(
              'لا توجد قراءات',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'لم تتم إضافة أي قراءة للعدادات حتى الآن',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
