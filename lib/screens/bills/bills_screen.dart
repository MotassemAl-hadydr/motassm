import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bill_provider.dart';
import '../../models/bill.dart';
import 'bill_details_screen.dart';
import 'edit_bill_screen.dart';

// الاستيرادات الجديدة الخاصة بتسجيل الخروج
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillProvider>().fetchBills();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            // شريط البحث
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'ابحث باسم المشترك...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ),

            Expanded(
              child: Consumer<BillProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.errorMessage != null) {
                    return Center(
                      child: Text(
                        provider.errorMessage!,
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                    );
                  }

                  // تصفية الفواتير بناءً على البحث
                  final filteredBills =
                      provider.bills.where((bill) {
                        return bill.subscriberName.contains(_searchQuery);
                      }).toList();

                  if (filteredBills.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد فواتير مطابقة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredBills.length,
                    itemBuilder: (context, index) {
                      final bill = filteredBills[index];
                      return _buildBillCard(context, bill, provider);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillCard(
    BuildContext context,
    Bill bill,
    BillProvider provider,
  ) {
    final dateStr =
        "${bill.issueDate.year}/${bill.issueDate.month}/${bill.issueDate.day}";

    String statusText;
    Color statusColor;
    Color bgColor;

    if (bill.isPaid) {
      statusText = 'مكتملة';
      statusColor = Colors.green.shade700;
      bgColor = Colors.green.shade50;
    } else if (bill.paidAmount > 0) {
      statusText = 'تسديد جزئي';
      statusColor = Colors.orange.shade700;
      bgColor = Colors.orange.shade50;
    } else {
      statusText = 'غير مدفوعة';
      statusColor = Colors.red.shade700;
      bgColor = Colors.red.shade50;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // الانتقال لشاشة التفاصيل
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BillDetailsScreen(bill: bill)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.subscriberName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'التاريخ: $dateStr',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'الاستهلاك: ${bill.consumption} كيلوواط',
                          style: TextStyle(
                            color:
                                Colors.blue.shade700, // لون أزرق مميز للاستهلاك
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // قائمة التعديل والحذف
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        // الانتقال لشاشة التعديل
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditBillScreen(bill: bill),
                          ),
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirm(context, bill.id, provider);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('تعديل'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'حذف',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAmountColumn(
                    'الإجمالي',
                    bill.totalAmount,
                    Colors.blue.shade700,
                  ),
                  _buildAmountColumn(
                    'المدفوع',
                    bill.paidAmount,
                    Colors.green.shade700,
                  ),
                  _buildAmountColumn(
                    'المتبقي',
                    bill.remainingAmount,
                    Colors.red.shade700,
                  ),
                ],
              ),
              if (!bill.isPaid) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                        () => _showPaymentDialog(context, bill, provider),
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('تسجيل دفعة مالية'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountColumn(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          '$amount',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirm(
    BuildContext context,
    String billId,
    BillProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('تأكيد الحذف'),
              content: const Text('هل أنت متأكد من حذف هذه الفاتورة نهائياً؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final success = await provider.deleteBill(billId);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم الحذف بنجاح')),
                      );
                    }
                  },
                  child: const Text(
                    'حذف',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showPaymentDialog(
    BuildContext context,
    Bill bill,
    BillProvider provider,
  ) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (ctx) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text(
                'تسجيل دفعة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المبلغ المتبقي: ${bill.remainingAmount} ريال',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'المبلغ المدفوع',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى إدخال المبلغ';
                        }
                        final amount = double.tryParse(value.trim());
                        if (amount == null || amount <= 0) {
                          return 'أدخل مبلغاً صحيحاً';
                        }
                        if (amount > bill.remainingAmount) {
                          return 'المبلغ يتجاوز المتبقي!';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final amount = double.parse(controller.text.trim());
                      Navigator.pop(ctx);
                      await provider.recordPayment(bill.id, amount);
                    }
                  },
                  child: const Text('حفظ الدفعة'),
                ),
              ],
            ),
          ),
    );
  }
}
