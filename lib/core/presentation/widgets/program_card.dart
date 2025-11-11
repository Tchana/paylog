// presentation/widgets/program_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/app/theme/app_theme.dart';
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
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.workspace_premium_outlined,
            color: AppTheme.primaryColor,
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
              child: Text('edit'.tr),
              onTap: onTap,
            ),
            PopupMenuItem(
              child: Text('delete'.tr, style: TextStyle(color: Colors.red)),
              onTap: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}