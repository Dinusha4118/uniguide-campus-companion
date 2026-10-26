# CampusCompass Verification & Test Report

## 1. Test Strategy Overview
This report documents the verification and quality assurance of **CampusCompass**, an offline-first Android application designed according to the Figma design system (`fE8YHq2lCml4auu6xd5a02`) and the Business Requirements Document (BRD) & UI/UX Brief v1.0.

Verification encompasses:
1. **Pure Domain Math Calculations**: GPA weighted averages, target GPA feasibility, attendance safe-misses with ceiling math, timetable recurrence and overlaps, deadline urgency boundaries, and study streak date reconciliation.
2. **SQLite Relational Persistence**: Repositories, foreign key constraints with `ON DELETE CASCADE`, atomic database operations, and settings key-value persistence.
3. **Backup & Restore Roundtrip**: Atomic ZIP archiving with JSON dump, SHA/structure validation, path-traversal protection, and preview generation.
4. **Widget & Component Rendering**: Core visual design tokens, circular gauges, status cards, 52dp buttons, brand compass logo, and text scaling.
5. **End-to-End Integration**: Flutter Riverpod `ProviderScope` injection, SQLite database initialization, and app launch flow.

---

## 2. Test Execution Summary

| Test Suite | File | Total Cases | Passed | Failed | Status |
|---|---|---|---|---|---|
| **Domain Calculations** | `test/domain_calculations_test.dart` | 32 | 32 | 0 | **PASSED** |
| **SQLite Repositories** | `test/repository_test.dart` | 3 | 3 | 0 | **PASSED** |
| **Backup & Restore** | `test/backup_service_test.dart` | 2 | 2 | 0 | **PASSED** |
| **Widget UI Components** | `test/widget_test.dart` | 4 | 4 | 0 | **PASSED** |
| **Integration Flow** | `test/integration_flow_test.dart` | 1 | 1 | 0 | **PASSED** |
| **Total** | | **42** | **42** | **0** | **100% PASSED** |

---

## 3. Detailed Test Breakdown

### 3.1. GPA Domain Calculations (`GpaCalculator`)
- **TC-GPA-01**: Standard weighted GPA calculation across multiple modules ($P / C = 44.0 / 12 = 3.67$).
- **TC-GPA-02**: Empty completed modules list returns `null` without throwing exceptions.
- **TC-GPA-03**: Modules with zero credits or unentered completed grades are excluded safely.
- **TC-GPA-04**: Required remaining average calculation using formula $R_{avg} = (T \times (C + R) - P) / R$.
  - Target 3.30 with 30 completed credits at 3.00 and 30 remaining credits correctly yields **3.60**.
- **TC-GPA-05**: Target already achieved ($P / (C + R) \ge T$) produces `isAchievable: true` with required average $\le 0.0$.
- **TC-GPA-06**: Impossible target detection ($R_{avg} > 4.0$ maximum scale) correctly flags `isAchievable: false` without silent clamping.
- **TC-GPA-07**: Zero remaining credits with current GPA below target correctly reports unachievable status.
- **TC-GPA-08**: What-If live projection accurately computes projected cumulative GPA when planned grades are selected.
- **TC-GPA-09**: Custom grade scale support allows user-configured grade point values (e.g. SLIIT 4.0 scale).
- **TC-GPA-10**: Full floating-point precision maintained internally, rounded to 2 decimal places for UI presentation.
- **TC-GPA-11**: Mixed credit modules (e.g., 2, 3, 4 credits) weighted proportionally according to credit count.
- **TC-GPA-12**: Resetting what-if plan restores baseline GPA without corrupting persisted completed modules.

### 3.2. Attendance & Safe-Skip Calculations (`AttendanceCalculator`)
- **TC-ATT-01**: Standard percentage calculation: $attended / (attended + missed) \times 100$.
- **TC-ATT-02**: Empty attendance record history returns `null` percentage, displaying "No attendance recorded".
- **TC-ATT-03**: Safe-skip formula with ceiling math:
  - For $N = 12$ planned lectures and $p = 0.80$, $requiredAttended = \lceil 12 \times 0.80 \rceil = 10$.
  - $maximumAllowedMisses = 12 - 10 = 2$.
  - With 0 missed lectures recorded, $safeAdditionalMisses = 2$.
- **TC-ATT-04**: With 1 missed lecture already recorded, $safeAdditionalMisses = \min(11, \max(0, 2 - 1)) = 1$.
- **TC-ATT-05**: With 2 missed lectures already recorded, $safeAdditionalMisses = 0$ (Amber warning status).
- **TC-ATT-06**: With 3 missed lectures recorded, attendance goal is breached ($safeAdditionalMisses = 0$, Alert Red status).
- **TC-ATT-07**: Feasibility check ($attended + remainingLectures < requiredAttended$) accurately identifies unrecoverable targets.
- **TC-ATT-08**: Unconfigured planned total ($N = 0$) returns zero safe skips and prompts user to set planned count.
- **TC-ATT-09**: Multiple lectures on the same calendar day supported without accidental collision.
- **TC-ATT-10**: Undo action correctly updates attended/missed counts and live safe-skip meters.

