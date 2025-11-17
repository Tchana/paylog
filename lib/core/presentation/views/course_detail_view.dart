import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/presentation/controllers/course_controller.dart';
import 'package:paylog/core/presentation/controllers/member_controller.dart';
import 'package:paylog/data/models/course.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/models/enrollment.dart';
import 'package:paylog/data/repositories/enrollment_repository.dart';
import 'package:intl/intl.dart';

class CourseDetailView extends GetView<CourseController> {
  const CourseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final course = Get.arguments as Course;
    final memberController = Get.find<MemberController>();

    // Fetch data when the view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      memberController.fetchMembersByProgramId(course.programId);
      controller.fetchCourseMembers(course.id);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(course.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit course
              Get.toNamed('/edit-course', arguments: course);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
              Get.toNamed('/settings');
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
                        '${'created_on'.tr}: ${_formatDate(course.createdAt)}',
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
                            child: FutureBuilder<Widget>(
                              future: _buildMemberCourseStatus(context, course, member),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const ListTile(
                                    title: Text('Loading...'),
                                  );
                                }
                                return snapshot.data ?? ListTile(
                                  title: Text(member.name),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    Get.toNamed('/member-detail', arguments: member);
                                  },
                                );
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
                        _showAssignMembersDialog(
                            context, course, memberController);
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
        Get.back(); // Close the dialog
        Get.snackbar(
          'Success',
          'Course deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  void _showAssignMembersDialog(
      BuildContext context, Course course, MemberController memberController) {
    final selectedMembers = <Member>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'select_members'.tr,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Obx(
                    // Wrap with Obx to react to member changes
                    () => memberController.members.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('no_members_yet'.tr),
                          )
                        : Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: memberController.members.length,
                              itemBuilder: (context, index) {
                                final member = memberController.members[index];
                                return CheckboxListTile(
                                  title: Text(member.name),
                                  subtitle: Text(member.contactInfo ?? ''),
                                  value: selectedMembers.contains(member),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedMembers.add(member);
                                      } else {
                                        selectedMembers.remove(member);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text('cancel'.tr),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Assign selected members to course
                              _assignMembersToCourse(
                                  course, selectedMembers.toList());
                              Get.back();
                              Get.snackbar(
                                'Success',
                                'Members assigned to course successfully',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                            child: Text('done'.tr),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _assignMembersToCourse(Course course, List<Member> members) {
    // Assign selected members to course
    controller.assignMembersToCourse(course, members);
  }

  String _formatDate(DateTime date) {
    final locale = Get.locale;
    final tag = locale == null
        ? 'en_US'
        : '${locale.languageCode}_${locale.countryCode ?? 'US'}';
    final formatter = DateFormat.yMMMd(tag);
    return formatter.format(date);
  }

  Future<Widget> _buildMemberCourseStatus(
      BuildContext context, Course course, Member member) async {
    final enrollmentRepository = EnrollmentRepository();
    final enrollments = await enrollmentRepository.getEnrollmentsByCourse(course.id);
    final enrollment = enrollments.firstWhere(
      (e) => e.memberId == member.id,
      orElse: () => Enrollment(programId: course.programId, courseId: course.id, memberId: member.id),
    );
    final paid = enrollment.amountPaid;
    final balance = course.fee - paid;
    return ListTile(
      title: Text(member.name),
      subtitle: Text(
        'Paid: ₣${paid.toStringAsFixed(0)} • Owes: ₣${balance.clamp(0, double.infinity).toStringAsFixed(0)}',
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Get.toNamed('/member-detail', arguments: member);
      },
    );
  }
}
