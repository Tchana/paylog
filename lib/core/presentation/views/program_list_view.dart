import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/presentation/controllers/program_controller.dart';
import 'package:paylog/data/models/program.dart';

class ProgramListView extends GetView<ProgramController> {
  const ProgramListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch programs when the view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPrograms();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('programs_title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchPrograms,
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => controller.fetchPrograms(),
                child: controller.programs.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
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
      child: ListTile(
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
}
