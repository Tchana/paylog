import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/presentation/controllers/member_controller.dart';
import 'package:paylog/data/models/member.dart';

class EditMemberView extends GetView<MemberController> {
  const EditMemberView({super.key});

  @override
  Widget build(BuildContext context) {
    final member = Get.arguments as Member;

    final nameController = TextEditingController(text: member.name);
    final contactController = TextEditingController(text: member.contactInfo);
    final debtController =
        TextEditingController(text: member.totalDebt.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text('edit_member'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'member_name'.tr,
                hintText: 'Enter member name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contactController,
              decoration: InputDecoration(
                labelText: 'member_contact'.tr,
                hintText: 'Enter contact information',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: debtController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'member_debt'.tr,
                hintText: 'Enter initial debt amount',
                prefixText: '₣',
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
                      // Update member
                      final updatedMember = Member(
                        id: member.id,
                        programId: member.programId,
                        name: nameController.text,
                        contactInfo: contactController.text,
                        accountBalance: member.accountBalance,
                        totalDebt: double.tryParse(debtController.text) ??
                            member.totalDebt,
                      )..updateTimestamp();

                      controller.updateMember(updatedMember);
                      Get.back();
                      Get.snackbar(
                        'Success',
                        'Member updated successfully',
                        snackPosition: SnackPosition.BOTTOM,
                      );
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
