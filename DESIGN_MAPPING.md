# CampusCompass Design to Screen Mapping

Source of Truth:
- **Figma Design URL**: `https://www.figma.com/design/fE8YHq2lCml4auu6xd5a02`
- **Figma Prototype URL**: `https://www.figma.com/proto/fE8YHq2lCml4auu6xd5a02`
- **Figma File Key**: `fE8YHq2lCml4auu6xd5a02`
- **Specification Document**: `CampusCompass_BRD_and_UIUX_Brief.pdf` (Version 1.0, 24 October 2026)

---

## 1. Brand Tokens & Color Palette

| Token Name | Hex Code | Light Role | Dark Role | Usage in CampusCompass |
|---|---|---|---|---|
| **Deep Navy** | `#14213D` | Primary headers, app bars, brand cards | Brand highlights, button text on orange | Card backgrounds, top navigation headers, primary branding |
| **Campus Orange** | `#FCA311` | Primary CTA, active accents | Primary CTA, active accents | Primary 52dp buttons, circular gauges, active indicators |
| **Mint Success** | `#2EC4B6` | Safe attendance, completed status | Safe attendance, completed status | Green traffic light card, >80% attendance, safe deadlines (>7 days) |
| **Amber Warn** | `#FFB703` | Warning status, close deadlines | Warning status, close deadlines | Amber traffic light card, near minimum attendance (80%), deadlines <7 days |
| **Alert Red** | `#E5484D` | Danger status, overdue deadlines | Danger status, overdue deadlines | Low attendance alerts (<80%), deadlines <2 days, destructive buttons |
| **Soft Cloud** | `#F5F7FB` | Background (Light Mode) | N/A | Scaffold background, soft secondary surfaces in Light Mode |
| **Night** | `#0B1020` | N/A | Background (Dark Mode) | Scaffold background in Dark Mode |
| **Ink** | `#1B1F2A` | Primary text (Light Mode) | N/A | High-contrast body text and titles |
| **Surface Dark** | `#161B2E` | N/A | Card Surface (Dark Mode) | Rounded cards in Dark Mode |
| **Surface Dark Elevated** | `#1F263D` | N/A | Card Elevated (Dark Mode) | Nested cards, dialogs, inputs in Dark Mode |
| **Text Dark High** | `#FFFFFF` | N/A | Primary text (Dark Mode) | High-contrast text on dark backgrounds |
| **Text Dark Muted** | `#9EABC0` | N/A | Muted text (Dark Mode) | Secondary labels, timestamps, metadata |
| **Border Light** | `#E5E9F2` | Card borders / dividers | N/A | Subtle clean strokes |
| **Border Dark** | `#2A334E` | N/A | Card borders / dividers | Dark mode borders |

---

## 2. Typography System

- **Headings**: `Poppins` (Bold, SemiBold)
  - Hero / Title: 24sp – 28sp Bold
  - Section Header: 18sp – 20sp SemiBold
  - Card Title: 16sp – 18sp SemiBold
- **Body & Subtitles**: `Inter` (Regular, Medium, SemiBold)
  - Body: 14sp Regular
  - Body Medium: 14sp Medium
  - Caption / Label: 12sp Regular / SemiBold
  - Overline / Badge: 11sp SemiBold (All Caps, letter spacing +0.5)
- **Sinhala Localization**: `Noto Sans Sinhala` (Regular, SemiBold, Bold)
  - Height multiplier: $\ge 1.5$ line height to prevent diacritic clipping.

---

## 3. Screen Family Mapping to Figma Starting Nodes

