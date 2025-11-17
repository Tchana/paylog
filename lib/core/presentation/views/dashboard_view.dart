import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paylog/core/app/theme/app_theme.dart';
import 'package:paylog/core/presentation/controllers/dashboard_controller.dart';
import 'package:paylog/data/models/member.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> navigateAndRefresh(String route) async {
      final navigation = Get.toNamed(route);
      if (navigation != null) {
        await navigation;
      }
      await controller.loadDashboardData();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('dashboard_title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              navigateAndRefresh('/settings');
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    navigateAndRefresh('/programs');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: EdgeInsets.zero,
                    textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                  child: Text('view_all_programs'.tr),
                ),
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
                              subtitle: Text(_formatDate(payment.date)),
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateAndRefresh('/add-program');
        },
        child: const Icon(Icons.add),
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

  String _formatDate(DateTime date) {
    final locale = Get.locale;
    final tag = locale == null
        ? 'en_US'
        : '${locale.languageCode}_${locale.countryCode ?? 'US'}';
    final formatter = DateFormat.yMMMd(tag);
    return formatter.format(date);
  }
}
