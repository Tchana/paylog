import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paylog/core/app/theme/app_colors.dart';
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
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
                      AppColors.primary,
                      Icons.category,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'total_members'.tr,
                      Obx(() => Text(
                            '${controller.totalMembers.value}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          )),
                      AppColors.secondary,
                      Icons.people,
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
                      AppColors.success,
                      Icons.attach_money,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'total_pending'.tr,
                      Obx(() => Text(
                            controller
                                .formatCurrency(controller.totalPending.value),
                            style: Theme.of(context).textTheme.headlineMedium,
                          )),
                      AppColors.warning,
                      Icons.pending_actions,
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
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, String title, Widget value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
