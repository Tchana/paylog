import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/presentation/controllers/course_controller.dart';
import 'package:paylog/core/presentation/controllers/member_controller.dart';
import 'package:paylog/data/models/program.dart';

class ProgramDetailView extends GetView<CourseController> {
  const ProgramDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final program = Get.arguments as Program;
    final memberController = Get.put(MemberController());

    // Fetch courses and members when the view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCoursesByProgramId(program.id);
      memberController.fetchMembersByProgramId(program.id);
    });

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(program.name),
          bottom: TabBar(
            tabs: [
              Tab(text: 'courses_title'.tr),
              Tab(text: 'members_title'.tr),
              Tab(text: 'summary'.tr),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Edit program
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
        body: TabBarView(
          children: [
            // Courses tab
            _buildCoursesTab(context, program),
            // Members tab
            _buildMembersTab(context, program, memberController),
            // Summary tab
            _buildSummaryTab(context, program),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(context, program),
      ),
    );
  }

  Widget _buildCoursesTab(BuildContext context, Program program) {
    return Obx(
      () => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : controller.courses.isEmpty
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
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.toNamed('/add-course', arguments: program);
                        },
                        icon: const Icon(Icons.add),
                        label: Text('add_course'.tr),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: controller.courses.length,
                        itemBuilder: (context, index) {
                          final course = controller.courses[index];
                          return Card(
                            child: ListTile(
                              title: Text(
                                course.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              subtitle:
                                  Text('₣${course.fee.toStringAsFixed(0)}'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                Get.toNamed('/course-detail',
                                    arguments: course);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.toNamed('/add-member', arguments: program);
                        },
                        icon: const Icon(Icons.add),
                        label: Text('add_member'.tr),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
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
                                Get.toNamed('/member-detail',
                                    arguments: member);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSummaryTab(BuildContext context, Program program) {
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
                            '${controller.courses.length}',
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
                            '${Get.find<MemberController>().members.length}',
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
        // Delete program logic would go here
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
