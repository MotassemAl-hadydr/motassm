import 'package:electricity_management/models/subscriber.dart';
import 'package:electricity_management/screens/subscribers/edit_subscriber_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/subscriber_provider.dart';
import 'add_subscriber_screen.dart';
import 'subscriber_details_screen.dart';

class SubscribersScreen extends StatefulWidget {
  const SubscribersScreen({super.key});

  @override
  State<SubscribersScreen> createState() => _SubscribersScreenState();
}

class _SubscribersScreenState extends State<SubscribersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriberProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<SubscriberProvider>().setSearchQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubscriberProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المشتركين',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إدارة المشتركين',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              'عرض وإدارة جميع المشتركين في النظام',
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            // البحث
            TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<SubscriberProvider>().setSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'ابحث عن مشترك...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear_rounded),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // عدد المشتركين وزر الإضافة
            Row(
              children: [
                Text(
                  '${provider.filteredSubscribers.length} مشترك',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                FloatingActionButton.small(
                  heroTag: 'addSubscriber',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddSubscriberScreen(),
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // تحميل البيانات
            if (provider.isLoading && provider.subscribers.isEmpty)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            // ظهور الخطأ
            else if (provider.errorMessage != null &&
                provider.subscribers.isEmpty)
              Expanded(child: Center(child: Text(provider.errorMessage!)))
            // لا يوجد مشتركين
            else if (provider.filteredSubscribers.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 70,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'لا يوجد مشتركون حاليًا',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            // القائمة
            else
              Expanded(
                child: ListView.separated(
                  itemCount: provider.filteredSubscribers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final subscriber = provider.filteredSubscribers[index];

                    return _SubscriberCard(subscriber: subscriber);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SubscriberCard extends StatelessWidget {
  final Subscriber subscriber;

  const _SubscriberCard({required this.subscriber});

  Future<void> _showDeleteDialog(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'حذف المشترك',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل أنت متأكد من حذف المشترك '
            '"${subscriber.name}"؟\n\n'
            'لا يمكن التراجع عن هذه العملية.',
          ),
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

    if (shouldDelete == true && context.mounted) {
      final success = await context.read<SubscriberProvider>().removeSubscriber(
        subscriber.id,
      );

      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم حذف المشترك بنجاح')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر حذف المشترك')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
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
              child: Icon(Icons.person_rounded, color: primaryColor, size: 28),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscriber.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text('عداد: ${subscriber.meterNumber}'),

                  const SizedBox(height: 3),

                  Text(subscriber.phone),

                  const SizedBox(height: 3),

                  Text(subscriber.address),
                ],
              ),
            ),

            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'details') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              SubscriberDetailsScreen(subscriber: subscriber),
                    ),
                  );
                }
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => EditSubscriberScreen(subscriber: subscriber),
                    ),
                  );
                }

                if (value == 'delete') {
                  await _showDeleteDialog(context);
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
    );
  }
}
