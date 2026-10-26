const fs = require('fs');
const path = require('path');

function getBase64(fileRel) {
  const fullPath = path.join(__dirname, 'manual_assets', fileRel);
  if (!fs.existsSync(fullPath)) return '';
  const bitmap = fs.readFileSync(fullPath);
  return 'data:image/png;base64,' + Buffer.from(bitmap).toString('base64');
}

const appIconBase64 = getBase64('app_icon.png');

const sections = [
  {
    num: "01",
    tag: "SCREENS 1 & 2",
    titleEn: "01. App Launch & Onboarding Experience",
    titleSi: "යෙදුම හඳුන්වාදීම සහ Launch සජීවීකරණය",
    desc: "The entry screen introduces the student to the UniGuide ecosystem with high-impact brand resonance, animated logo bounce, and pleasant female audio guidance.",
    mockup: `
      <div style="align-items: center; justify-content: center; text-align: center; background: #f5f7fb; height: 100%; display: flex; flex-direction: column;">
        <div style="width: 76px; height: 76px; background: #0d253f; border-radius: 18px; display: flex; align-items: center; justify-content: center; box-shadow: 0 8px 20px rgba(0,112,243,0.3); margin-bottom: 14px;">
          <img src="${appIconBase64}" style="width: 68px; height: 68px; border-radius: 16px;">
        </div>
        <div style="font-size: 19px; font-weight: 800; color: #0d253f; letter-spacing: -0.5px;">Uni<span style="color: #0070f3;">Guide</span></div>
        <div style="font-size: 10px; color: #64748b; margin-top: 4px; padding: 0 10px;">Know where you stand. Plan what’s next.</div>
        <div style="margin-top: 35px; background: #0070f3; color: white; padding: 7px 24px; border-radius: 20px; font-weight: 700; font-size: 10px; box-shadow: 0 4px 12px rgba(0,112,243,0.3);">
          Let's begin / ආරම්භ කරමු
        </div>
        <div style="margin-top: 25px; font-size: 8.5px; color: #64748b; text-align: center;">
          🔊 Girl Voice: "Uni Guide"
        </div>
      </div>
    `,
    enPoints: [
      "Voice Feedback: Welcoming girl audio prompt 'Uni Guide' plays automatically upon launching the app.",
      "Elastic Spring Animation: Dynamic 1.4-second logo bounce with realistic compass tilt.",
      "Instant Start: Tap 'Let\\'s begin' to directly enter the setup flow or home screen.",
      "100% Offline Readiness: Operates completely without needing internet connection."
    ],
    siPoints: [
      "හඬ මඟපෙන්වීම: App එක විවෘත වන විටම පැහැදිලි කාන්තා හඬකින් 'Uni Guide' නම ප්‍රකාශ වේ.",
      "ලාංඡන සජීවීකරණය: මාලිමා කටුව චලනය වන ආකර්ෂණීය Elastic Bounce Animation එක.",
      "පහසු පිවිසුම: 'ආරම්භ කරමු' බොත්තම මඟින් මොඩියුල පිහිටුවීමට හෝ මුල් පිටුවට පිවිසෙන්න.",
      "නොබැඳි ක්‍රියාකාරිත්වය: කිසිදු අන්තර්ජාල සම්බන්ධතාවයකින් තොරව ක්ෂණිකව ක්‍රියාත්මක වේ."
    ],
    tableRows: [
      ["1", "Launch UniGuide app from your mobile phone.", "දුරකථනයේ මුල් තිරයෙන් UniGuide යෙදුම විවෘත කරන්න."],
      ["2", "Experience logo animation & introductory girl voice.", "ලාංඡන සජීවීකරණය සහ කාන්තා හඬ ප්‍රතිචාරය ශ්‍රවණය කරන්න."],
      ["3", "Tap 'Let\\'s begin' to access semester setup.", "'ආරම්භ කරමු' තට්ටු කර ප්‍රථම අධ්‍යයන වාර පිහිටුවීම් වෙත පිවිසෙන්න."]
    ]
  },
  {
    num: "02",
    tag: "SCREENS 6 & 7",
    titleEn: "02. Setup Wizard & Module Intake",
    titleSi: "ප්‍රථම පිහිටුවීම් සහ මොඩියුල ඇතුළත් කිරීම",
    desc: "The setup wizard guides students to define their academic workload. Module and lecture data powers the attendance tracker, GPA simulator, and deadline engine.",
    mockup: `
      <div style="background: #f8fafc; height: 100%; display: flex; flex-direction: column;">
        <div class="mock-header">
          <span style="font-weight: 700; color: #0d253f;">Setup Wizard</span>
          <span class="mock-badge badge-blue">Step 1 of 2</span>
        </div>
        <div style="font-size: 11px; font-weight: 700; color: #0d253f; margin-bottom: 2px;">Semester Modules</div>
        <div style="font-size: 8px; color: #64748b; margin-bottom: 8px;">Add your enrolled subjects for this term</div>

        <div class="mock-card">
          <div style="font-weight: 700; font-size: 10px; color: #0d253f;">Data Structures & Algorithms</div>
          <div style="font-size: 8px; color: #64748b;">IT2030 · 4 Credits · 14 Lectures</div>
        </div>

        <div class="mock-card">
          <div style="font-weight: 700; font-size: 10px; color: #0d253f;">Database Management Systems</div>
          <div style="font-size: 8px; color: #64748b;">IT2040 · 3 Credits · 12 Lectures</div>
        </div>

        <div style="border: 1px dashed #0070f3; border-radius: 8px; padding: 7px; text-align: center; color: #0070f3; font-weight: 700; font-size: 9px; margin-top: 6px;">
          + Add Another Module
        </div>

        <div style="margin-top: auto; background: #fca311; color: #0d253f; text-align: center; padding: 8px; border-radius: 10px; font-weight: 800; font-size: 9.5px;">
          Continue to Timetable →
        </div>
      </div>
    `,
    enPoints: [
      "Subject Codes: Enter standard university codes (e.g. IT2030, SE3040).",
      "Credit Weighting: Assign credits (1 to 6) which dictate GPA importance.",
      "Total Sessions: Configure planned lecture counts for accurate attendance % thresholds.",
      "Target Grade: Set target expectations (A, A-, B+) for semester performance."
    ],
    siPoints: [
      "විෂය කේත: විශ්වවිද්‍යාලයේ නිල විෂය කේතය (Module Code) ඇතුළත් කරන්න.",
      "ක්‍රෙඩිට් අගය: GPA ගණනය කිරීමට බලපාන Credit ප්‍රමාණය (1-6) සකසන්න.",
      "සම්පූර්ණ දේශන ගණන: පැමිණීමේ ප්‍රතිශතය සඳහා මුළු දේශන ගණන ඇතුළත් කරන්න.",
      "ඉලක්ක ශ්‍රේණිය: ඔබ අපේක්ෂා කරන ඉලක්ක ශ්‍රේණිය (Target Grade) තෝරන්න."
    ],
    tableRows: [
      ["Module Code", "Enter official code e.g. IT2030.", "විෂය කේතය ඇතුළත් කරන්න."],
      ["Credits", "Set 1, 2, 3, or 4 credits for GPA weighting.", "GPA ගණනය සඳහා ක්‍රෙඩිට් අගය තෝරන්න."],
      ["Planned Sessions", "Estimated total lectures in semester (e.g. 14).", "අධ්‍යයන වාරයේ මුළු දේශන ගණන ඇතුළත් කරන්න."]
    ]
  },
  {
    num: "03",
    tag: "SCREEN 8",
    titleEn: "03. Home Dashboard (Live Command Center)",
    titleSi: "මුල් පුවරුව (Next Class සහ Quick Status)",
    desc: "The Home screen dynamically recalculates every time you open the app to display whatever is happening right now or coming up next.",
    mockup: `
      <div style="background: #f5f7fb; height: 100%; display: flex; flex-direction: column;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
          <div>
            <div style="font-size: 12px; font-weight: 800; color: #0d253f;">Good morning, Student 👋</div>
            <div style="font-size: 7.5px; color: #64748b;">Monday, 26 October · At a glance</div>
          </div>
          <div style="font-size: 12px;">⚙️</div>
        </div>

        <div style="background: linear-gradient(135deg, #0d253f, #153e75); color: white; border-radius: 10px; padding: 8px 10px; margin-bottom: 7px;">
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <span class="mock-badge" style="background: #fca311; color: #0d253f; font-size: 7.5px;">NEXT UP IN 35 MIN</span>
            <span style="font-size: 7.5px; color: #94a3b8;">10:30 AM - 12:30 PM</span>
          </div>
          <div style="font-size: 11px; font-weight: 800; margin-top: 4px;">Software Engineering Architecture</div>
          <div style="font-size: 8.5px; color: #cbd5e1; margin-top: 2px;">📍 Hall B402 · Prof. Perera</div>
        </div>

        <div class="mock-card" style="padding: 6px 8px; margin-bottom: 6px;">
          <div style="display: flex; justify-content: space-between; margin-bottom: 2px;">
            <span style="font-weight: 700; font-size: 9px; color: #0d253f;">⏰ Deadlines Due Soon</span>
            <span class="mock-badge badge-red" style="font-size: 7.5px;">2 Days Left</span>
          </div>
          <div style="font-size: 8.5px; font-weight: 600;">Assignment 02: REST API Architecture</div>
        </div>

        <div class="mock-card" style="border-left: 3px solid #2ec4b6; padding: 6px 8px; margin-bottom: 6px;">
          <div style="display: flex; justify-content: space-between;">
            <span style="font-weight: 700; font-size: 9px; color: #0d253f;">🛡️ Attendance Status</span>
            <span class="mock-badge badge-green" style="font-size: 7.5px;">87.5% Safe</span>
          </div>
          <div style="font-size: 7.5px; color: #475569; margin-top: 2px;">You can safely miss 2 more classes in DBMS.</div>
        </div>

        <div style="margin-top: auto; display: flex; justify-content: space-around; background: white; padding: 6px 0; border-top: 1px solid #e2e8f0; border-radius: 10px 10px 0 0;">
          <span style="color: #0070f3; font-weight: 700; font-size: 7.5px;">🏠 Home</span>
          <span style="color: #94a3b8; font-size: 7.5px;">📅 Classes</span>
          <span style="color: #94a3b8; font-size: 7.5px;">⏰ Deadlines</span>
          <span style="color: #94a3b8; font-size: 7.5px;">⏱️ Study</span>
          <span style="color: #94a3b8; font-size: 7.5px;">🎓 GPA</span>
        </div>
      </div>
    `,
    enPoints: [
      "Real-time countdown timer to your next lecture with hall and lecturer details.",
      "Live pulsating badge indicator whenever a class is currently active.",
      "Highlighted urgent deadlines due within 48 hours to prevent mark deductions.",
      "Traffic-light attendance health summary across all enrolled subjects."
    ],
    siPoints: [
      "මීළඟ දේශනයට ඉතිරි කාලය, දේශන ශාලාව සහ ආචාර්යවරයා ක්ෂණිකව දැකීම.",
      "මේ මොහොතේ පැවැත්වෙන දේශනය සඳහා සජීවී Pulse Badge එක.",
      "පැය 48ක් ඇතුළත භාරදිය යුතු පැවරුම් (Deadlines) රතු පැහැයෙන් අනතුරු ඇඟවීම.",
      "සියලුම විෂයයන්හි පැමිණීමේ සෞඛ්‍යය එක බැල්මකින් පෙන්වන Traffic-Light සාරාංශය."
    ],
    tableRows: [
      ["Next Class Card", "Tap to jump straight into today's timetable.", "අද දවසේ කාලසටහන වෙත කෙලින්ම පිවිසෙන්න."],
      ["Urgent Deadlines", "Tap to view full submission brief and attachments.", "පැවරුමේ විස්තර සහ අවශ්‍යතා පරීක්ෂා කරන්න."],
      ["Attendance Alert", "Tap to see safe-skip projection details.", "Safe-skip ගණනය කිරීම් විස්තරාත්මකව බලන්න."]
    ]
  },
  {
    num: "04",
    tag: "SCREEN 13 & 15",
    titleEn: "04. Timetable & Free-Time Optimization",
    titleSi: "දේශන කාලසටහන සහ නිදහස් කාල කවුළු",
    desc: "UniGuide computes idle gaps between consecutive classes so students can schedule productive revision and library study intervals.",
    mockup: `
      <div style="background: #f8fafc; height: 100%; display: flex; flex-direction: column;">
        <div style="display: flex; background: #e2e8f0; border-radius: 6px; padding: 2px; margin-bottom: 6px;">
          <div style="flex: 1; text-align: center; background: white; color: #0d253f; font-weight: 700; border-radius: 4px; padding: 3px; font-size: 8.5px;">Timetable</div>
          <div style="flex: 1; text-align: center; color: #64748b; font-weight: 600; padding: 3px; font-size: 8.5px;">Attendance</div>
        </div>

        <div style="display: flex; justify-content: space-between; margin-bottom: 8px;">
          <span style="background: #0070f3; color: white; padding: 2px 7px; border-radius: 10px; font-weight: 700; font-size: 8px;">Mon</span>
          <span style="color: #64748b; font-size: 8px; padding: 2px;">Tue</span>
          <span style="color: #64748b; font-size: 8px; padding: 2px;">Wed</span>
          <span style="color: #64748b; font-size: 8px; padding: 2px;">Thu</span>
          <span style="color: #64748b; font-size: 8px; padding: 2px;">Fri</span>
        </div>

        <div class="mock-card" style="border-left: 3px solid #0070f3; padding: 6px 8px; margin-bottom: 5px;">
          <div style="display: flex; justify-content: space-between;">
            <span style="font-weight: 700; font-size: 9.5px; color: #0d253f;">Data Structures</span>
            <span style="font-size: 7.5px; color: #64748b;">08:30 - 10:30</span>
          </div>
          <div style="font-size: 7.5px; color: #64748b;">Hall A501 · Lecture</div>
        </div>

        <div style="border: 1px dashed #cbd5e1; border-radius: 6px; padding: 5px; text-align: center; margin: 5px 0; background: #f1f5f9;">
          <span style="font-size: 8px; color: #0284c7; font-weight: 700;">☕ 2h 00m Free Window</span>
          <div style="font-size: 7px; color: #64748b;">Perfect time for Library or Focus Session</div>
        </div>

        <div class="mock-card" style="border-left: 3px solid #fca311; padding: 6px 8px;">
          <div style="display: flex; justify-content: space-between;">
            <span style="font-weight: 700; font-size: 9.5px; color: #0d253f;">Database Systems</span>
            <span style="font-size: 7.5px; color: #64748b;">12:30 - 14:30</span>
          </div>
          <div style="font-size: 7.5px; color: #64748b;">Lab 03 · Practical Lab</div>
        </div>

        <div style="position: absolute; bottom: 12px; right: 12px; width: 32px; height: 32px; background: #fca311; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #0d253f; font-weight: 800; font-size: 16px; box-shadow: 0 4px 10px rgba(252,163,17,0.4);">
          +
        </div>
      </div>
    `,
    enPoints: [
      "Day Selector: Seamlessly filter lectures across Monday to Sunday.",
      "Free-Time Calculation: Smart banners automatically reveal free study windows.",
      "Conflict Detection: Amber warnings appear if any two sessions overlap in time.",
      "Add / Edit Class: Quick modal to configure subject, hall, time slot, and repetition."
    ],
    siPoints: [
      "දින තේරීම: සඳුදා සිට ඉරිදා දක්වා ඕනෑම දිනයක් තනි තට්ටුවකින් තෝරාගන්න.",
      "නිදහස් කාලය පෙන්වීම: දේශන දෙකක් අතර ඇති විවේක කාලය (Free Window) ස්වයංක්‍රීයව ගණනය වේ.",
      "කාල ගැටුම් (Conflicts): එකම වේලාවක දේශන දෙකක් යෙදුනහොත් අනතුරු අඟවයි.",
      "දේශන ඇතුළත් කිරීම: (+) බොත්තම මඟින් වේලාව, ශාලාව සහ දිනය ඇතුළත් කළ හැක."
    ],
    tableRows: [
      ["Add Class", "Tap (+) → Select Subject → Pick Time & Hall → Save.", "(+) ඔබන්න → විෂය තෝරන්න → වේලාව සහ ශාලාව ඇතුළත් කරන්න."],
      ["Edit Class", "Tap any class card to modify venue, lecturer or timing.", "කාඩ්පත තට්ටු කර ශාලාව හෝ වේලාව සංශෝධනය කරන්න."],
      ["Delete Class", "Long press class card → Confirm remove.", "කාඩ්පත මත මදක් ඔබාගෙන සිට මකාදමන්න."]
    ]
  },
  {
    num: "05",
    tag: "SCREEN 62 & 63",
    titleEn: "05. Attendance Tracking & Safe-Skip Formula",
    titleSi: "පැමිණීම සහ Safe-Skip ගණනය කිරීම",
    desc: "UniGuide eliminates end-of-semester attendance surprises by projecting safe skips and recovery requirements using strict 80% university standards.",
    mockup: `
      <div style="background: #f8fafc; height: 100%; display: flex; flex-direction: column;">
        <div style="font-weight: 700; color: #0d253f; font-size: 11px; margin-bottom: 6px;">Attendance Tracker</div>

        <div class="mock-card" style="border-left: 3px solid #2ec4b6; padding: 6px 8px; margin-bottom: 6px;">
          <div style="display: flex; justify-content: space-between;">
            <span style="font-weight: 700; font-size: 9.5px; color: #0d253f;">IT2030 - DSA</span>
            <span class="mock-badge badge-green" style="font-size: 7.5px;">91.6%</span>
          </div>
          <div style="font-size: 7.5px; color: #64748b; margin: 2px 0;">Attended 11 / 12 Held Sessions</div>
          <div style="background: #e6fffa; color: #047857; font-weight: 700; font-size: 7.5px; padding: 3px; border-radius: 4px; margin: 3px 0;">
            🛡️ Safe to skip: 2 more lectures
          </div>
          <div style="display: flex; gap: 4px; margin-top: 4px;">
            <div style="flex: 1; background: #2ec4b6; color: white; text-align: center; padding: 3px; border-radius: 4px; font-weight: 700; font-size: 7.5px;">+ Attended</div>
            <div style="flex: 1; background: #fee2e2; color: #991b1b; text-align: center; padding: 3px; border-radius: 4px; font-weight: 700; font-size: 7.5px;">Missed</div>
          </div>
        </div>

        <div class="mock-card" style="border-left: 3px solid #e5484d; padding: 6px 8px;">
          <div style="display: flex; justify-content: space-between;">
            <span style="font-weight: 700; font-size: 9.5px; color: #0d253f;">IT2040 - DBMS</span>
            <span class="mock-badge badge-red" style="font-size: 7.5px;">72.7%</span>
          </div>
          <div style="font-size: 7.5px; color: #64748b; margin: 2px 0;">Attended 8 / 11 Held Sessions</div>
          <div style="background: #fee2e2; color: #991b1b; font-weight: 700; font-size: 7.5px; padding: 3px; border-radius: 4px; margin: 3px 0;">
            ⚠️ Must attend next 3 lectures for 80%
          </div>
          <div style="display: flex; gap: 4px; margin-top: 4px;">
            <div style="flex: 1; background: #2ec4b6; color: white; text-align: center; padding: 3px; border-radius: 4px; font-weight: 700; font-size: 7.5px;">+ Attended</div>
            <div style="flex: 1; background: #fee2e2; color: #991b1b; text-align: center; padding: 3px; border-radius: 4px; font-weight: 700; font-size: 7.5px;">Missed</div>
          </div>
        </div>
      </div>
    `,
    enPoints: [
      "Safe-Skip Calculator: Shows exact number of classes you can miss without dropping below 80%.",
      "Deficit Recovery: Computes consecutive lectures you must attend if you are under 80%.",
      "One-Tap Marking: Quick '+ Attended' and 'Missed' buttons with instant undo safety.",
      "Date History: Full chronological log of every marked class session."
    ],
    siPoints: [
      "Safe-Skip ගණනය: 80% සීමාව රැකගනිමින් මඟහැරිය හැකි උපරිම දේශන ගණන.",
      "අවශ්‍ය දේශන ගණන: 80%ට අඩු නම් විභාග සුදුසුකම් නැවත ලබාගැනීමට යා යුතු දේශන ගණන.",
      "ක්ෂණික ලකුණු කිරීම: '+ පැමිණියා' හෝ 'නොපැමිණියා' තනි තට්ටුවෙන් ලකුණු කිරීම.",
      "ඉතිහාසය සහ Undo: වැරදීමකින් ලකුණු කළ පැමිණීමක් නැවත හැරවීමේ පහසුකම."
    ],
    tableRows: [
      ["Safe Status", "Green badge: Attendance > 80%. Safe skip available.", "කොළ පැහැය: 80%ට වැඩි ආරක්ෂිත මට්ටම."],
      ["Warning", "Amber badge: Exactly near 80%. Attend upcoming session.", "කහ පැහැය: අවධානයෙන් සිටිය යුතු සීමාව."],
      ["Critical Barred", "Red badge: Barred from exam unless recovery lectures met.", "රතු පැහැය: විභාග අවදානම් තත්ත්වය."]
    ]
  },
  {
    num: "06",
    tag: "SCREEN 65 & 66",
    titleEn: "06. Deadlines, Submissions & Urgency Badges",
    titleSi: "නියමිත දිනයන් සහ Assignment කළමනාකරණය",
    desc: "Track every academic submission, assignment, and quiz with urgency countdown badges and pre-due notifications so you never lose marks.",
    mockup: `
      <div style="background: #f8fafc; height: 100%; display: flex; flex-direction: column;">
        <div style="font-weight: 700; color: #0d253f; font-size: 11px; margin-bottom: 5px;">Coursework Deadlines</div>

        <div style="display: flex; gap: 4px; margin-bottom: 8px;">
          <span style="background: #0070f3; color: white; padding: 2px 6px; border-radius: 8px; font-size: 7px; font-weight: 700;">Upcoming (3)</span>
          <span style="background: #e2e8f0; color: #64748b; padding: 2px 6px; border-radius: 8px; font-size: 7px;">Overdue (0)</span>
          <span style="background: #e2e8f0; color: #64748b; padding: 2px 6px; border-radius: 8px; font-size: 7px;">Done (8)</span>
        </div>

        <div class="mock-card" style="border-left: 3px solid #e5484d; padding: 5px 8px; margin-bottom: 5px;">
          <div style="display: flex; justify-content: space-between;">
            <span class="mock-badge badge-red" style="font-size: 7px;">DUE IN 18 HOURS</span>
            <span style="font-size: 7px; color: #64748b;">Assignment</span>
          </div>
          <div style="font-weight: 700; color: #0d253f; font-size: 9.5px; margin-top: 3px;">Software Architecture Report</div>
          <div style="font-size: 7.5px; color: #64748b;">SE3020 · Tomorrow, 11:59 PM</div>
        </div>

        <div class="mock-card" style="border-left: 3px solid #fca311; padding: 5px 8px; margin-bottom: 5px;">
          <div style="display: flex; justify-content: space-between;">
            <span class="mock-badge badge-amber" style="font-size: 7px;">4 DAYS LEFT</span>
            <span style="font-size: 7px; color: #64748b;">Quiz</span>
          </div>
          <div style="font-weight: 700; color: #0d253f; font-size: 9.5px; margin-top: 3px;">Online Quiz 03 (SQL Joins)</div>
          <div style="font-size: 7.5px; color: #64748b;">IT2040 · Friday, 06:00 PM</div>
        </div>

        <div class="mock-card" style="border-left: 3px solid #2ec4b6; padding: 5px 8px;">
          <div style="display: flex; justify-content: space-between;">
            <span class="mock-badge badge-green" style="font-size: 7px;">14 DAYS LEFT</span>
            <span style="font-size: 7px; color: #64748b;">Project Viva</span>
          </div>
          <div style="font-weight: 700; color: #0d253f; font-size: 9.5px; margin-top: 3px;">Final Prototype Demo</div>
          <div style="font-size: 7.5px; color: #64748b;">CS2080 · 10 Nov, 09:00 AM</div>
        </div>
      </div>
    `,
    enPoints: [
      "Categorization: Assignment, Quiz, Lab Assessment, Viva, and Final Exam.",
      "Urgency Badging: Dynamic color cues (Red < 2 days, Amber < 7 days, Green > 7 days).",
      "Swipe to Complete: Swipe deadline card right to archive into Done folder.",
      "Local Reminders: High-priority push notifications 24h and 2h before deadline."
    ],
    siPoints: [
      "වර්ගීකරණය: Assignments, Quizzes, Lab Tests, Viva, සහ විභාග ලෙස වෙන් කිරීම.",
      "වර්ණ කේත: දින 2කට අඩු (රතු), දින 7කට අඩු (කහ), සහ ආරක්ෂිත (කොළ).",
      "Swipe කර අවසන් කිරීම: අවසන් කළ කාර්යයන් Swipe කර Done ලැයිස්තුවට යැවීම.",
      "ස්වයංක්‍රීය සිහිකැඳවීම්: පැය 24කට සහ පැය 2කට පෙර ලැබෙන Alarm Notifications."
    ],
    tableRows: [
      ["Create Deadline", "Tap (+) → Title → Module → Category → Date & Time → Save.", "(+) ඔබන්න → නම → විෂය → දිනය සහ වේලාව ඇතුළත් කරන්න."],
      ["Archive Task", "Tap circular checkbox or swipe right on item.", "චෙක්බොක්ස් එක ඔබන්න හෝ දකුණට Swipe කරන්න."],
      ["Filter View", "Toggle between Upcoming, Overdue, and Completed.", "ඉදිරියට ඇති, කල් ඉකුත් වූ, සහ අවසන් වූ ලෙස පෙරන්න."]
    ]
  },
  {
    num: "07",
    tag: "SCREEN 67 & 68",
    titleEn: "07. GPA Target Planner & What-If Simulator",
    titleSi: "GPA ඉලක්ක සැලසුම්කරු සහ What-If සිමියුලේටරය",
    desc: "Test what-if grade scenarios in real time to understand exactly what results you need before exam day.",
    mockup: `
      <div style="background: #f8fafc; height: 100%; display: flex; flex-direction: column; align-items: center;">
        <div style="font-weight: 700; color: #0d253f; font-size: 11px; align-self: flex-start; margin-bottom: 4px;">GPA Strategy Hub</div>

        <div style="width: 90px; height: 90px; border-radius: 50%; border: 7px solid #0070f3; display: flex; flex-direction: column; align-items: center; justify-content: center; margin: 8px 0; background: white;">
          <span style="font-size: 18px; font-weight: 800; color: #0d253f;">3.48</span>
          <span style="font-size: 7px; color: #64748b;">Target: 3.60</span>
        </div>

        <div class="mock-card" style="width: 100%; text-align: left; padding: 6px 8px;">
          <div style="font-size: 8px; font-weight: 700; color: #0d253f;">Remaining Credits: 18</div>
          <div style="font-size: 7.5px; color: #047857; font-weight: 600; margin-top: 2px;">
            🎯 Required Average: 3.72 (A / A-)
          </div>
        </div>

        <div style="background: #0d253f; color: white; width: 100%; border-radius: 8px; padding: 6px; text-align: center; margin-top: 8px; font-weight: 700; font-size: 8.5px;">
          Interactive What-If Simulator →
        </div>
      </div>
    `,
    enPoints: [
      "Visual GPA Gauge: Compare current GPA against your graduation target.",
      "Required Average Math: Computes necessary score across remaining credits for your target.",
      "Live What-If Simulator: Tap grade chips (A+, A, B, C) to project your GPA instantly.",
      "Class Honors Classification: Outlines 1st Class (3.70+), 2nd Upper (3.30+), and 2nd Lower."
    ],
    siPoints: [
      "GPA ප්‍රස්ථාරය: ඔබ ලබාගෙන ඇති GPA එක සහ ඉලක්ක GPA එක සංසන්දනය කරන්න.",
      "අවශ්‍ය සාමාන්‍යය: ඉලක්කය සපුරාගැනීමට ඉතිරි Credit වල ලබාගත යුතු අවම සාමාන්‍යය.",
      "What-If සිමියුලේටරය: විභාගයට පෙර A+, A, B ලැබුණහොත් අවසන් GPA එක කුමක්වේදැයි පරීක්ෂා කිරීම.",
      "සාමාර්ථ මට්ටම්: 1st Class (3.70+), 2nd Upper (3.30+) ආදී විශ්වවිද්‍යාල මට්ටම්."
    ],
    tableRows: [
      ["1st Class Honours", "GPA 3.70 - 4.00", "පළමු පෙළ සාමාර්ථය"],
      ["2nd Class Upper", "GPA 3.30 - 3.69", "දෙවන පෙළ ඉහළ සාමාර්ථය"],
      ["2nd Class Lower", "GPA 3.00 - 3.29", "දෙවන පෙළ පහළ සාමාර්ථය"]
    ]
  },
  {
    num: "08",
    tag: "SCREEN 69 & 70",
    titleEn: "08. Focus Timer & Study Session Analytics",
    titleSi: "Focus Timer සහ අධ්‍යයන කාල ප්‍රස්ථාර",
    desc: "Build productive academic habits with 25-minute Pomodoro study cycles and weekly analytics charts.",
    mockup: `
      <div style="background: #f8fafc; height: 100%; display: flex; flex-direction: column; align-items: center;">
        <div style="font-weight: 700; color: #0d253f; font-size: 11px; align-self: flex-start;">Pomodoro Focus</div>

        <div style="background: #fff7ed; border: 1px solid #fed7aa; color: #c2410c; padding: 2px 8px; border-radius: 16px; font-size: 7.5px; font-weight: 700; margin: 4px 0;">
          🔥 4-Day Study Streak!
        </div>

        <div style="width: 95px; height: 95px; border-radius: 50%; border: 7px solid #fca311; display: flex; flex-direction: column; align-items: center; justify-content: center; margin: 6px 0; background: white;">
          <span style="font-size: 20px; font-weight: 800; color: #0d253f;">24:18</span>
          <span style="font-size: 7px; color: #64748b;">DSA Revision</span>
        </div>

        <div style="display: flex; gap: 8px; margin-top: 4px;">
          <div style="background: #0d253f; color: white; padding: 4px 12px; border-radius: 6px; font-weight: 700; font-size: 8px;">Pause</div>
          <div style="background: #fee2e2; color: #991b1b; padding: 4px 12px; border-radius: 6px; font-weight: 700; font-size: 8px;">Cancel</div>
        </div>

        <div class="mock-card" style="width: 100%; margin-top: 10px; padding: 6px 8px;">
          <div style="font-size: 7.5px; font-weight: 700; color: #0d253f;">Weekly Study: 14.5 Hours</div>
          <div style="display: flex; justify-content: space-between; align-items: flex-end; height: 26px; margin-top: 4px; padding: 0 4px;">
            <div style="background: #0070f3; width: 8px; height: 60%; border-radius: 2px;"></div>
            <div style="background: #0070f3; width: 8px; height: 80%; border-radius: 2px;"></div>
            <div style="background: #0070f3; width: 8px; height: 40%; border-radius: 2px;"></div>
            <div style="background: #0070f3; width: 8px; height: 95%; border-radius: 2px;"></div>
            <div style="background: #fca311; width: 8px; height: 70%; border-radius: 2px;"></div>
          </div>
        </div>
      </div>
    `,
    enPoints: [
      "Module Tagging: Link study cycles to specific modules for detailed breakdowns.",
      "Study Streak: Stay motivated with consecutive study streak day counts.",
      "Weekly Bar Chart: Visual graph showing study duration from Monday to Sunday.",
      "Break Management: Automated alerts for 5-minute short and 15-minute long breaks."
    ],
    siPoints: [
      "විෂය අනුව පාඩම් කිරීම: සෑම විනාඩි 25ක සැසියක්ම අදාළ විෂයට සම්බන්ධ කරන්න.",
      "Streak වාර්තාව: දිනපතා පාඩම් කිරීම දිරිගන්වන Streak Badge එක.",
      "සතිපතා ප්‍රස්ථාරය: සතියේ සෑම දිනකම පාඩම් කළ මුළු පැය ගණන බලාගන්න.",
      "විවේක කාල කළමනාකරණය: විනාඩි 5ක සහ විනාඩි 15ක විවේක ස්වයංක්‍රීයව දැනුම්දීම."
    ],
    tableRows: [
      ["Start Session", "Choose Subject → Tap Start Focus → Work for 25 mins.", "විෂය තෝරන්න → Start ඔබන්න → මිනිත්තු 25ක් පාඩම් කරන්න."],
      ["Break Cycle", "Enjoy 5 min break, then repeat 4 cycles.", "මිනිත්තු 5ක විවේකය ගන්න, චක්‍ර 4ක් සම්පූර්ණ කරන්න."],
      ["View Analytics", "Inspect weekly charts to evaluate subject distribution.", "සතිපතා ප්‍රස්ථාර බලා වැඩිපුර කාලය යෙදවූ විෂයයන් හඳුනාගන්න."]
    ]
  },
  {
    num: "09",
    tag: "SCREEN 71 & 72",
    titleEn: "09. Board Snap (Lecture Whiteboard Camera & Vault)",
    titleSi: "දේශන පුවරු ඡායාරූප (Board Snap) සුරැකුම",
    desc: "Capture and categorize lecture whiteboards into subject-specific folders with high-resolution zooming and date metadata.",
    mockup: `
      <div style="background: #f8fafc; height: 100%; display: flex; flex-direction: column;">
        <div style="font-weight: 700; color: #0d253f; font-size: 11px; margin-bottom: 4px;">Board Snap Vault</div>
        <div style="font-size: 7px; color: #64748b; margin-bottom: 8px;">Organized whiteboards sorted by module</div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 6px;">
          <div class="mock-card" style="text-align: center; border-top: 3px solid #0070f3; padding: 6px 4px;">
            <div style="font-size: 14px;">📁</div>
            <div style="font-weight: 700; font-size: 8.5px; color: #0d253f;">IT2030 - DSA</div>
            <div style="font-size: 7px; color: #64748b;">14 Photos</div>
          </div>
          <div class="mock-card" style="text-align: center; border-top: 3px solid #fca311; padding: 6px 4px;">
            <div style="font-size: 14px;">📁</div>
            <div style="font-weight: 700; font-size: 8.5px; color: #0d253f;">IT2040 - DBMS</div>
            <div style="font-size: 7px; color: #64748b;">8 Photos</div>
          </div>
          <div class="mock-card" style="text-align: center; border-top: 3px solid #2ec4b6; padding: 6px 4px;">
            <div style="font-size: 14px;">📁</div>
            <div style="font-weight: 700; font-size: 8.5px; color: #0d253f;">SE3020 - SE</div>
            <div style="font-size: 7px; color: #64748b;">19 Photos</div>
          </div>
          <div class="mock-card" style="text-align: center; border-top: 3px solid #e5484d; padding: 6px 4px;">
            <div style="font-size: 14px;">📁</div>
            <div style="font-weight: 700; font-size: 8.5px; color: #0d253f;">CS2080 - OS</div>
            <div style="font-size: 7px; color: #64748b;">6 Photos</div>
          </div>
        </div>

        <div style="margin-top: auto; background: #0070f3; color: white; padding: 8px; border-radius: 10px; text-align: center; font-weight: 700; font-size: 9px;">
          📷 Snap Whiteboard Note
        </div>
      </div>
    `,
    enPoints: [
      "Subject Folders: Photos automatically save under the selected module folder.",
      "Pinch to Zoom: High-resolution viewer with full zoom capabilities for small handwritten notes.",
      "Date & Note Tags: Automatically tags images with lecture timestamps and keywords.",
      "Zero Clutter: Keeps personal mobile gallery clean from lecture whiteboard photos."
    ],
    siPoints: [
      "ස්වයංක්‍රීය ෆෝල්ඩර: ඡායාරූප අදාළ විෂයේ ෆෝල්ඩරයට පමණක් ගොනු වේ.",
      "විශාල කර බැලීම: Pinch-to-zoom මඟින් කුඩා අකුරු පවා ඉතා පැහැදිලිව කියවීම.",
      "දිනය සහ සටහන්: ඡායාරූපය ලබාගත් දිනය සහ වේලාව ස්වයංක්‍රීයව සටහන් වේ.",
      "දුරකථන ගැලරිය සුරැකීම: පුද්ගලික ඡායාරූප සමඟ මිශ්‍ර නොවී වෙන්ව පවතී."
    ],
    tableRows: [
      ["Capture Photo", "Tap 'Snap Whiteboard Note' → Select Subject → Snap & Save.", "'Snap Whiteboard Note' ඔබන්න → විෂය තෝරා ඡායාරූප ගන්න."],
      ["View Whiteboards", "Open Module Folder → Tap image to enter interactive zoom viewer.", "ෆෝල්ඩරය විවෘත කර ඡායාරූපය විශාල කර බලන්න."],
      ["Export & Share", "Share whiteboard notes directly to study groups or Drive.", "ඡායාරූපය Study Groups වෙත පහසුවෙන් Share කරන්න."]
    ]
  },
  {
    num: "10",
    tag: "SCREEN 73 - 75",
    titleEn: "10. Settings, ZIP Backups & Custom Academic Rules",
    titleSi: "සැකසුම්, උපස්ථ (Backup) සහ විභාග නීති",
    desc: "Take full ownership of your data with portable ZIP backups and custom academic grading rules.",
    mockup: `
      <div style="background: #f8fafc; height: 100%; display: flex; flex-direction: column;">
        <div style="font-weight: 700; color: #0d253f; font-size: 11px; margin-bottom: 6px;">Settings & Privacy</div>

        <div class="mock-card" style="padding: 5px 8px; margin-bottom: 5px;">
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <span style="font-size: 8.5px; font-weight: 700;">Language / භාෂාව</span>
            <span class="mock-badge badge-blue" style="font-size: 7px;">English / සිංහල</span>
          </div>
        </div>

        <div class="mock-card" style="padding: 5px 8px; margin-bottom: 5px;">
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <span style="font-size: 8.5px; font-weight: 700;">Theme Mode</span>
            <span class="mock-badge badge-amber" style="font-size: 7px;">Dark / Light</span>
          </div>
        </div>

        <div class="mock-card" style="border: 1px solid #0070f3; background: #f0f7ff; padding: 6px 8px;">
          <div style="font-weight: 700; font-size: 8.5px; color: #0070f3;">📦 Full Backup Archive (ZIP)</div>
          <div style="font-size: 7px; color: #475569; margin: 2px 0;">Export or restore all data including board photos</div>
          <div style="display: flex; gap: 4px; margin-top: 5px;">
            <div style="flex: 1; background: #0070f3; color: white; text-align: center; padding: 3px; border-radius: 4px; font-size: 7.5px; font-weight: 700;">Export ZIP</div>
            <div style="flex: 1; background: white; border: 1px solid #0070f3; color: #0070f3; text-align: center; padding: 3px; border-radius: 4px; font-size: 7.5px; font-weight: 700;">Import ZIP</div>
          </div>
        </div>

        <div style="margin-top: auto; text-align: center; font-size: 7.5px; color: #94a3b8;">
          UniGuide v1.0.0 (Offline Edition)<br>No tracking · No cloud
        </div>
      </div>
    `,
    enPoints: [
      "Bilingual Toggle: Switch seamlessly between 100% English and 100% pure Sinhala.",
      "Dark / Light Mode: Elegant dark theme optimized for late night study and battery saving.",
      "Export ZIP Backup: One-click export of database, timetable, study sessions, and whiteboard photos.",
      "Restore Archive: Effortless migration to any new mobile device in seconds."
    ],
    siPoints: [
      "ද්විභාෂා තේරීම: සම්පූර්ණ ඉංග්‍රීසි හෝ සම්පූර්ණ පිරිසිදු සිංහල භාෂාවට ක්ෂණිකව මාරුවීම.",
      "Dark Mode: රාත්‍රී කාලයේදී ඇස්වලට පහසු ආකර්ෂණීය Dark Theme එක.",
      "ZIP Backup ලබාගැනීම: ඔබගේ සියලු දත්ත සහ ඡායාරූප අඩංගු තනි ZIP ගොනුවක් Backup කරගැනීම.",
      "නැවත ප්‍රතිස්ථාපනය (Restore): දුරකථනය මාරු කළද පහසුවෙන් දත්ත නැවත ලබාගත හැක."
    ],
    tableRows: [
      ["Export Backup", "Saves uniguide_backup_*.zip to device storage.", "සියලු දත්ත අඩංගු ZIP ගොනුවක් සුරකියි."],
      ["Import Backup", "Restore previous backup onto new phone.", "පැරණි Backup එකක් නව දුරකථනයට ඇතුළත් කරයි."],
      ["Grading Rules", "Customize pass marks and attendance minimums.", "විභාග ලකුණු සහ පැමිණීමේ අවම සීමාවන් සකසන්න."]
    ]
  }
];

