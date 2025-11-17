## Overview

* Implement PayLog with automatic payment allocation across courses using Flutter, GetX, and Hive.

* Align existing codebase to the requested logic: programs, courses, participants, payments with auto-assigned allocations, bilingual support (EN/FR), local storage, and PDF reports.

## Current Codebase Snapshot

* Entry: `lib/main.dart:11-50` initializes Hive and GetMaterialApp with translations and routes.

* Storage: `lib/core/services/hive_service.dart:13-25` registers adapters and opens `programs`, `courses`, `members`, `payments` boxes.

* Models: `lib/data/models/{program.dart,course.dart,member.dart,payment.dart}` exist; member holds `accountBalance` and `totalDebt` but no course enrollment model; payment has optional `courseId` and no `autoAssignedCourses`.

* Routing/UI: `lib/core/app/routes/app_pages.dart:31-80`; views include Dashboard, Program/Course/Member screens and Record Payment.

* Controllers: Payment flow in `lib/core/presentation/controllers/payment_controller.dart` does not auto-allocate; Course assignment uses 0-amount payments.

* Reports: Mobile PDF service `lib/core/services/platform/report_service_mobile.dart` lists payments by optional `courseId`.

* Translations: `lib/core/translations/app_translations.dart` contains EN/FR keys.

## Data Model Updates

* Add `Enrollment` model (Hive box `enrollments`) to represent a participant assigned to a course:

  * Fields: `id`, `programId`, `courseId`, `memberId`, `createdAt`, `updatedAt`, `amountPaid` (sum allocated to this course).

  * Enables fast debt computations and deterministic allocation order by course `createdAt`.

* Extend `Payment` model to include `autoAssignedCourses: List<AllocationEntry>`:

  * Each entry: `courseId`, `courseName`, `amountApplied`.

  * Keep `courseId` nullable for legacy but primary flow is general payment auto-distribution.

* Member debt semantics:

  * `totalDebt` becomes the sum of all enrolled course fees minus total `amountPaid`; update consistently via services.

  * Use `pendingBalance = max(totalDebt - accountBalance, 0)`; fix UI mismatches (e.g., `MemberCard` should use `pendingBalance`).

## Storage & Initialization

* Register Hive adapters for `Enrollment` and `AllocationEntry` in `HiveService.initialize()`.

* Open `enrollments` box; migrate any existing 0-amount payments used as enrollment markers into `Enrollment` records.

## Allocation Algorithm

* Implement `PaymentAllocator` service:

  * Input: member, program, amount.

  * Steps:

    * Fetch member’s enrollments within program; order by related course `createdAt` ascending.

    * For each enrollment, compute `remainingFee = course.fee - enrollment.amountPaid`.

    * Apply payment across enrollments until amount is 0: update `enrollment.amountPaid` and build `autoAssignedCourses` entries.

    * If amount remains after all enrollments fully paid, add remainder to `member.accountBalance`.

    * Persist updates and return `AllocationResult` with `autoAssignedCourses`.

* New-course assignment behavior:

  * When assigning a member to a new course, if `member.accountBalance > 0`, immediately reduce the new course’s `remainingFee` by credit and decrement `accountBalance` accordingly; record a zero-amount payment with `autoAssignedCourses` showing credit applied OR update enrollment directly and emit a system note.

## Repository & Controller Changes

* Repositories:

  * Create `EnrollmentRepository` (CRUD, queries by member/program/course, debt totals).

  * Update `MemberRepository` to compute `totalDebt` using enrollments; stop using payments to infer enrollment.

  * Update `PaymentRepository` to support storing `autoAssignedCourses` and recent payments.

* Controllers:

  * `PaymentController.recordPayment(...)` delegates to `PaymentAllocator`, stores payment with `autoAssignedCourses`, updates member/enrollment state, refreshes views.

  * `CourseController.assignMembersToCourse(...)` creates `Enrollment` records instead of 0-amount payments and applies `accountBalance` credit to the new enrollment.

  * `DashboardController` totals: `totalPending` from aggregated enrollments minus credits; format currency via `intl`.

  * `MemberController` formats currency with `intl` and exposes per-course status by joining enrollments with courses.

## UI Updates

* Dashboard: keep existing cards; ensure recent payments show participant and allocated summary.

* Program List/Details: show aggregated totals (participants, payments, debt) using enrollments.

* Course Details: list enrolled participants and each `remainingFee` status.

* Member Details: display

  * Payments with date, amount, and `autoAssignedCourses` list,

  * Per-course summary (fee, amount paid, balance owed),

  * Totals: amount paid, total debt, account balance,

  * “Download Report” button triggers report service.

* Fix `MemberCard` to use `pendingBalance` and a real progress bar based on `amountPaid/fee`.

## Reporting (PDF)

* Update report service to include `autoAssignedCourses` entries for each payment.

* Add per-course summary table: `courseName`, `fee`, `amountPaid`, `balanceOwed` for the participant.

* Totals section: amount paid, total debt, account balance.

* Share/save via existing mobile/web services; wire the “Download Report” button on Member Details.

## Internationalization & Formatting

* Use `intl` for currency/date formatting across controllers and views; respect device locale with manual override in Settings.

* Keep GetX translations; ensure new strings are added for allocation summaries.

## Validation & UX

* Input validation for numeric fields (fee, amount) and required fields (names).

* Soft, professional UI consistent with `AppTheme`; cards with rounded corners and shadows; floating action for quick create.

## Testing

* Unit tests for `PaymentAllocator` allocation and new-course credit application.

* Widget tests for Member Details and Report generation triggers.

## Milestones

* Phase 1: Data models + Hive adapters + EnrollmentRepository + PaymentAllocator.

* Phase 2: Controllers updated (Payment, Course, Member) + Dashboard computations.

* Phase 3: UI updates (Member/Course/Program screens + MemberCard fixes).

* Phase 4: Reporting updates (PDF auto-assigned courses & summaries).

* Phase 5: Intl formatting and Settings polish; add tests.

## Notes & Risks

* Migrate existing enrollment markers (0-amount payments) into `Enrollment` records.

* Ensure backward compatibility for existing data; keep `courseId` optional on `Payment` but prefer `autoAssignedCourses`.

* Review `Member.hasCredit` semantics; should indicate `accountBalance > 0`.

## Next Actions

* On approval, implement Phase 1 changes, generate adapters with `build_runner`, and proceed through phases with verification at each step.

