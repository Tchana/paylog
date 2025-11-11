import 'package:get/get.dart';
import 'package:paylog/core/presentation/views/dashboard_view.dart';
import 'package:paylog/core/presentation/views/program_list_view.dart';
import 'package:paylog/core/presentation/views/program_detail_view.dart';
import 'package:paylog/core/presentation/views/course_detail_view.dart';
import 'package:paylog/core/presentation/views/member_detail_view.dart';
import 'package:paylog/core/presentation/views/add_program_view.dart';
import 'package:paylog/core/presentation/views/add_course_view.dart';
import 'package:paylog/core/presentation/views/add_member_view.dart';
import 'package:paylog/core/presentation/views/edit_member_view.dart';
import 'package:paylog/core/presentation/views/edit_course_view.dart';
import 'package:paylog/core/presentation/views/record_payment_view.dart';
import 'package:paylog/core/presentation/views/settings_view.dart';

class AppRoutes {
  static const String home = '/home';
  static const String programs = '/programs';
  static const String programDetail = '/program-detail';
  static const String courseDetail = '/course-detail';
  static const String memberDetail = '/member-detail';
  static const String addProgram = '/add-program';
  static const String addCourse = '/add-course';
  static const String addMember = '/add-member';
  static const String editMember = '/edit-member';
  static const String editCourse = '/edit-course';
  static const String recordPayment = '/record-payment';
  static const String settings = '/settings';
}

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const DashboardView(),
    ),
    GetPage(
      name: AppRoutes.programs,
      page: () => const ProgramListView(),
    ),
    GetPage(
      name: AppRoutes.programDetail,
      page: () => const ProgramDetailView(),
    ),
    GetPage(
      name: AppRoutes.courseDetail,
      page: () => const CourseDetailView(),
    ),
    GetPage(
      name: AppRoutes.memberDetail,
      page: () => const MemberDetailView(),
    ),
    GetPage(
      name: AppRoutes.addProgram,
      page: () => const AddProgramView(),
    ),
    GetPage(
      name: AppRoutes.addCourse,
      page: () => const AddCourseView(),
    ),
    GetPage(
      name: AppRoutes.addMember,
      page: () => const AddMemberView(),
    ),
    GetPage(
      name: AppRoutes.editMember,
      page: () => const EditMemberView(),
    ),
    GetPage(
      name: AppRoutes.editCourse,
      page: () => const EditCourseView(),
    ),
    GetPage(
      name: AppRoutes.recordPayment,
      page: () => const RecordPaymentView(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
    ),
  ];
}
