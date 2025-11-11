import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/presentation/controllers/program_controller.dart';
import 'package:paylog/data/models/program.dart';

class AddProgramView extends GetView<ProgramController> {
  const AddProgramView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('add_program'.tr),
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
                labelText: 'program_name'.tr,
                hintText: 'Enter program name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'program_description'.tr,
                hintText: 'Enter program description',
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
                        final program = Program(
                          name: nameController.text,
                          description: descriptionController.text,
                        );
                        controller.addProgram(program);
                        Get.back(); // Close the add program screen
                        Get.toNamed('/programs'); // Navigate to programs list
                        Get.snackbar(
                          'Success',
                          'Program added successfully',
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
