// presentation/widgets/program_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/app/theme/app_colors.dart';
import 'package:paylog/data/models/program.dart';

class ProgramCard extends StatelessWidget {
  final Program program;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ProgramCard({
    super.key,
    required this.program,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.primary,
          ),
        ),
        title: Text(program.name),
        subtitle: Text(
          program.description ?? 'no_description'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: onTap,
              child: Text('edit'.tr),
            ),
            PopupMenuItem(
              onTap: onDelete,
              child: Text('delete'.tr, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
