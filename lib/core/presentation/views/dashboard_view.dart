import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/app/theme/app_theme.dart';
import 'package:paylog/core/presentation/controllers/dashboard_controller.dart';
import 'package:paylog/data/models/member.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('dashboard_title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
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
              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'total_programs'.tr,
                      Obx(() => Text(
                            '${controller.totalPrograms.value}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          )),
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'total_members'.tr,
                      Obx(() => Text(
                            '${controller.totalMembers.value}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          )),
                      AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Create program button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed('/add-program');
                      },
                      icon: const Icon(Icons.add),
                      label: Text('add_program'.tr),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'total_collected'.tr,
                      Obx(() => Text(
                            controller.formatCurrency(
                                controller.totalCollected.value),
                            style: Theme.of(context).textTheme.headlineMedium,
                          )),
                      AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'total_pending'.tr,
                      Obx(() => Text(
                            controller
                                .formatCurrency(controller.totalPending.value),
                            style: Theme.of(context).textTheme.headlineMedium,
                          )),
                      AppTheme.warningColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Members with pending balance
              Text(
                'most_pending'.tr,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Obx(
                () => controller.membersWithPendingBalance.isEmpty
                    ? _buildEmptyState(context, 'no_members_yet'.tr)
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.membersWithPendingBalance.length,
                        itemBuilder: (context, index) {
                          final member =
                              controller.membersWithPendingBalance[index];
                          return Card(
                            child: ListTile(
                              title: Text(member.name),
                              subtitle: Text(
                                  '${'pending_amount'.tr}: ${controller.formatCurrency(member.pendingBalance)}'),
                              trailing: Text(
                                controller
                                    .formatCurrency(member.pendingBalance),
                                style: const TextStyle(
                                  color: AppTheme.warningColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 32),
              // Recent payments
              Text(
                'recent_payments'.tr,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Obx(
                () => controller.recentPayments.isEmpty
                    ? _buildEmptyState(context, 'no_payments_yet'.tr)
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.recentPayments.length,
                        itemBuilder: (context, index) {
                          final payment = controller.recentPayments[index];
                          return Card(
                            child: ListTile(
                              title: Text(
                                  controller.formatCurrency(payment.amount)),
                              subtitle: Text(
                                  '${payment.date.day}/${payment.date.month}/${payment.date.year}'),
                              trailing: FutureBuilder<Member?>(
                                future:
                                    controller.getMemberById(payment.memberId),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    return Text(snapshot.data!.name);
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, String title, Widget value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                  ),
            ),
            const SizedBox(height: 8),
            value,
          ],
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
}
