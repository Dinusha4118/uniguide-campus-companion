# CampusCompass 🧭
> **"Know where you stand. Plan what's next."**  
> *A calm, student-first offline companion for managing modules, GPA goals, attendance, deadlines, classes, study sessions, and lecture-board photos.*

---

## 🏛️ Project & Governance Notice
> **"Unofficial student tool. Always confirm with official SLIIT sources."**  
CampusCompass is an independent, offline student utility designed to help students track academic commitments, visualize attendance safety margins, and model GPA scenarios. It does not replace or represent official university portals, LMS systems, or administrative records.

---

## 🔒 100% Offline-First Architecture
- **Zero Network Access**: No cloud backends, no Firebase/Supabase, no third-party telemetry or analytics, and zero advertisements.
- **Local Sandbox Storage**: All data (modules, grades, attendance logs, timetable entries, study sessions, and camera board captures) is stored strictly on-device in app-private SQLite storage and sandbox directories.
- **Data Sovereignty**: Complete data portability via atomic ZIP export and restore.

---

## 📱 Features & Capabilities

### 1. 📅 Weekly Recurring Timetable & Next Class
- Monday through Sunday day-by-day timetable navigation.
- Accurate real-time countdown to the next scheduled class.
- Live "In Progress" session status indicators with room numbers.
- Automated detection of free-time study gaps between lectures.
- Visual warnings for schedule overlaps.

### 2. 🚦 Attendance Traffic Light & Safe-Skip Meter
- Semantic traffic light indicators:
  - 🟢 **Safe**: $>80\%$ attendance.
  - 🟡 **Warning**: Near the $80\%$ minimum attendance threshold.
  - 🔴 **Alert**: Below $80\%$ attendance threshold.
- **Ceiling-based Safe Skip Math**:
  $$\text{Required Attended} = \lceil N \times p \rceil$$
  $$\text{Maximum Allowed Misses} = N - \text{Required Attended}$$
  $$\text{Safe Additional Misses} = \min(\text{Remaining}, \max(0, \text{Max Allowed Misses} - \text{Recorded Misses}))$$
- Clear distinction between "No attendance recorded" and 0% attendance.
- Lecture log history with one-tap undo capability.

### 3. 🎯 GPA Target & Interactive What-If Planner
- Accurate credit-weighted GPA calculation:
  $$\text{GPA} = \frac{\sum (\text{Credits} \times \text{Grade Points})}{\sum \text{Credits}}$$
- **Required Remaining Average Formula**:
  $$R_{\text{avg}} = \frac{T \times (C + R) - P}{R}$$
- Clear detection of unachievable targets ($R_{\text{avg}} > 4.0$) without silent clamping.
- Interactive What-If Planner: tap grade chips (A+ down to E) per module to project cumulative GPA in real time.
- Fully customizable and persisted university grade point scale.

### 4. ⏰ Deadlines & Urgency Categorization
- Chronological, nearest-first deadline tracking.
- Three tabbed filters: **Upcoming**, **Overdue**, and **Completed**.
- Dynamic visual urgency badges:
  - 🔴 **Overdue** / Due in $< 2$ days
  - 🟡 Due in $< 7$ days
  - 🟢 Due in $> 7$ days
- Swipe-to-complete with undo snackbar and button-based completion.

### 5. ⏱️ 25/5 Focus Timer & Study Statistics
- Integrated 25-minute focus / 5-minute break Pomodoro timer linked to academic modules.
- Persisted timestamp state reconciliation to prevent lost time across app minimize or screen lock.
- Local calendar date streak tracking with same-day session aggregation.
- Monday–Sunday weekly study time bar chart.
- Per-module study time breakdown and alerts for unstudied modules.

### 6. 📸 Board Snap
- Real camera capture for lecture slides and whiteboard notes.
- Module folder organization with thumbnail grids.
- Pinch-to-zoom full-screen viewer (`InteractiveViewer`) with metadata notes and confirmed deletion.
- Stored exclusively in app-private sandboxed documents storage.

### 7. 🌐 Localization & Dual Themes
- **Sinhala & English**: Complete internationalization via Flutter ARB catalogs (`app_en.arb`, `app_si.arb`).
- Bundled Google Fonts: `Poppins` (headings), `Inter` (body), and `Noto Sans Sinhala` (Sinhala text with $\ge 1.5$ line-height).
- **Themes**: Seamless Light (Soft Cloud `#F5F7FB`) and Dark (Night `#0B1020` / Surface Dark `#161B2E`) modes.
- Strict adherence to Deep Navy (`#14213D`) text on Campus Orange (`#FCA311`) primary 52dp buttons.

### 8. 📦 Atomic Backup & Restore
- Portable `.zip` backup package containing JSON database dump and board photos.
- Path traversal security validation against directory escapes (`../`).
- Archive preview dialog showing module count, class count, and photos before restore.

---

## 📂 Project Structure

```
c:\Users\HP\Desktop\CampusCompress\
├── assets/
│   └── fonts/                   # Bundled Poppins, Inter, Noto Sans Sinhala TTFs
├── lib/
│   ├── application/
│   │   └── providers/           # Riverpod state notifiers and dependency providers
│   ├── data/
│   │   ├── database/            # SQLite schema migrations & foreign keys
│   │   ├── repositories/        # 7 modular repositories (Modules, Timetable, etc.)
│   │   └── services/            # Local notifications, camera, ZIP backup
│   ├── domain/
│   │   ├── calculations/        # Pure math (GPA, Attendance, Streaks, Deadlines)
│   │   └── models/              # Pure domain data models
│   ├── l10n/                    # ARB translation files (English & Sinhala)
│   ├── presentation/
│   │   ├── routes/              # Declarative GoRouter configuration
│   │   ├── screens/             # 20+ feature screens (Home, Classes, GPA, etc.)
│   │   ├── theme/               # Design tokens, typography, and color palettes
│   │   └── widgets/             # Reusable UI components (Buttons, Cards, Gauges)
│   └── main.dart                # App entrypoint with ProviderScope
├── test/
│   ├── domain_calculations_test.dart  # 32 pure math unit tests
│   ├── repository_test.dart           # SQLite CRUD and cascade deletion tests
│   ├── backup_service_test.dart       # ZIP export, preview, and restore tests
│   ├── widget_test.dart               # Component rendering and touch tests
│   └── integration_flow_test.dart     # Full app launch and routing test
├── DESIGN_MAPPING.md            # Figma 47 Light / 47 Dark frame mapping
├── IMPLEMENTATION_PLAN.md       # Comprehensive 9-phase execution log
├── TEST_REPORT.md               # Detailed 42-case test report
└── pubspec.yaml                 # Dependencies and asset declarations
```

---

## 🛠️ Build & Verification Instructions

### 1. Prerequisites
- **Flutter SDK**: 3.47.8+
- **Dart SDK**: 3.13.7+
- **Android SDK**: API 26+ (minSdk 26, targetSdk 35/36)
- **Java JDK**: 17 or 21+

### 2. Install Dependencies
```bash
flutter pub get
flutter gen-l10n
```

### 3. Run Automated Tests
```bash
flutter test
```
*Executes all 42 domain calculation, repository, backup, widget, and integration tests.*

### 4. Build Android APK
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release
```
*Generated output will be located at `build/app/outputs/flutter-apk/`.*
