import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bill_provider.dart';
import '../../models/bill.dart';

class EditBillScreen extends StatefulWidget {
  final Bill bill;

  const EditBillScreen({super.key, required this.bill});

  @override
  State<EditBillScreen> createState() => _EditBillScreenState();
}

class _EditBillScreenState extends State<EditBillScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _totalController;
  late TextEditingController _paidController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _totalController = TextEditingController(
      text: widget.bill.totalAmount.toString(),
    );
    _paidController = TextEditingController(
      text: widget.bill.paidAmount.toString(),
    );
  }

  @override
  void dispose() {
    _totalController.dispose();
    _paidController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final newTotal = double.parse(_totalController.text.trim());
    final newPaid = double.parse(_paidController.text.trim());
    final newRemaining = newTotal - newPaid;

    final updatedBill = Bill(
      id: widget.bill.id,
      subscriberId: widget.bill.subscriberId,
      subscriberName: widget.bill.subscriberName,
      meterId: widget.bill.meterId,
      readingId: widget.bill.readingId,
      consumption: widget.bill.consumption,
      totalAmount: newTotal,
      paidAmount: newPaid,
      remainingAmount: newRemaining > 0 ? newRemaining : 0.0,
      issueDate: widget.bill.issueDate,
      isPaid: newRemaining <= 0,
    );

    final success = await context.read<BillProvider>().updateBill(updatedBill);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم التعديل بنجاح ✅')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تعديل الفاتورة',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _totalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'المبلغ الإجمالي',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _paidController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'المبلغ المدفوع',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    child:
                        _isSaving
                            ? const CircularProgressIndicator()
                            : const Text('حفظ التعديلات'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
