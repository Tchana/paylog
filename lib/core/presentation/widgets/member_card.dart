// Member card widget will be defined here
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/data/models/member.dart';

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
      child: ListTile(
        title: Text(
          member.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '₣${member.totalBalanceDue.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: member.hasPendingBalance ? 0.7 : 0.3,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                member.hasPendingBalance ? Colors.orange : Colors.green,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('View Details'),
              onTap: onTap,
            ),
            PopupMenuItem(
              child: const Text('Delete'),
              onTap: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