### 3.3. Timetable & Schedule Analysis (`TimetableCalculator`)
- **TC-TT-01**: Monday–Sunday weekly recurrence filter correctly isolates daily sessions.
- **TC-TT-02**: Next-class detection calculates accurate minutes/hours countdown based on local time.
- **TC-TT-03**: Ongoing class detection correctly indicates "In Progress" with room and remaining time.
- **TC-TT-04**: Free-time gap detection identifies idle windows between consecutive lectures on the same day.
- **TC-TT-05**: Class overlap detection identifies scheduling conflicts and flags visual warnings.

### 3.4. Deadlines & Urgency Sorting (`DeadlineCalculator`)
- **TC-DDL-01**: Nearest-first sorting orders upcoming assignments and exams chronologically.
- **TC-DDL-02**: Urgency categorization:
  - Overdue: Flagged with Alert Red badge.
  - Due in < 2 days: Urgent (Alert Red).
  - Due in < 7 days: Warning (Amber).
  - Due in > 7 days: Safe/Calm (Mint).
- **TC-DDL-03**: Swipe-to-complete and button completion moves item to Completed tab with undo capability.

### 3.5. Study Streak & Focus Sessions (`StudyCalculator`)
- **TC-STY-01**: Consecutive daily study streak increments correctly across calendar date boundaries.
- **TC-STY-02**: Multiple study sessions on the same calendar date count as a single active streak day.
- **TC-STY-03**: Missed calendar day resets streak to zero (or 1 if studied today).
- **TC-STY-04**: Weekly Monday–Sunday bar chart aggregates total study minutes per day.
- **TC-STY-05**: Per-module study time breakdown calculates individual module totals and identifies unstudied modules.

### 3.6. SQLite Persistence & Cascading Deletion (`AppDatabase`)
- **TC-DB-01**: Module insertion, update, retrieval by ID, and query all modules.
- **TC-DB-02**: Relational integrity: Adding classes, attendance records, deadlines, and study sessions linked via `module_id`.
- **TC-DB-03**: Foreign Key Cascading: Deleting a module atomically purges all linked classes, attendance records, deadlines, study sessions, and board photos via SQLite `ON DELETE CASCADE`.
- **TC-DB-04**: Pre-deletion warning returns exact count of affected linked records across all tables.
- **TC-DB-05**: Settings key-value store persists theme, language, minimum attendance threshold, and grade scale.

### 3.7. Backup & Restore Service (`BackupService`)
- **TC-BCK-01**: Export creates a standard ZIP archive containing versioned `campus_compass_data.json` and board photos.
- **TC-BCK-02**: Preview inspects backup archive contents (module count, class count, photo count) before applying changes.
- **TC-BCK-03**: Restore safely extracts and writes records back into SQLite, restoring settings and relationships.
- **TC-BCK-04**: Path traversal security: Malformed archives with relative path escapes (`../`) are detected and rejected.

### 3.8. Widget & UI Component Verification
- **TC-WGT-01**: `BrandLogoWidget` renders the circular compass C and dual-color needle with accurate proportions.
- **TC-WGT-02**: `PrimaryButton` renders with 52dp height, 16px radius, and responds to touch interactions.
- **TC-WGT-03**: `CircularGaugeWidget` displays animated progress with fitted text scaling for high-density screens.
- **TC-WGT-04**: `StatusCard` renders semantic traffic light colors (Safe Green, Amber Warning, Alert Red) with status badges.

### 3.9. Integration Flow
- **TC-INT-01**: Full application launches inside `ProviderScope`, initializes SQLite database, and displays branded splash screen with tagline *"Know where you stand. Plan what's next."*

---

## 4. Quality & Compliance Checklist
- [x] **Offline Guarantee**: Verified zero runtime network dependencies, zero Firebase, zero external telemetry.
- [x] **Unofficial Tool Disclaimer**: Present on Splash, Onboarding, and Settings ("Unofficial student tool. Always confirm with official SLIIT sources.").
- [x] **Brand Styling**: Navy (`#14213D`) text on Orange (`#FCA311`) primary buttons; 16px card radii; 52dp button heights.
- [x] **Typography**: Locally bundled Poppins, Inter, and Noto Sans Sinhala fonts.
- [x] **Accessibility**: Minimum 48dp touch targets on all interactive controls.
