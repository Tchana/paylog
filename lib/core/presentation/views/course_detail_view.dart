import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/presentation/controllers/course_controller.dart';
import 'package:paylog/data/models/course.dart';

class CourseDetailView extends GetView<CourseController> {
  const CourseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final course = Get.arguments as Course;

    return Scaffold(
      appBar: AppBar(
        title: Text(course.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit course
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _confirmDeleteCourse(context, course);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (course.description != null) ...[
                        const SizedBox(height: 8),
                        Text(course.description!),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        '₣${course.fee.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${'created_on'.tr}: ${course.createdAt.day}/${course.createdAt.month}/${course.createdAt.year}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Members enrolled in this course
              Text(
                'enrolled_members'.tr,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Obx(
                () => controller.courseMembers.isEmpty
                    ? _buildEmptyState(context, 'no_members_enrolled'.tr)
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.courseMembers.length,
                        itemBuilder: (context, index) {
                          final member = controller.courseMembers[index];
                          return Card(
                            child: ListTile(
                              title: Text(member.name),
                              subtitle: Text(member.contactInfo ?? ''),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                Get.toNamed('/member-detail',
                                    arguments: member);
                              },
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Assign members to course
                      },
                      icon: const Icon(Icons.group_add),
                      label: Text('assign_members'.tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  void _confirmDeleteCourse(BuildContext context, Course course) {
    Get.defaultDialog(
      title: 'are_you_sure'.tr,
      middleText: 'confirm_delete_course'.tr,
      textConfirm: 'delete'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteCourse(course.id);
        Get.back();
        Get.back();
        Get.snackbar(
          'Success',
          'Course deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}