| Screen Family | Primary Node ID | Flutter Route / Component | Key States & Interactions |
|---|---|---|---|
| **Brand & Logo** | `10:234`, `3:32` | `BrandLogoWidget` | Compass C ring with dual-color needle (Orange/Mint) on Navy |
| **Splash & Onboarding 1** | `4:2` | `/splash`, `/onboarding` | Logo, Tagline "Know where you stand. Plan what's next", "Let's begin" button |
| **Onboarding 2** | `4:22` | `/onboarding/step2` | "Your semester at a glance" preview card |
| **Onboarding 3** | `4:33` | `/onboarding/step3` | "No more attendance surprises" safe-skip preview |
| **Disclaimer & Preferences** | `4:53` | `/onboarding/disclaimer` | Unofficial student tool notice, Language selector (English/Sinhala), "Set up my semester" |
| **Setup Wizard - Modules** | `4:65` | `/setup/modules` | Add module name, code, credits, planned lecture count, progress bar (1/2) |
| **Setup Wizard - Timetable**| `4:85` | `/setup/timetable` | Add weekly classes (Day, Time, Hall, Module), progress bar (2/2) |
| **Home (Light)** | `4:125` | `/home` | Greeting, Next Class countdown, Deadlines due soon, Attendance alert, Quick shortcuts |
| **Home (Dark)** | `9:1549` | `/home` (dark theme) | Identical structure rendered with Night `#0B1020` and Surface Dark `#161B2E` |
| **Timetable Tab** | `4:168` | `/classes/timetable` | Timetable/Attendance toggle, Mon–Sun weekday tabs, Class cards, Free-time gaps |
| **Attendance Tab** | `4:210` | `/classes/attendance` | Traffic light module cards (Green/Amber/Red), Attended/Missed buttons, safe skip count |
| **Attendance Detail** | `4:246` | `/classes/attendance/:id` | Lecture log, date history, undo attended/missed status |
| **Add / Edit Class** | `4:280` | `/classes/add` | Module picker, Day of week, Time picker, Room textfield |
| **Deadlines Tab** | `4:317` | `/deadlines` | Upcoming / Overdue / Completed filters, Urgency colored badges, Swipe to done |
| **Add / Edit Deadline** | `4:360` | `/deadlines/add` | Title, Module, Type (Assignment, Quiz, Viva, Exam), Date & Time picker |
| **GPA Target Planner** | `5:140` | `/gpa` | Circular GPA Gauge, Target comparison, Required remaining average card |
| **GPA What-If Planner** | `5:180` | `/gpa/what-if` | Interactive grade chips per module (A+ to E), Live projected GPA re-calculation |
| **Focus Timer** | `5:240` | `/study/focus` | 25-min focus ring, Module dropdown, Start/Pause/Resume/Cancel, 4-day streak badge |
| **Study Statistics** | `5:375` | `/study/stats` | Total study time, Streak count, Weekly bar chart (M-S), Per-module study time list |
| **Board Snap Folders** | `5:431` | `/boards` | Module folder grid with photo count, Capture board note button |
| **Board Photo Viewer** | `5:460` | `/boards/:id` | Full screen viewer, pinch-to-zoom, date & note overlay, delete photo |
| **Settings** | `6:170` | `/settings` | Language, Theme, Academic Rules (Grade scale, Min attendance %), Backup, Disclaimer |
| **Academic Rules** | `6:200` | `/settings/rules` | Editable grade points table, 80% minimum attendance slider/input |
| **Backup & Restore** | `6:240` | `/settings/backup` | Export ZIP backup, Import ZIP preview dialog, restore confirmation |

---

## 4. Comprehensive 47-State Matrix (Light & Dark Themes)

