import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/presentation/controllers/member_controller.dart';
import 'package:paylog/core/presentation/controllers/payment_controller.dart';
import 'package:paylog/data/models/member.dart';

class RecordPaymentView extends GetView<PaymentController> {
  const RecordPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final member = Get.arguments as Member;
    final memberController = Get.find<MemberController>();

    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('record_payment'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (member.contactInfo != null) ...[
                      const SizedBox(height: 8),
                      Text(member.contactInfo!),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '${'account_balance'.tr}: ${memberController.formatCurrency(member.accountBalance)}',
                      style: TextStyle(
                        color: member.accountBalance > 0
                            ? Colors.green
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'payment_amount'.tr,
                hintText: 'Enter payment amount',
                prefixText: '₣',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'payment_description'.tr,
                hintText: 'Enter payment description',
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('cancel'.tr),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (amountController.text.isNotEmpty) {
                        final amount =
                            double.tryParse(amountController.text) ?? 0.0;
                        controller.recordPayment(
                          memberId: member.id,
                          amount: amount,
                          date: DateTime.now(),
                          description: descriptionController.text,
                          programId: member.programId,
                        );
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'payment_recorded_success'.trParams({
                            'name': member.name,
                            'amount': memberController.formatCurrency(amount)
                          }),
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    child: Text('save'.tr),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