let pagesHtml = '';

sections.forEach((sec, idx) => {
  const pageNum = idx + 3;
  pagesHtml += `
  <div class="page-container page-break">
    <div class="doc-header">
      <div class="doc-header-left">
        <img src="${appIconBase64}" class="doc-header-logo" alt="UniGuide">
        <div>
          <div class="doc-header-title">${sec.titleEn}</div>
          <div class="doc-header-cat">${sec.titleSi}</div>
        </div>
      </div>
      <div class="badge-tag">${sec.tag} · Page ${pageNum}</div>
    </div>

    <div class="screen-showcase-container">
      <div class="phone-mockup">
        <div class="phone-notch"></div>
        <div class="phone-screen light-mode">
          ${sec.mockup}
        </div>
      </div>

      <div class="details-box">
        <div>
          <h2 style="font-size: 16px; color: #0d253f; margin: 0 0 4px 0;">${sec.titleEn}</h2>
          <p style="font-size: 11.5px; color: #475569; margin: 0 0 10px 0;">
            ${sec.desc}
          </p>

          <div class="bilingual-block">
            <div class="lang-en-box">
              <div class="lang-title">🇬🇧 What You Can Do</div>
              <ul class="feature-list">
                ${sec.enPoints.map(p => `<li>${p}</li>`).join('')}
              </ul>
            </div>
            <div class="lang-si-box">
              <div class="lang-title">🇱🇰 ඔබගේ හැකියාවන් (සිංහල)</div>
              <ul class="feature-list">
                ${sec.siPoints.map(p => `<li>${p}</li>`).join('')}
              </ul>
            </div>
          </div>
        </div>

        <table class="action-steps-table">
          <thead>
            <tr>
              <th style="width: 25%;">Feature / විශේෂාංගය</th>
              <th style="width: 38%;">Action (English)</th>
              <th style="width: 37%;">ක්‍රියාකාරී පියවර (සිංහල)</th>
            </tr>
          </thead>
          <tbody>
            ${sec.tableRows.map(r => `
              <tr>
                <td><strong>${r[0]}</strong></td>
                <td>${r[1]}</td>
                <td>${r[2]}</td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>
    </div>
  </div>
  `;
});

const fullHtml = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>UniGuide - Official User Manual & Guide Book</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&family=Noto+Sans+Sinhala:wght@400;500;600;700&family=JetBrains+Mono:wght@400;600&display=swap');

  @page {
    size: A4;
    margin: 10mm 12mm 12mm 12mm;
  }

  * {
    box-sizing: border-box;
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }

  body {
    font-family: 'Outfit', 'Noto Sans Sinhala', 'Nirmala UI', sans-serif;
    color: #1b2533;
    background: #f8fafc;
    margin: 0;
    padding: 0;
    line-height: 1.45;
    font-size: 12px;
  }

  .page-container {
    height: 1040px;
    max-height: 1040px;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }

  .page-break {
    page-break-after: always;
    break-after: page;
  }

  /* Cover Page */
  .cover {
    height: 1040px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    padding: 40px 30px;
    background: linear-gradient(135deg, #091326 0%, #0d253f 60%, #153e75 100%);
    color: white;
    border-radius: 20px;
    position: relative;
    overflow: hidden;
  }

  .cover::before {
    content: '';
    position: absolute;
    top: -100px;
    right: -100px;
    width: 450px;
    height: 450px;
    background: radial-gradient(circle, rgba(0, 112, 243, 0.35) 0%, transparent 70%);
    border-radius: 50%;
  }

  .cover-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid rgba(255,255,255,0.15);
    padding-bottom: 16px;
  }

  .badge-tag {
    background: rgba(253, 185, 19, 0.2);
    color: #fdb913;
    border: 1px solid rgba(253, 185, 19, 0.5);
    padding: 4px 12px;
    border-radius: 30px;
    font-weight: 700;
    font-size: 10px;
    letter-spacing: 1px;
    text-transform: uppercase;
  }

  .cover-body {
    text-align: center;
    margin: auto 0;
  }

  .cover-logo-img {
    width: 150px;
    height: 150px;
    border-radius: 34px;
    box-shadow: 0 16px 40px rgba(0,0,0,0.5), 0 0 50px rgba(0,112,243,0.4);
    margin-bottom: 20px;
    border: 3px solid rgba(255,255,255,0.2);
  }

  .cover-title {
    font-size: 42px;
    font-weight: 800;
    letter-spacing: -1px;
    margin: 0;
    background: linear-gradient(90deg, #ffffff, #88c2ff);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }

  .cover-tagline {
    font-size: 16px;
    color: #fdb913;
    font-weight: 600;
    margin-top: 8px;
    margin-bottom: 4px;
  }

  .cover-tagline-si {
    font-family: 'Noto Sans Sinhala', 'Nirmala UI', sans-serif;
    font-size: 14.5px;
    color: #cbd5e1;
    margin-bottom: 20px;
  }

  .cover-desc {
    max-width: 580px;
    margin: 0 auto;
    font-size: 12.5px;
    color: #94a3b8;
    line-height: 1.6;
  }

  .cover-footer {
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    border-top: 1px solid rgba(255,255,255,0.15);
    padding-top: 16px;
    font-size: 11px;
    color: #94a3b8;
  }

  /* Document Content Layout */
  .doc-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 2px solid #e2e8f0;
    padding-bottom: 8px;
    margin-bottom: 12px;
  }

  .doc-header-left {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .doc-header-logo {
    width: 30px;
    height: 30px;
    border-radius: 7px;
  }

  .doc-header-title {
    font-size: 14.5px;
    font-weight: 800;
    color: #0d253f;
    letter-spacing: -0.3px;
  }

  .doc-header-cat {
    font-size: 10.5px;
    color: #64748b;
    font-weight: 600;
  }

  /* Feature Grid & Screen Showcase */
  .screen-showcase-container {
    display: grid;
    grid-template-columns: 240px 1fr;
    gap: 16px;
    background: white;
    border: 1px solid #e2e8f0;
    border-radius: 14px;
    padding: 14px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.03);
    flex: 1;
  }

  /* Phone Mockup Canvas CSS */
  .phone-mockup {
    background: #0b1020;
    border-radius: 22px;
    border: 6px solid #1e293b;
    box-shadow: 0 8px 24px rgba(0,0,0,0.15);
    overflow: hidden;
    height: 440px;
    display: flex;
    flex-direction: column;
    color: white;
    position: relative;
    font-size: 10px;
  }

  .phone-notch {
    background: #1e293b;
    height: 14px;
    width: 80px;
    margin: 0 auto 3px auto;
    border-radius: 0 0 8px 8px;
  }

  .phone-screen {
    flex: 1;
    display: flex;
    flex-direction: column;
    padding: 8px 10px;
    overflow: hidden;
    position: relative;
  }

  .phone-screen.light-mode {
    background: #f8fafc;
    color: #0f172a;
  }

  /* Mock UI elements */
  .mock-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 8px;
    padding-bottom: 4px;
    border-bottom: 1px solid rgba(0,0,0,0.06);
  }

  .mock-card {
    background: white;
    border-radius: 8px;
    padding: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.04);
    border: 1px solid #e2e8f0;
    margin-bottom: 6px;
  }

  .mock-badge {
    display: inline-block;
    padding: 2px 5px;
    border-radius: 5px;
    font-size: 8px;
    font-weight: 700;
  }

  .badge-green { background: #d1fae5; color: #065f46; }
  .badge-amber { background: #fef3c7; color: #92400e; }
  .badge-red { background: #fee2e2; color: #991b1b; }
  .badge-blue { background: #dbeafe; color: #1e40af; }

  /* Explanation Columns */
  .details-box {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }

  .bilingual-block {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
    margin-bottom: 8px;
  }

  .lang-en-box, .lang-si-box {
    background: #f8fafc;
    border: 1px solid #e2e8f0;
    border-radius: 10px;
    padding: 10px 12px;
  }

  .lang-en-box { border-top: 3px solid #0070f3; }
  .lang-si-box { border-top: 3px solid #fca311; }

  .lang-title {
    font-size: 10.5px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 6px;
    display: flex;
    align-items: center;
    gap: 5px;
  }

  .lang-en-box .lang-title { color: #0070f3; }
  .lang-si-box .lang-title { color: #d97706; }

  .feature-list {
    margin: 0;
    padding-left: 14px;
    font-size: 11px;
    line-height: 1.45;
  }

  .feature-list li {
    margin-bottom: 4px;
  }

  .action-steps-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 10.5px;
    margin-top: 6px;
    background: white;
    border-radius: 8px;
    overflow: hidden;
    border: 1px solid #e2e8f0;
  }

  .action-steps-table th {
    background: #0d253f;
    color: white;
    padding: 6px 8px;
    text-align: left;
    font-weight: 600;
    font-size: 10px;
  }

  .action-steps-table td {
    padding: 6px 8px;
    border-bottom: 1px solid #f1f5f9;
  }

  .action-steps-table tr:last-child td {
    border-bottom: none;
  }

  .privacy-banner {
    background: #fffbeb;
    border: 1px solid #fde68a;
    color: #92400e;
    padding: 12px 16px;
    border-radius: 10px;
    margin-top: 14px;
  }

  /* Table of Contents */
  .toc-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
    margin-top: 12px;
  }

  .toc-item {
    background: white;
    border: 1px solid #e2e8f0;
    border-radius: 10px;
    padding: 10px 12px;
    display: flex;
    align-items: center;
    gap: 10px;
    box-shadow: 0 1px 4px rgba(0,0,0,0.02);
  }

  .toc-badge {
    background: #0d253f;
    color: #fdb913;
    font-size: 11px;
    font-weight: 800;
    padding: 4px 8px;
    border-radius: 6px;
  }

  .toc-title-en {
    font-weight: 700;
    font-size: 11.5px;
    color: #0f172a;
  }

  .toc-title-si {
    font-family: 'Noto Sans Sinhala', 'Nirmala UI', sans-serif;
    font-size: 10px;
    color: #64748b;
  }

</style>
</head>
<body>

<!-- PAGE 1: COVER PAGE -->
<div class="page-container page-break">
  <div class="cover">
    <div class="cover-header">
      <div style="font-weight: 800; letter-spacing: 1px; font-size: 13px; color: #88c2ff;">
        UNIGUIDE MOBILE APP
      </div>
      <div class="badge-tag">COMPLETE USER MANUAL · 2026</div>
    </div>

    <div class="cover-body">
      <img src="${appIconBase64}" class="cover-logo-img" alt="UniGuide Logo" />
      <h1 class="cover-title">UniGuide</h1>
      <div class="cover-tagline">Know where you stand. Plan what’s next.</div>
      <div class="cover-tagline-si">ඔබ සිටින තැන දැනගන්න. ඊළඟ පියවර සැලසුම් කරන්න.</div>
      <p class="cover-desc">
        A comprehensive bilingual reference and operator manual covering every single screen, feature, academic calculation rule, and privacy capability within the UniGuide student ecosystem.
      </p>
    </div>

    <div class="cover-footer">
      <div>
        <strong>Target Audience:</strong> University Students & Academics (SLIIT & Compatible Systems)<br>
        <strong>Data Privacy:</strong> 100% Offline · Local SQLite · Zero Tracking · No Cloud Dependency
      </div>
      <div style="text-align: right;">
        <strong>Version:</strong> 1.0.0 (Release Edition)<br>
        <strong>Languages:</strong> English & සිංහල (Dual Mode)
      </div>
    </div>
  </div>
</div>

<!-- PAGE 2: TABLE OF CONTENTS & OVERVIEW -->
<div class="page-container page-break">
  <div>
    <div class="doc-header">
      <div class="doc-header-left">
        <img src="${appIconBase64}" class="doc-header-logo" alt="UniGuide">
        <div>
          <div class="doc-header-title">UniGuide User Manual & Guide Book</div>
          <div class="doc-header-cat">Table of Contents & Architectural Overview</div>
        </div>
      </div>
      <div class="badge-tag">Page 2</div>
    </div>

    <h2 style="font-size: 18px; color: #0d253f; margin: 4px 0;">📋 Guide Contents / පටුන</h2>
    <div style="font-size: 11.5px; color: #475569; margin-bottom: 12px; border-left: 3px solid #0070f3; padding-left: 8px;">
      Quick navigation reference for all operational modules across UniGuide. / යෙදුමේ සියලුම මොඩියුල සඳහා ඉක්මන් මාර්ගෝපදේශය.
    </div>

    <div class="toc-grid">
      ${sections.map(s => `
        <div class="toc-item">
          <div class="toc-badge">${s.num}</div>
          <div>
            <div class="toc-title-en">${s.titleEn}</div>
            <div class="toc-title-si">${s.titleSi}</div>
          </div>
        </div>
      `).join('')}
    </div>
  </div>

  <div class="privacy-banner">
    <div style="font-weight: 700; font-size: 12.5px; margin-bottom: 3px;">🛡️ 100% Privacy Guarantee / 100% දත්ත රහස්‍යභාවය</div>
    <div style="font-size: 11px; line-height: 1.5;">
      <strong>English:</strong> UniGuide does not track, collect, or transmit your academic records. All database tables (Modules, Attendance, Timetable, Deadlines, Study logs) remain exclusively on your device within encrypted SQLite. You can export/import full ZIP backups at any time.<br>
      <strong>සිංහල:</strong> UniGuide කිසිදු ආකාරයකින් ඔබගේ පෞද්ගලික තොරතුරු පිටතට නොයවයි. සියලුම දත්ත ඔබගේ දුරකථනයේ පමණක් සුරැකෙන අතර ඕනෑම මොහොතක සම්පූර්ණ ZIP Backup එකක් ලබාගත හැක.
    </div>
  </div>
</div>

<!-- PAGES 3 TO 12: 10 MODULE SCREENS -->
${pagesHtml}

<!-- PAGE 13: BACK COVER / CLOSING -->
<div class="page-container">
  <div class="cover" style="justify-content: center; text-align: center;">
    <div style="max-width: 580px; margin: auto;">
      <img src="${appIconBase64}" style="width: 100px; height: 100px; border-radius: 24px; box-shadow: 0 10px 30px rgba(0,0,0,0.4); margin-bottom: 16px;">
      <h1 style="font-size: 34px; margin: 0; color: white;">UniGuide</h1>
      <div style="color: #fdb913; font-weight: 700; font-size: 15px; margin: 8px 0;">Empowering Higher Education Students</div>
      
      <div style="background: rgba(255,255,255,0.08); border-radius: 14px; padding: 20px; margin: 20px 0; border: 1px solid rgba(255,255,255,0.15); text-align: left; font-size: 12px; line-height: 1.7;">
        <div style="color: #cbd5e1; margin-bottom: 8px;">
          <strong>English Summary:</strong> UniGuide is built to eliminate academic anxiety. By consolidating attendance risks, timetable gaps, countdown deadlines, GPA forecasts, and study timers into one beautiful, privacy-centric app, students can focus purely on academic excellence.
        </div>
        <div style="color: #94a3b8; font-family: 'Noto Sans Sinhala', 'Nirmala UI', sans-serif;">
          <strong>සිංහල සාරාංශය:</strong> UniGuide නිර්මාණය කර ඇත්තේ විශ්වවිද්‍යාල සිසුන්ගේ අධ්‍යයන කටයුතු වඩාත් පහසු සහ ක්‍රමවත් කිරීම සඳහාය. පැමිණීමේ අවදානම්, කාලසටහන්, Assignment Deadlines, GPA අනාවැකි සහ Study Timer එකම තැනකින් ලබාදෙන 100% නොබැඳි පුද්ගලික මෙවලමකි.
        </div>
      </div>

      <div style="color: #64748b; font-size: 11px;">
        Designed & Developed with Flutter · 100% Offline Architecture<br>
        Colombo, Sri Lanka · 2026 Edition · Version 1.0.0
      </div>
    </div>
  </div>
</div>

</body>
</html>
`;

fs.writeFileSync(path.join(__dirname, 'manual.html'), fullHtml, 'utf8');
console.log('manual.html updated cleanly with fixed A4 height!');