| # | Screen / State Name | Light Figma Representation | Dark Figma Equivalent | Implemented Widget / Route |
|---|---|---|---|---|
| 1 | Splash Screen | Soft Cloud bg, Navy card | Night bg, Surface Dark card | `SplashScreen` |
| 2 | Onboarding Slide 1 (Intro) | Poppins bold hero, orange CTA | Dark mode cards, orange CTA | `OnboardingFlowScreen` (Page 0) |
| 3 | Onboarding Slide 2 (Schedule) | Illustrated timetable preview | Dark schedule preview card | `OnboardingFlowScreen` (Page 1) |
| 4 | Onboarding Slide 3 (Attendance) | Safe-skip preview meter | Dark safe-skip preview meter | `OnboardingFlowScreen` (Page 2) |
| 5 | Disclaimer & First-Run Setup | Unofficial notice banner | Dark alert banner | `OnboardingFlowScreen` (Page 3) |
| 6 | Setup Wizard: Add Modules | Step 1/2 indicator, input forms | Dark input styling, 16px radius | `SetupWizardScreen` (Step 1) |
| 7 | Setup Wizard: Add Classes | Step 2/2 indicator, day selector | Dark day chips, time picker | `SetupWizardScreen` (Step 2) |
| 8 | Home: Normal State | Greeting, Next Class, Deadlines | High-contrast dark surfaces | `HomeScreen` |
| 9 | Home: Class In Progress | Pulse indicator, room badge | Dark card with pulse indicator | `HomeScreen` |
| 10 | Home: No Classes Today | Friendly empty class state | Muted dark card state | `HomeScreen` |
| 11 | Home: Deadlines Empty | "All caught up" check illustration | Dark calm check card | `HomeScreen` |
| 12 | Home: Attendance Warning | Red/Amber priority warning banner | Alert Red border in dark theme | `HomeScreen` |
| 13 | Timetable: Mon–Sun Selector | Segmented pills, active orange | Dark pills, active orange pill | `ClassesScreen` (Tab 0) |
| 14 | Timetable: Class Card | Hall, start/end time, module name | Surface Dark card, white text | `ClassesScreen` (Tab 0) |
| 15 | Timetable: Free-Time Gap | Dotted line with idle duration | Dark dotted line idle window | `ClassesScreen` (Tab 0) |
| 16 | Timetable: Overlap Conflict | Amber conflict badge | Dark amber conflict warning | `ClassesScreen` (Tab 0) |
| 17 | Add Class Modal | Form inputs, dropdown, time picker | Surface Dark modal sheet | `AddClassScreen` |
| 18 | Edit Class Modal | Pre-populated inputs, save CTA | Dark pre-populated modal | `AddClassScreen` |
| 19 | Attendance: Module List | Traffic light cards (Green/Amber/Red) | Dark surface cards with colored bars | `ClassesScreen` (Tab 1) |
| 20 | Attendance: Safe State | Mint badge, safe skips remaining | Mint badge, dark background | `ClassesScreen` (Tab 1) |
| 21 | Attendance: Warning State | Amber badge, 0 safe skips | Amber badge, dark background | `ClassesScreen` (Tab 1) |
| 22 | Attendance: Alert State | Red badge, breached requirement | Alert Red badge, dark background | `ClassesScreen` (Tab 1) |
| 23 | Attendance: Empty State | "No attendance recorded" | "No attendance recorded" muted | `ClassesScreen` (Tab 1) |
| 24 | Attendance Detail: Log | Lecture date entries with status | Dark log cards with status badges | `AttendanceDetailScreen` |
| 25 | Attendance Detail: Undo | Snackbar notification with undo | Dark snackbar with undo CTA | `AttendanceDetailScreen` |
| 26 | Deadlines: Upcoming Filter | Chronological cards, urgency tags | Dark cards with urgency tags | `DeadlinesScreen` (Tab 0) |
| 27 | Deadlines: Overdue Filter | Red overdue tags and countdowns | Dark cards, red tags | `DeadlinesScreen` (Tab 1) |
| 28 | Deadlines: Completed Filter | Strike-through text, check icon | Dimmed dark cards, check icon | `DeadlinesScreen` (Tab 2) |
| 29 | Deadlines: Swipe to Done | Swipe background transition | Swipe background transition | `DeadlinesScreen` |
| 30 | Add Deadline Modal | Title, module picker, date picker | Surface Dark modal sheet | `AddDeadlineScreen` |
| 31 | GPA: Target Overview | Circular gauge (Current vs Target) | Circular gauge with dark track | `GpaScreen` |
| 32 | GPA: Required Average Card | Projected target calculation | Dark card with required grade | `GpaScreen` |
| 33 | GPA: Impossible Target Alert | Warning banner for average > 4.0 | Dark red warning banner | `GpaScreen` |
| 34 | GPA: What-If Planner | Interactive grade chips per module | Dark interactive chips | `WhatIfPlannerScreen` |
| 35 | GPA: What-If Recalculation | Live projected GPA recomputation | Live projected GPA recomputation | `WhatIfPlannerScreen` |
| 36 | Focus Timer: Idle | 25:00 circular ring, module picker | 25:00 ring on Night background | `StudyScreen` |
| 37 | Focus Timer: Running | Active countdown with pause CTA | Active countdown on dark | `StudyScreen` |
| 38 | Focus Timer: Break Mode | 05:00 green break indicator | 05:00 break ring on dark | `StudyScreen` |
| 39 | Focus Timer: Completed | Save session dialog, streak update | Dark save session dialog | `StudyScreen` |
| 40 | Study Stats: Weekly Chart | Mon–Sun vertical bar chart | Bar chart with dark gridlines | `StudyStatsScreen` |
| 41 | Study Stats: Module Breakdown | Ranked study hours by module | Dark list with colored module dots | `StudyStatsScreen` |
| 42 | Board Snap: Folder Grid | Module folders with count badges | Surface Dark folder tiles | `BoardGalleryScreen` |
| 43 | Board Snap: Camera Capture | Live camera viewfinder and shutter | Camera viewfinder on dark | `BoardCaptureScreen` |
| 44 | Board Snap: Viewer | Fullscreen zoom, date/note overlay | Fullscreen zoom on dark | `BoardViewerScreen` |
| 45 | Settings: Main Menu | Theme, language, backup, rules | Dark list tiles with icons | `SettingsScreen` |
| 46 | Settings: Academic Rules | Editable grade points table | Dark table with input fields | `AcademicRulesScreen` |
| 47 | Settings: Backup & Restore | ZIP export & preview dialog | Dark preview dialog with stats | `SettingsScreen` (Backup) |
