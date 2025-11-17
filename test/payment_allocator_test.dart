import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:paylog/core/services/hive_service.dart';
import 'package:paylog/core/services/payment_allocator.dart';
import 'package:paylog/data/models/course.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/models/program.dart';
import 'package:paylog/data/models/enrollment.dart';
import 'package:paylog/data/repositories/course_repository.dart';
import 'package:paylog/data/repositories/member_repository.dart';
import 'package:paylog/data/repositories/payment_repository.dart';
import 'package:paylog/data/repositories/enrollment_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  late Directory tempDir;

  group('PaymentAllocator', () {
    late CourseRepository courseRepo;
    late MemberRepository memberRepo;
    late PaymentRepository paymentRepo;
    late EnrollmentRepository enrollmentRepo;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('paylog_test_');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathProviderChannel, (methodCall) async {
        switch (methodCall.method) {
          case 'getApplicationDocumentsDirectory':
          case 'getApplicationSupportDirectory':
          case 'getTemporaryDirectory':
            return tempDir.path;
          default:
            return null;
        }
      });

      await Hive.initFlutter();
      await HiveService.initialize();
      courseRepo = CourseRepository();
      memberRepo = MemberRepository();
      paymentRepo = PaymentRepository();
      enrollmentRepo = EnrollmentRepository();
      Get.put<CourseRepository>(courseRepo);
      Get.put<MemberRepository>(memberRepo);
      Get.put<PaymentRepository>(paymentRepo);
      Get.put<EnrollmentRepository>(enrollmentRepo);
      Get.put<PaymentAllocator>(PaymentAllocator());
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathProviderChannel, null);
    });

    test('allocates payments across courses by createdAt and updates balances', () async {
      final program = Program(name: 'Bible Program');
      await HiveService.programs.put(program.id, program);

      final romans = Course(programId: program.id, name: 'Romans', fee: 4500);
      await courseRepo.addCourse(romans);
      await Future.delayed(const Duration(milliseconds: 5));
      final revelation = Course(programId: program.id, name: 'Revelation', fee: 4500);
      await courseRepo.addCourse(revelation);
      await Future.delayed(const Duration(milliseconds: 5));
      final biblical = Course(programId: program.id, name: 'Biblical Understanding', fee: 6000);
      await courseRepo.addCourse(biblical);

      final member = Member(programId: program.id, name: 'John Doe');
      await memberRepo.addMember(member);

      final enrRepo = EnrollmentRepository();
      await enrRepo.addEnrollment(Enrollment(programId: program.id, courseId: romans.id, memberId: member.id));
      await enrRepo.addEnrollment(Enrollment(programId: program.id, courseId: revelation.id, memberId: member.id));
      await enrRepo.addEnrollment(Enrollment(programId: program.id, courseId: biblical.id, memberId: member.id));

      await Get.find<PaymentAllocator>().allocateAndRecordPayment(
        memberId: member.id,
        programId: program.id,
        amount: 3000,
        date: DateTime.now(),
      );

      var enrollments = await enrRepo.getEnrollmentsByMember(member.id);
      final romansEnrollment = enrollments.firstWhere((e) => e.courseId == romans.id);
      final revelationEnrollment = enrollments.firstWhere((e) => e.courseId == revelation.id);
      final biblicalEnrollment = enrollments.firstWhere((e) => e.courseId == biblical.id);
      expect(romansEnrollment.amountPaid, 3000);
      expect(revelationEnrollment.amountPaid, 0);
      expect(biblicalEnrollment.amountPaid, 0);

      await Get.find<PaymentAllocator>().allocateAndRecordPayment(
        memberId: member.id,
        programId: program.id,
        amount: 7000,
        date: DateTime.now(),
      );

      enrollments = await enrRepo.getEnrollmentsByMember(member.id);
      final romansEnrollment2 = enrollments.firstWhere((e) => e.courseId == romans.id);
      final revelationEnrollment2 = enrollments.firstWhere((e) => e.courseId == revelation.id);
      final biblicalEnrollment2 = enrollments.firstWhere((e) => e.courseId == biblical.id);
      expect(romansEnrollment2.amountPaid, 4500);
      expect(revelationEnrollment2.amountPaid, 4500);
      expect(biblicalEnrollment2.amountPaid, 1000);

      final updatedMember = await memberRepo.getMemberById(member.id);
      expect(updatedMember?.accountBalance, 0);
      expect(updatedMember?.totalDebt, 5000);
    });
  });
}
