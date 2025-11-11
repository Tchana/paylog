import 'package:hive_flutter/hive_flutter.dart';
import 'package:paylog/data/models/program.dart';
import 'package:paylog/data/models/course.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/models/payment.dart';

class HiveService {
  static late Box<Program> programs;
  static late Box<Course> courses;
  static late Box<Member> members;
  static late Box<Payment> payments;

  static Future<void> initialize() async {
    // Register adapters
    Hive.registerAdapter(ProgramAdapter());
    Hive.registerAdapter(CourseAdapter());
    Hive.registerAdapter(MemberAdapter());
    Hive.registerAdapter(PaymentAdapter());

    // Open boxes
    programs = await Hive.openBox<Program>('programs');
    courses = await Hive.openBox<Course>('courses');
    members = await Hive.openBox<Member>('members');
    payments = await Hive.openBox<Payment>('payments');
  }

  static Future<void> closeBoxes() async {
    await programs.close();
    await courses.close();
    await members.close();
    await payments.close();
  }
}
