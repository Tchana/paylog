import 'package:get/get.dart';
import 'package:paylog/data/models/program.dart';
import 'package:paylog/data/repositories/program_repository.dart';

class ProgramController extends GetxController {
  final ProgramRepository _repository = ProgramRepository();

  var programs = <Program>[].obs;
  var isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    refreshPrograms();
  }

  Future<void> refreshPrograms() async {
    try {
      isLoading.value = true;
      programs.value = await _repository.getAllPrograms();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPrograms() async {
    try {
      isLoading.value = true;
      programs.value = await _repository.getAllPrograms();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProgram(Program program) async {
    await _repository.addProgram(program);
    refreshPrograms();
  }

  Future<void> updateProgram(Program program) async {
    await _repository.updateProgram(program);
    refreshPrograms();
  }

  Future<void> deleteProgram(String programId) async {
    await _repository.deleteProgram(programId);
    refreshPrograms();
  }
}
