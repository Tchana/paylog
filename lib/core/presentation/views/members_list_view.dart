import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/models/program.dart';
import 'package:paylog/data/repositories/member_repository.dart';
import 'package:paylog/data/repositories/program_repository.dart';

class MembersListView extends StatelessWidget {
  const MembersListView({super.key});

  @override
  Widget build(BuildContext context) {
    final memberRepository = MemberRepository();
    final programRepository = ProgramRepository();
    return Scaffold(
      appBar: AppBar(
        title: Text('members_title'.tr),
      ),
      body: FutureBuilder<List<Member>>(
        future: memberRepository.getAllMembers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final members = snapshot.data!;
          if (members.isEmpty) {
            return Center(
              child: Text('no_members_yet'.tr),
            );
          }
          return FutureBuilder<List<Program>>(
            future: programRepository.getAllPrograms(),
            builder: (context, progSnap) {
              final programs = progSnap.data ?? [];
              final programMap = {for (final p in programs) p.id: p};
              return ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final m = members[index];
                  final program = programMap[m.programId];
                  return Card(
                    child: ListTile(
                      title: Text(m.name),
                      subtitle: Text(program?.name ?? ''),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.toNamed('/member-detail', arguments: m),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
