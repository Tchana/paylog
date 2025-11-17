import 'package:hive_flutter/hive_flutter.dart';
import 'package:paylog/data/models/program.dart';
import 'package:paylog/data/models/course.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/models/payment.dart';
import 'package:paylog/data/models/allocation_entry.dart';
import 'package:paylog/data/models/enrollment.dart';

class HiveService {
  static late Box<Program> programs;
  static late Box<Course> courses;
  static late Box<Member> members;
  static late Box<Payment> payments;
  static late Box<Enrollment> enrollments;

  static Future<void> initialize() async {
    // Register adapters
    Hive.registerAdapter(ProgramAdapter());
    Hive.registerAdapter(CourseAdapter());
    Hive.registerAdapter(MemberAdapter());
    Hive.registerAdapter(PaymentAdapter());
    Hive.registerAdapter(AllocationEntryAdapter());
    Hive.registerAdapter(EnrollmentAdapter());

    // Open boxes
    programs = await Hive.openBox<Program>('programs');
    courses = await Hive.openBox<Course>('courses');
    members = await Hive.openBox<Member>('members');
    payments = await Hive.openBox<Payment>('payments');
    enrollments = await Hive.openBox<Enrollment>('enrollments');
  }

  static Future<void> closeBoxes() async {
    await programs.close();
    await courses.close();
    await members.close();
    await payments.close();
    await enrollments.close();
  }
}
