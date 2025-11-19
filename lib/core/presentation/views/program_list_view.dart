import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/presentation/controllers/program_controller.dart';
import 'package:paylog/data/models/program.dart';
import 'package:paylog/data/repositories/payment_repository.dart';
import 'package:paylog/data/repositories/enrollment_repository.dart';
import 'package:paylog/data/repositories/course_repository.dart';
import 'package:paylog/data/repositories/member_repository.dart';
import 'package:intl/intl.dart';

class ProgramListView extends GetView<ProgramController> {
  const ProgramListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch programs when the view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPrograms();
    });

    return Scaffold(
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => controller.fetchPrograms(),
                child: controller.programs.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                        itemCount: controller.programs.length,
                        itemBuilder: (context, index) {
                          final program = controller.programs[index];
                          return _buildProgramCard(context, program);
                        },
                      ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/add-program');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProgramCard(BuildContext context, Program program) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                program.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Text(program.description ?? ''),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.toNamed('/program-detail', arguments: program);
              },
            ),
            const SizedBox(height: 8),
            FutureBuilder<Map<String, dynamic>>(
              future: _computeProgramSummary(program),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const LinearProgressIndicator();
                }
                final data = snapshot.data!;
                final locale = Get.locale;
                final tag = locale == null
                    ? 'en_US'
                    : '${locale.languageCode}_${locale.countryCode ?? 'US'}';
                final fmt = NumberFormat.currency(locale: tag, symbol: '₣', decimalDigits: 0);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${'members_title'.tr}: ${data['members']}'),
                    Text('${'payments_title'.tr}: ${fmt.format(data['collected'] ?? 0)}'),
                    Text('${'total_pending'.tr}: ${fmt.format(data['pending'] ?? 0)}'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 64,
            color: Theme.of(context).hintColor,
          ),
          const SizedBox(height: 16),
          Text(
            'no_programs_yet'.tr,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Get.toNamed('/add-program');
            },
            child: Text('add_program'.tr),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _computeProgramSummary(Program program) async {
    final paymentRepository = PaymentRepository();
    final enrollmentRepository = EnrollmentRepository();
    final courseRepository = CourseRepository();
    final memberRepository = MemberRepository();
    final payments = await paymentRepository.getPaymentsByProgram(program.id);
    final enrollments = await enrollmentRepository.getEnrollmentsByProgram(program.id);
    final courses = await courseRepository.getAllCourses();
    final members = await memberRepository.getMembersByProgram(program.id);
    final courseMap = {for (final c in courses) c.id: c};
    double collected = 0.0;
    for (final p in payments) {
      collected += p.amount;
    }
    double pending = 0.0;
    for (final m in members) {
      final ms = enrollments.where((e) => e.memberId == m.id).toList();
      double debt = 0.0;
      for (final e in ms) {
        final c = courseMap[e.courseId];
        if (c != null) {
          final remaining = c.fee - e.amountPaid;
          if (remaining > 0) debt += remaining;
        }
      }
      final memberPending = debt - m.accountBalance;
      if (memberPending > 0) pending += memberPending;
    }
    return {
      'members': members.length,
      'collected': collected,
      'pending': pending,
    };
  }
}
