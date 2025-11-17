// Member card widget will be defined here
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/repositories/enrollment_repository.dart';
import 'package:paylog/data/repositories/course_repository.dart';

class MemberCard extends StatelessWidget {
  final Member member;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MemberCard({
    super.key,
    required this.member,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<Map<String, double>>(
              future: _computeBalances(member),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return LinearProgressIndicator(
                    backgroundColor: Colors.grey[200],
                  );
                }
                final data = snapshot.data!;
                final totalFee = data['totalFee'] ?? 0;
                final totalPaid = data['totalPaid'] ?? 0;
                final balance = (totalFee - totalPaid) - member.accountBalance;
                final pending = balance > 0 ? balance : 0;
                final progress = totalFee > 0 ? (totalPaid / totalFee).clamp(0, 1) : 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₣${pending.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.toDouble(),
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        pending > 0 ? Colors.orange : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${'total_paid'.tr}: ₣${totalPaid.toStringAsFixed(0)} • ${'balance_due'.tr}: ₣${(totalFee - totalPaid).toStringAsFixed(0)}'),
                  ],
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: onTap,
                      child: const Text('View Details'),
                    ),
                    PopupMenuItem(
                      onTap: onDelete,
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, double>> _computeBalances(Member member) async {
    final enrollmentRepository = EnrollmentRepository();
    final courseRepository = CourseRepository();
    final enrollments = await enrollmentRepository.getEnrollmentsByMember(member.id);
    final courses = await courseRepository.getAllCourses();
    final courseMap = {for (final c in courses) c.id: c};
    double totalFee = 0.0;
    double totalPaid = 0.0;
    for (final e in enrollments) {
      final course = courseMap[e.courseId];
      if (course != null) {
        totalFee += course.fee;
        totalPaid += e.amountPaid;
      }
    }
    return {
      'totalFee': totalFee,
      'totalPaid': totalPaid,
    };
  }
}
