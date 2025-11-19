import 'package:get/get.dart';
import 'package:paylog/core/presentation/controllers/dashboard_controller.dart';
import 'package:paylog/core/presentation/controllers/program_controller.dart';
import 'package:paylog/core/presentation/controllers/course_controller.dart';
import 'package:paylog/core/presentation/controllers/member_controller.dart';
import 'package:paylog/core/presentation/controllers/payment_controller.dart';
import 'package:paylog/core/presentation/controllers/main_layout_controller.dart';
import 'package:paylog/core/presentation/controllers/analysis_controller.dart';
import 'package:paylog/data/repositories/course_repository.dart';
import 'package:paylog/data/repositories/member_repository.dart';
import 'package:paylog/data/repositories/payment_repository.dart';
import 'package:paylog/data/repositories/enrollment_repository.dart';
import 'package:paylog/data/repositories/program_repository.dart';
import 'package:paylog/core/services/payment_allocator.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainLayoutController());
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => AnalysisController());
    Get.put(ProgramController());
    Get.put(ProgramRepository()); // Register ProgramRepository
    Get.put(CourseRepository()); // Register CourseRepository
    Get.put(MemberRepository()); // Register MemberRepository
    Get.put(PaymentRepository()); // Register PaymentRepository
    Get.put(EnrollmentRepository()); // Register EnrollmentRepository
    Get.put(PaymentAllocator()); // Register PaymentAllocator
    Get.put(CourseController());
    Get.put(MemberController());
    Get.put(PaymentController()); // Register PaymentController as a singleton
  }
}
