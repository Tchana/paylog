import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/presentation/controllers/course_controller.dart';
import 'package:paylog/data/models/course.dart';
import 'package:paylog/data/models/program.dart';

class AddCourseView extends GetView<CourseController> {
  const AddCourseView({super.key});

  @override
  Widget build(BuildContext context) {
    final program = Get.arguments as Program;
    final nameController = TextEditingController();
    final feeController = TextEditingController();
    final descriptionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('add_course'.tr),
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
                labelText: 'course_name'.tr,
                hintText: 'Enter course name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'course_fee'.tr,
                hintText: 'Enter course fee',
                prefixText: '₣',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'course_description'.tr,
                hintText: 'Enter course description',
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
                      if (nameController.text.isNotEmpty &&
                          feeController.text.isNotEmpty) {
                        final course = Course(
                          programId: program.id,
                          name: nameController.text,
                          fee: double.tryParse(feeController.text) ?? 0.0,
                          description: descriptionController.text,
                        );
                        controller.addCourse(course);
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Course added successfully',
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
