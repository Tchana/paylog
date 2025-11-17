import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/app/theme/app_theme.dart';
import 'package:paylog/core/presentation/controllers/member_controller.dart';
// Use the platform service factory for proper platform detection
import 'package:paylog/core/services/platform/platform_service_factory.dart';
import 'package:paylog/core/services/platform/report_service_interface.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/models/payment.dart';
import 'package:paylog/data/repositories/enrollment_repository.dart';
import 'package:paylog/data/repositories/course_repository.dart';
import 'package:intl/intl.dart';

class MemberDetailView extends GetView<MemberController> {
  const MemberDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final member = Get.arguments as Member;
    // Use the factory to create the appropriate report service
    final ReportServiceInterface reportService =
        PlatformServiceFactory.createReportService();

    // Fetch member payments every time the view is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMemberPayments(member.id);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit member
              Get.toNamed('/edit-member', arguments: member);
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
              _confirmDeleteMember(context, member);
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
              // Member info card
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
                      const SizedBox(height: 16),
                      Obx(() {
                        // Find the updated member from the controller's list
                        final updatedMember = controller.members.isNotEmpty
                            ? controller.members.firstWhere(
                                (m) => m.id == member.id,
                                orElse: () => member,
                              )
                            : member;
                        return _buildBalanceInfo(context, updatedMember);
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Payment history
              Text(
                'payment_history'.tr,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              // Record payment button moved here
              ElevatedButton.icon(
                onPressed: () async {
                  final result =
                      await Get.toNamed('/record-payment', arguments: member);
                  if (result == true) {
                    await controller.fetchMemberPayments(member.id);
                    await controller.fetchMembersByProgramId(member.programId);
                  }
                },
                icon: const Icon(Icons.add),
                label: Text('record_payment'.tr),
              ),
              const SizedBox(height: 16),
              Obx(
                () => controller.memberPayments.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.memberPayments.length,
                        itemBuilder: (context, index) {
                          final payment = controller.memberPayments[index];
                          return _buildPaymentCard(context, payment);
                        },
                      ),
              ),
              const SizedBox(height: 24),
              // Per-course summary
              Text(
                'summary'.tr,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              FutureBuilder<Widget>(
                future: _buildCourseSummary(context, member),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  }
                  if (snapshot.hasData) return snapshot.data!;
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 24),
              // Action buttons - removed back button, kept only download report
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Generate and download member report
                        try {
                          await reportService
                              .generateMemberPaymentReport(member);
                          Get.snackbar(
                            'Success',
                            'Report generated and shared successfully',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Failed to generate report: $e',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      icon: const Icon(Icons.download),
                      label: Text('download_report'.tr),
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

  Widget _buildBalanceInfo(BuildContext context, Member member) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'balance_due'.tr,
                overflow: TextOverflow.fade,
              ),
            ),
            Text(
              controller.formatCurrency(member.pendingBalance),
              style: TextStyle(
                color: member.pendingBalance > 0
                    ? AppTheme.warningColor
                    : AppTheme.successColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'account_balance'.tr,
                overflow: TextOverflow.fade,
              ),
            ),
            Text(
              controller.formatCurrency(member.accountBalance),
              style: TextStyle(
                color: member.accountBalance > 0
                    ? AppTheme.successColor
                    : AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'total_debt'.tr,
                overflow: TextOverflow.fade,
              ),
            ),
            Text(
              controller.formatCurrency(member.totalDebt),
              style: TextStyle(
                color: member.totalDebt > 0
                    ? AppTheme.errorColor
                    : AppTheme.successColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentCard(BuildContext context, Payment payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(controller.formatCurrency(payment.amount)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (payment.description != null) ...[
              Text(payment.description!),
              const SizedBox(height: 4),
            ],
            Text(
              _formatDate(payment.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (payment.autoAssignedCourses.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'auto_assigned_courses'.tr,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              ...payment.autoAssignedCourses.map((a) => Text(
                    '- ${a.courseName}: ${controller.formatCurrency(a.amountApplied)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  )),
            ],
          ],
        ),
        trailing: null,
        onTap: () {
          // Navigate to edit payment screen
          Get.toNamed('/edit-payment', arguments: payment);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.payment,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'no_payments_yet'.tr,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'record_payment'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteMember(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('delete_member'.tr),
          content:
              Text('confirm_delete_member'.trParams({'name': member.name})),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.deleteMember(member.id);
                Get.back();
              },
              child: Text(
                'delete'.tr,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper methods to format date
  String _formatDate(DateTime date) {
    final locale = Get.locale;
    final tag = locale == null
        ? 'en_US'
        : '${locale.languageCode}_${locale.countryCode ?? 'US'}';
    final formatter = DateFormat.yMMMd(tag);
    return formatter.format(date);
  }

  Future<Widget> _buildCourseSummary(BuildContext context, Member member) async {
    final enrollmentRepository = EnrollmentRepository();
    final courseRepository = CourseRepository();
    final enrollments = await enrollmentRepository.getEnrollmentsByMember(member.id);
    if (enrollments.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('no_members_enrolled'.tr),
        ),
      );
    }
    final courses = await courseRepository.getAllCourses();
    final courseMap = {for (final c in courses) c.id: c};
    return Column(
      children: enrollments.map((e) {
        final course = courseMap[e.courseId];
        final fee = course?.fee ?? 0.0;
        final paid = e.amountPaid;
        final balance = fee - paid;
        return Card(
          child: ListTile(
            title: Text(course?.name ?? 'Course'),
            subtitle: Text(
                '${'course_fee'.tr}: ${controller.formatCurrency(fee)}\n${'total_paid'.tr}: ${controller.formatCurrency(paid)}\n${'balance_due'.tr}: ${controller.formatCurrency(balance.clamp(0, double.infinity))}'),
          ),
        );
      }).toList(),
    );
  }
}
