import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/app/theme/app_theme.dart';
import 'package:paylog/core/presentation/controllers/member_controller.dart';
import 'package:paylog/core/services/report_service.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/models/payment.dart';

class MemberDetailView extends GetView<MemberController> {
  const MemberDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final member = Get.arguments as Member;
    final ReportService reportService = ReportService();

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
                            'Report generated successfully',
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
                'total_paid'.tr,
                overflow: TextOverflow.fade,
              ),
            ),
            Text(
              controller.formatCurrency(member.accountBalance),
              style: const TextStyle(
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
      child: ListTile(
        title: Text(controller.formatCurrency(payment.amount)),
        subtitle: Text(
            '${payment.date.day}/${payment.date.month}/${payment.date.year}'),
        trailing: Text(payment.description ?? ''),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          'no_payments_yet'.tr,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  void _confirmDeleteMember(BuildContext context, Member member) {
    Get.defaultDialog(
      title: 'are_you_sure'.tr,
      middleText: 'confirm_delete_member'.tr,
      textConfirm: 'delete'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteMember(member.id);
        Get.back();
        Get.back();
        Get.snackbar(
          'Success',
          'Member deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}
