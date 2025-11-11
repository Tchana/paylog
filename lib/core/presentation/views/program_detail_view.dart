import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/presentation/controllers/program_controller.dart';
import 'package:paylog/core/presentation/controllers/course_controller.dart';
import 'package:paylog/core/presentation/controllers/member_controller.dart';
import 'package:paylog/data/models/program.dart';

class ProgramDetailView extends GetView<ProgramController> {
  const ProgramDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final program = Get.arguments as Program;
    final courseController = Get.find<CourseController>();
    final memberController = Get.find<MemberController>();

    // Fetch data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      courseController.fetchCoursesByProgramId(program.id);
      memberController.fetchMembersByProgramId(program.id);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(program.name),
        actions: [
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
              _confirmDeleteProgram(context, program);
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'summary'.tr),
                Tab(text: 'courses_title'.tr),
                Tab(text: 'members_title'.tr),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSummaryTab(context, program, memberController),
                  _buildCoursesTab(context, program, courseController),
                  _buildMembersTab(context, program, memberController),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context, program),
    );
  }

  Widget _buildCoursesTab(BuildContext context, Program program,
      CourseController courseController) {
    return Obx(
      () => courseController.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : courseController.courses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: Theme.of(context).hintColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'no_courses_yet'.tr,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          Get.toNamed('/add-course', arguments: program);
                        },
                        child: Text('add_course'.tr),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: courseController.courses.length,
                  itemBuilder: (context, index) {
                    final course = courseController.courses[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          course.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        subtitle: Text('₣${course.fee.toStringAsFixed(0)}'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Get.toNamed('/course-detail', arguments: course);
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildMembersTab(BuildContext context, Program program,
      MemberController memberController) {
    return Obx(
      () => memberController.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : memberController.members.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 64,
                        color: Theme.of(context).hintColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'no_members_yet'.tr,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          Get.toNamed('/add-member', arguments: program);
                        },
                        child: Text('add_member'.tr),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: memberController.members.length,
                  itemBuilder: (context, index) {
                    final member = memberController.members[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          member.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        subtitle: Text(member.contactInfo ?? ''),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Get.toNamed('/member-detail', arguments: member);
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildSummaryTab(BuildContext context, Program program,
      MemberController memberController) {
    final courseController = Get.find<CourseController>();

    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (program.description != null) ...[
                      const SizedBox(height: 8),
                      Text(program.description!),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      '${'created_on'.tr}: ${program.createdAt.day}/${program.createdAt.month}/${program.createdAt.year}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Summary statistics
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '${courseController.courses.length}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text('courses_title'.tr),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '${memberController.members.length}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text('members_title'.tr),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, Program program) {
    return FloatingActionButton(
      onPressed: () {
        // Show options to add course or member
        _showAddOptions(context, program);
      },
      child: const Icon(Icons.add),
    );
  }

  void _showAddOptions(BuildContext context, Program program) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.school),
                title: Text('add_course'.tr),
                onTap: () {
                  Get.back();
                  Get.toNamed('/add-course', arguments: program);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text('add_member'.tr),
                onTap: () {
                  Get.back();
                  Get.toNamed('/add-member', arguments: program);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteProgram(BuildContext context, Program program) {
    Get.defaultDialog(
      title: 'are_you_sure'.tr,
      middleText: 'confirm_delete_program'.tr,
      textConfirm: 'delete'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteProgram(program.id);
        Get.back();
        Get.back();
        Get.snackbar(
          'Success',
          'Program deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}
