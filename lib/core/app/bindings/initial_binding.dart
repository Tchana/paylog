import 'package:get/get.dart';
import 'package:paylog/core/presentation/controllers/dashboard_controller.dart';
import 'package:paylog/core/presentation/controllers/program_controller.dart';
import 'package:paylog/core/presentation/controllers/course_controller.dart';
import 'package:paylog/core/presentation/controllers/member_controller.dart';
import 'package:paylog/core/presentation/controllers/payment_controller.dart';
import 'package:paylog/data/repositories/course_repository.dart';
import 'package:paylog/data/repositories/member_repository.dart';
import 'package:paylog/data/repositories/payment_repository.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
    Get.put(ProgramController());
    Get.put(CourseRepository()); // Register CourseRepository
    Get.put(MemberRepository()); // Register MemberRepository
    Get.put(PaymentRepository()); // Register PaymentRepository
    Get.put(CourseController());
    Get.put(MemberController());
    Get.lazyPut(() => PaymentController());
  }
}
