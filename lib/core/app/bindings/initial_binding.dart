import 'package:get/get.dart';
import 'package:paylog/core/presentation/controllers/dashboard_controller.dart';
import 'package:paylog/core/presentation/controllers/program_controller.dart';
import 'package:paylog/core/presentation/controllers/course_controller.dart';
import 'package:paylog/core/presentation/controllers/member_controller.dart';
import 'package:paylog/core/presentation/controllers/payment_controller.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
    Get.put(ProgramController());
    Get.put(CourseController());
    Get.put(MemberController());
    Get.lazyPut(() => PaymentController());
  }
}
