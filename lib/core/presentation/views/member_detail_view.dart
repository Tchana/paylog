import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/app/theme/app_theme.dart';
import 'package:paylog/core/presentation/controllers/member_controller.dart';
// Use the platform service factory for proper platform detection
import 'package:paylog/core/services/platform/platform_service_factory.dart';
import 'package:paylog/core/services/platform/report_service_interface.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/models/payment.dart';
import 'package:paylog/data/repositories/course_repository.dart';

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
          onPressed: () => Get.back(),
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
                onPressed: () {
                  Get.toNamed('/record-payment', arguments: member);
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
          ],
        ),
        trailing: Text(
          _getCourseName(payment.courseId),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
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
              'no_payments_recorded'.tr,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'record_first_payment'.tr,
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

  // Helper methods to format date and get course name
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getCourseName(String? courseId) {
    if (courseId == null) return 'General Payment';
    // In a real implementation, we would fetch the course name from the repository
    // For now, we'll just return a placeholder
    return 'Course';
  }
}
