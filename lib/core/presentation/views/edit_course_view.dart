import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/presentation/controllers/course_controller.dart';
import 'package:paylog/data/models/course.dart';

class EditCourseView extends GetView<CourseController> {
  const EditCourseView({super.key});

  @override
  Widget build(BuildContext context) {
    final course = Get.arguments as Course;

    final nameController = TextEditingController(text: course.name);
    final feeController = TextEditingController(text: course.fee.toString());
    final descriptionController =
        TextEditingController(text: course.description);

    return Scaffold(
      appBar: AppBar(
        title: Text('edit_course'.tr),
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
                      // Update course
                      final updatedCourse = Course(
                        id: course.id,
                        programId: course.programId,
                        name: nameController.text,
                        fee: double.tryParse(feeController.text) ?? course.fee,
                        description: descriptionController.text,
                      )..updateTimestamp();

                      controller.updateCourse(updatedCourse);
                      Get.back();
                      Get.snackbar(
                        'Success',
                        'Course updated successfully',
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
