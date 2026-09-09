import 'package:flutter/material.dart';
import '../../models/bill.dart';

class BillDetailsScreen extends StatelessWidget {
  final Bill bill;

  const BillDetailsScreen({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        "${bill.issueDate.year}/${bill.issueDate.month}/${bill.issueDate.day}";

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تفاصيل الفاتورة',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Icon(
                          Icons.receipt_long,
                          size: 60,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          bill.isPaid
                              ? 'مدفوعة بالكامل'
                              : (bill.paidAmount > 0
                                  ? 'تسديد جزئي'
                                  : 'غير مدفوعة'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                bill.isPaid
                                    ? Colors.green
                                    : (bill.paidAmount > 0
                                        ? Colors.orange
                                        : Colors.red),
                          ),
                        ),
                      ),
                      const Divider(height: 32),
                      _buildDetailRow('اسم المشترك:', bill.subscriberName),
                      _buildDetailRow('تاريخ الإصدار:', dateStr),
                      _buildDetailRow(
                        'الاستهلاك:',
                        '${bill.consumption} كيلوواط',
                      ),
                      const Divider(height: 32),
                      _buildDetailRow(
                        'المبلغ الإجمالي:',
                        '${bill.totalAmount} ريال',
                        isBold: true,
                      ),
                      _buildDetailRow(
                        'المبلغ المدفوع:',
                        '${bill.paidAmount} ريال',
                        color: Colors.green,
                      ),
                      _buildDetailRow(
                        'المبلغ المتبقي:',
                        '${bill.remainingAmount} ريال',
                        color: Colors.red,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
