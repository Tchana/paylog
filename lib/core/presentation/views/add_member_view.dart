import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/presentation/controllers/member_controller.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/models/program.dart';

class AddMemberView extends GetView<MemberController> {
  const AddMemberView({super.key});

  @override
  Widget build(BuildContext context) {
    final program = Get.arguments as Program;
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final debtController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('add_member'.tr),
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
                      if (nameController.text.isNotEmpty) {
                        final member = Member(
                          programId: program.id,
                          name: nameController.text,
                          contactInfo: contactController.text,
                          totalDebt:
                              double.tryParse(debtController.text) ?? 0.0,
                        );
                        controller.addMember(member);
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Member added successfully',
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
