import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/meter.dart';
import '../../providers/meter_provider.dart';
import 'add_meter_screen.dart';
import 'edit_meter_screen.dart';
import 'meter_details_screen.dart';

class MetersScreen extends StatefulWidget {
  const MetersScreen({super.key});

  @override
  State<MetersScreen> createState() => _MetersScreenState();
}

class _MetersScreenState extends State<MetersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeterProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<MeterProvider>().setSearchQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'العدادات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إدارة العدادات',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              'عرض وإدارة جميع العدادات في النظام',
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<MeterProvider>().setSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'ابحث برقم العداد أو اسم المشترك...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear_rounded),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Text(
                  '${provider.filteredMeters.length} عداد',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                FloatingActionButton.small(
                  heroTag: 'addMeter',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddMeterScreen()),
                    );
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (provider.isLoading && provider.meters.isEmpty)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (provider.errorMessage != null && provider.meters.isEmpty)
              Expanded(child: Center(child: Text(provider.errorMessage!)))
            else if (provider.filteredMeters.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.electric_meter_outlined,
                        size: 70,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'لا توجد عدادات حاليًا',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'أضف أول عداد إلى النظام',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: provider.filteredMeters.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final meter = provider.filteredMeters[index];

                    return _MeterCard(meter: meter);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MeterCard extends StatelessWidget {
  final Meter meter;

  const _MeterCard({required this.meter});

  Color _statusColor() {
    switch (meter.status) {
      case 'نشط':
        return Colors.green;

      case 'متوقف':
        return Colors.orange;

      case 'معطل':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MeterDetailsScreen(meter: meter)),
    );
  }

  void _openEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditMeterScreen(meter: meter)),
    );
  }

  Future<void> _deleteMeter(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف العداد'),
          content: Text('هل أنت متأكد من حذف العداد ${meter.meterNumber}؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    final success = await context.read<MeterProvider>().deleteMeter(meter.id);

    if (!context.mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حذف العداد بنجاح')));
    } else {
      final error = context.read<MeterProvider>().errorMessage;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'تعذر حذف العداد')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final statusColor = _statusColor();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _openDetails(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.electric_meter_rounded,
                  color: primaryColor,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meter.meterNumber,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text('المشترك: ${meter.subscriberName}'),

                    const SizedBox(height: 3),

                    Text('النوع: ${meter.type}'),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            meter.status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'details') {
                    _openDetails(context);
                  }

                  if (value == 'edit') {
                    _openEdit(context);
                  }

                  if (value == 'delete') {
                    _deleteMeter(context);
                  }
                },
                itemBuilder:
                    (context) => const [
                      PopupMenuItem(value: 'details', child: Text('التفاصيل')),
                      PopupMenuItem(value: 'edit', child: Text('تعديل')),
                      PopupMenuItem(value: 'delete', child: Text('حذف')),
                    ],
                child: const Icon(Icons.more_vert_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
