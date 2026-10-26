import os
import sys
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import inch, cm
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, Image, KeepTogether, HRFlowable
)
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

# Base directories
DOCS_DIR = r"c:\Users\HP\Desktop\CampusCompress\docs"
ASSETS_DIR = os.path.join(DOCS_DIR, "manual_assets")
FONTS_DIR = r"c:\Users\HP\Desktop\CampusCompress\assets\fonts"
OUT_PDF_PATH = r"c:\Users\HP\Desktop\CampusCompress\UniGuide_User_Manual_Guide_Book.pdf"
DOCS_PDF_PATH = os.path.join(DOCS_DIR, "UniGuide_User_Manual_Guide_Book.pdf")

# Register TrueType Fonts for English and Sinhala
pdfmetrics.registerFont(TTFont('NotoSinhala', os.path.join(FONTS_DIR, 'NotoSansSinhala-Regular.ttf')))
pdfmetrics.registerFont(TTFont('NotoSinhala-Bold', os.path.join(FONTS_DIR, 'NotoSansSinhala-Bold.ttf')))
pdfmetrics.registerFont(TTFont('Poppins', os.path.join(FONTS_DIR, 'Poppins-Regular.ttf')))
pdfmetrics.registerFont(TTFont('Poppins-Bold', os.path.join(FONTS_DIR, 'Poppins-Bold.ttf')))
pdfmetrics.registerFont(TTFont('Inter', os.path.join(FONTS_DIR, 'Inter-Regular.ttf')))
pdfmetrics.registerFont(TTFont('Inter-Bold', os.path.join(FONTS_DIR, 'Inter-SemiBold.ttf')))

# Color Palette (Premium UniGuide Theme)
NAVY = colors.HexColor('#0F172A')
BLUE = colors.HexColor('#2563EB')
AMBER = colors.HexColor('#F59E0B')
EMERALD = colors.HexColor('#10B981')
INDIGO = colors.HexColor('#6366F1')
CARD_BG = colors.HexColor('#F8FAFC')
BORDER_COLOR = colors.HexColor('#E2E8F0')
TEXT_DARK = colors.HexColor('#1E293B')
TEXT_MUTED = colors.HexColor('#64748B')
LIGHT_BLUE = colors.HexColor('#EFF6FF')
LIGHT_GREEN = colors.HexColor('#ECFDF5')
LIGHT_INDIGO = colors.HexColor('#EEF2FF')

# Numbered canvas for footer and page numbers
class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super(NumberedCanvas, self).__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super(NumberedCanvas, self).showPage()
        super(NumberedCanvas, self).save()

    def draw_page_decorations(self, page_count):
        if self._pageNumber == 1:
            return  # Suppress headers/footers on cover

        self.saveState()
        self.setFont("Inter", 8)
        self.setFillColor(TEXT_MUTED)

        # Header
        self.drawString(36, 810, "UniGuide · Campus Academic Companion · Official User Manual")
        self.setStrokeColor(BORDER_COLOR)
        self.setLineWidth(0.5)
        self.line(36, 804, 559, 804)

        # Footer
        self.line(36, 40, 559, 40)
        self.drawString(36, 28, "100% Offline Architecture · Built with Flutter · 2026 Edition")
        page_str = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(559, 28, page_str)
        self.restoreState()

def create_manual():
    doc = SimpleDocTemplate(
        OUT_PDF_PATH,
        pagesize=A4,
        leftMargin=36,
        rightMargin=36,
        topMargin=46,
        bottomMargin=46
    )

    styles = getSampleStyleSheet()
    
    # Custom Typography Styles
    title_style = ParagraphStyle(
        'CoverTitle',
        parent=styles['Normal'],
        fontName='Poppins-Bold',
        fontSize=30,
        leading=36,
        textColor=NAVY,
        alignment=1
    )

    subtitle_style = ParagraphStyle(
        'CoverSubtitle',
        parent=styles['Normal'],
        fontName='NotoSinhala-Bold',
        fontSize=13,
        leading=18,
        textColor=BLUE,
        alignment=1
    )

    h1_style = ParagraphStyle(
        'Heading1Custom',
        parent=styles['Normal'],
        fontName='Poppins-Bold',
        fontSize=18,
        leading=22,
        textColor=NAVY,
        spaceAfter=4
    )

    h1_si_style = ParagraphStyle(
        'Heading1SiCustom',
        parent=styles['Normal'],
        fontName='NotoSinhala-Bold',
        fontSize=13,
        leading=17,
        textColor=BLUE,
        spaceAfter=8
    )

    desc_style = ParagraphStyle(
        'DescCustom',
        parent=styles['Normal'],
        fontName='Inter',
        fontSize=9.5,
        leading=14,
        textColor=TEXT_DARK,
        spaceAfter=10
    )

    section_header_style = ParagraphStyle(
        'SectionHeader',
        parent=styles['Normal'],
        fontName='Poppins-Bold',
        fontSize=11,
        leading=15,
        textColor=NAVY,
        spaceAfter=4
    )

    body_en = ParagraphStyle(
        'BodyEn',
        parent=styles['Normal'],
        fontName='Inter',
        fontSize=8.5,
        leading=12.5,
        textColor=TEXT_DARK
    )

    body_si = ParagraphStyle(
        'BodySi',
        parent=styles['Normal'],
        fontName='NotoSinhala',
        fontSize=8.5,
        leading=13.5,
        textColor=TEXT_DARK
    )

    step_cell_en = ParagraphStyle(
        'StepCellEn',
        parent=styles['Normal'],
        fontName='Inter',
        fontSize=8,
        leading=11.5,
        textColor=TEXT_DARK
    )

    step_cell_si = ParagraphStyle(
        'StepCellSi',
        parent=styles['Normal'],
        fontName='NotoSinhala',
        fontSize=8,
        leading=12,
        textColor=TEXT_DARK
    )

    story = []

    # ================= PAGE 1: COVER PAGE =================
    story.append(Spacer(1, 40))
    app_icon_path = os.path.join(ASSETS_DIR, "app_icon.png")
    if os.path.exists(app_icon_path):
        story.append(Image(app_icon_path, width=90, height=90))
    story.append(Spacer(1, 16))

    story.append(Paragraph("UniGuide", title_style))
    story.append(Paragraph("AI-Powered Campus Academic Companion & Female Voice Solver", ParagraphStyle(
        'CoverSubEn', parent=styles['Normal'], fontName='Poppins-Bold', fontSize=14, leading=18, textColor=INDIGO, alignment=1
    )))
    story.append(Spacer(1, 6))
    story.append(Paragraph("සම්පූර්ණ පරිශීලක අත්පොත සහ මඟපෙන්වීම් ග්‍රන්ථය (Official User Guide Book)", subtitle_style))
    story.append(Spacer(1, 25))

    # Executive Summary Card
    exec_text = """<b>Welcome to UniGuide:</b> Designed specifically for higher education university students, UniGuide brings together smart GPA planning, strict 80% attendance safe-skip predictions, countdown coursework deadlines, Pomodoro study focus tracking, and a breakthrough <b>Live AI Camera Question Solver with authentic Dual-Language Female Voice explanation (English &amp; Sinhala)</b>.<br/><br/><b>සාදරයෙන් පිළිගනිමු:</b> විශ්වවිද්‍යාල සිසුන්ගේ අධ්‍යයන ජීවිතය පහසු හා සාර්ථක කරවීම සඳහා නිර්මාණය වූ UniGuide මඟින් ඔබේ විභාග සුදුසුකම්, GPA ඉලක්ක, Assignment දින සටහන්, පාඩම් කාලසටහන් මෙන්ම <b>කැමරාවෙන් ප්‍රශ්න ස්කෑන් කර සිංහලෙන් හා ඉංග්‍රීසියෙන් කටහඬින් පිළිතුරු දෙන සුවිශේෂී AI කැමරා තාක්ෂණය</b> එකම තැනකින් ලබාදෙයි."""
    exec_table = Table([[Paragraph(exec_text, body_si)]], colWidths=[520])
    exec_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), LIGHT_INDIGO),
        ('BOX', (0,0), (-1,-1), 1.5, INDIGO),
        ('PADDING', (0,0), (-1,-1), 16),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ]))
    story.append(exec_table)
    story.append(Spacer(1, 30))

    meta_text = """<b>Product Version:</b> v1.0.0 (AI Edition) &nbsp;·&nbsp; <b>Architecture:</b> 100% Privacy-Preserving Offline Engine &nbsp;·&nbsp; <b>Release:</b> 2026<br/><b>Platform:</b> Android &amp; iOS &nbsp;·&nbsp; <b>Developer:</b> UniGuide Engineering Team"""
    story.append(Paragraph(meta_text, ParagraphStyle(
        'CoverMeta', parent=styles['Normal'], fontName='Inter', fontSize=8.5, leading=14, textColor=TEXT_MUTED, alignment=1
    )))
    story.append(PageBreak())

    # ================= PAGE 2: TABLE OF CONTENTS & QUICK START =================
    story.append(Paragraph("Table of Contents · අන්තර්ගතය", h1_style))
    story.append(Paragraph("UniGuide ප්‍රධාන අංශ සහ විශේෂාංග ලැයිස්තුව", h1_si_style))
    story.append(HRFlowable(width="100%", thickness=1, color=BORDER_COLOR, spaceAfter=14))

    toc_data = [
        ["#", "Core Feature / ප්‍රධාන විශේෂාංගය", "English Description", "සිංහල විස්තරය", "Page"],
        ["01", "AI Camera & Voice Solver", "Real OCR Question Recognition with Female Voice", "කැමරාවෙන් ප්‍රශ්න හඳුනාගැනීම සහ කාන්තා කටහඬ", "3"],
        ["02", "App Onboarding & Audio Welcome", "Initial brand setup, audio intro, elastic motion", "ආරම්භක පිහිටුවීම් සහ කටහඬ සුබපැතුම", "4"],
        ["03", "Setup Wizard & Module Intake", "Configure modules, credit weights & attendance", "විෂයයන්, ක්‍රෙඩිට් සහ දේශන ඇතුළත් කිරීම", "5"],
        ["04", "Home Dashboard (Live Command)", "Real-time countdown to next class & alerts", "මීළඟ දේශනය, සජීවී නිවේදන සහ ඉක්මන් සාරාංශය", "6"],
        ["05", "Timetable & Free-Time Windows", "Weekly lecture slots & 2-hour free time gaps", "සතිපතා කාලසටහන සහ නිදහස් විවේක කාල කවුළු", "7"],
        ["06", "Attendance & Safe-Skip Formula", "80% threshold math: exact safe misses", "80% සීමාව සහ මඟහැරිය හැකි ආරක්ෂිත දේශන ගණන", "8"],
        ["07", "Coursework Deadlines & Urgency", "Urgent countdown badges: <48h warnings", "පැවරුම් (Assignments), Quizzes සහ දින සටහන්", "9"],
        ["08", "GPA Target Planner & What-If", "Graduation honors, required avg & simulator", "GPA ඉලක්ක සහ විභාගයට පෙර What-If අනුකරණය", "10"],
        ["09", "Pomodoro Timer & Study Analytics", "25-min focus sessions, daily streaks, charts", "මිනිත්තු 25 පාඩම් ටයිමරය සහ සතිපතා වාර්තා", "11"],
        ["10", "Board Snap Vault & Flashcards", "Whiteboard photo categorizer & smart study cards", "දේශන පුවරු ඡායාරූප සුරැකුම සහ Flashcards", "12"],
        ["11", "AI Study Schedule & Health Score", "Daily briefings, GPA roadmap & assistant", "ස්වයංක්‍රීය අධ්‍යයන සැලසුම් සහ AI උපදේශක", "13"],
        ["12", "ZIP Backup, Restore & Privacy", "Full device export, restore and academic rules", "සම්පූර්ණ ZIP Backup සහ 100% නොබැඳි රහස්‍යභාවය", "14"],
    ]

    toc_table = Table(toc_data, colWidths=[24, 130, 160, 170, 36])
    toc_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), NAVY),
        ('TEXTCOLOR', (0,0), (-1,0), colors.white),
        ('FONTNAME', (0,0), (-1,0), 'Poppins-Bold'),
        ('FONTSIZE', (0,0), (-1,0), 8),
        ('ALIGN', (0,0), (0,-1), 'CENTER'),
        ('ALIGN', (-1,0), (-1,-1), 'CENTER'),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('GRID', (0,0), (-1,-1), 0.5, BORDER_COLOR),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, CARD_BG]),
        ('FONTNAME', (0,1), (-1,-1), 'NotoSinhala'),
        ('FONTSIZE', (0,1), (-1,-1), 7.5),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(toc_table)
    story.append(PageBreak())

    # ================= MANUAL CHAPTERS =================
    chapters = [
        {
            "num": "01",
            "titleEn": "AI Camera Question Recognition & Dual-Language Female Voice Solver",
            "titleSi": "AI කැමරා ප්‍රශ්න හඳුනාගැනීම සහ ද්විභාෂා කාන්තා කටහඬ විසඳුම්කරු",
            "desc": "The flagship AI Vision Solver leverages Google ML Kit on-device optical character recognition (OCR) and an intelligent academic logic engine. When you point your camera at any tutorial, exam question, or math problem, UniGuide extracts the exact text, calculates verified step-by-step solutions, and speaks out loud using natural female speech in both English and Sinhala.",
            "howToEn": [
                "<b>1. Open Solver:</b> Tap the prominent <b>AI Question Camera & Voice 🎙️</b> banner on the Home dashboard or navigate to Boards → AI Camera Solver.",
                "<b>2. Align Frame:</b> Position the tutorial problem or handwritten formula inside the illuminated holographic laser reticle.",
                "<b>3. Select Mode:</b> Filter subject domain (Mathematics, Computer Science, Physics, General) from the top chips.",
                "<b>4. Capture or Type:</b> Tap the purple <b>Scan & Voice Solve 🎙️</b> button. If the lighting is dim, tap the <b>✏️ (Type Question)</b> button to write directly (e.g., '45 * 12', 'dy/dx of 3x^2', 'Binary search time complexity').",
                "<b>5. Listen & Learn:</b> The solution card pops up instantly with confidence metrics, step-by-step breakdown, and automatic female voice narration. Toggle between <b>Female EN 🇬🇧</b> and <b>Female SI 🇱🇰</b> anytime!"
            ],
            "howToSi": [
                "<b>1. පිවිසීම:</b> මුල් පිටුවේ ඇති <b>AI Question Camera & Voice 🎙️</b> කාඩ්පත තට්ටු කර කැමරා තිරය විවෘත කරන්න.",
                "<b>2. ප්‍රශ්නය යොමු කිරීම:</b> කැමරා රාමුව තුළ ඇති ලේසර් සීමාවට අදාළ ප්‍රශ්නය හෝ ගණිත සමීකරණය කෙළින් තබන්න.",
                "<b>3. විෂය තේරීම:</b> ඉහළින් ඇති Mathematics, Computer Science, Physics ආදී විෂයයන් අතුරින් ඔබට අවශ්‍ය ක්ෂේත්‍රය තෝරන්න.",
                "<b>4. ස්කෑන් කිරීම හෝ ලිවීම:</b> දම් පැහැති <b>Scan & Voice Solve 🎙️</b> බොත්තම ඔබන්න. ආලෝකය අඩු නම් පහළ වම්පස ඇති <b>✏️ බොත්තම</b> ඔබා ප්‍රශ්නය කෙලින්ම Type කරන්න (උදා: 45 * 12, 100 / 4, dy/dx).",
                "<b>5. කටහඬින් සවන් දීම:</b> නිවැරදි පිළිතුර, පියවරෙන් පියවර ගණනය කිරීම සහ විභාග උපදෙස් (Exam Tip) තිරයේ දිස්වන අතර ස්වභාවික කාන්තා හඬින් සිංහලෙන් හෝ ඉංග්‍රීසියෙන් විස්තර කරනු ලැබේ."
            ],
            "tips": [
                ["Feature / විධානය", "User Action (English)", "පරිශීලක ක්‍රියාමාර්ගය (සිංහල)"],
                ["Audio Language Toggle", "Select 'Female SI 🇱🇰' or 'Female EN 🇬🇧' from the top right bar.", "ඉහළ දකුණු පසින් සිංහල හෝ ඉංග්‍රීසි කටහඬ තෝරාගන්න."],
                ["Manual Question Override", "Tap pencil icon (✏️) at bottom left to type or correct questions.", "පහළ වම්පස පෑන අයිකනය ඔබා ඕනෑම ප්‍රශ්නයක් ලියන්න."],
                ["Voice Pause / Replay", "Tap Play/Pause button on the floating audio player bar.", "කටහඬ තාවකාලිකව නැවැත්වීමට හෝ නැවත ඇසීමට Play ඔබන්න."]
            ]
        },
        {
            "num": "02",
            "titleEn": "App Launch, Brand Audio & Onboarding Flow",
            "titleSi": "යෙදුම විවෘත කිරීම, ශ්‍රව්‍ය සුබපැතුම සහ Onboarding පිවිසුම",
            "desc": "UniGuide welcomes every student with a signature tactile experience. Upon launching the app, a soothing female voice greets you ('Uni Guide') while the compass logo performs a smooth physics-based elastic spring animation.",
            "howToEn": [
                "<b>1. Launch App:</b> Tap the UniGuide app icon on your home screen or app drawer.",
                "<b>2. Voice Welcome:</b> Listen to the clear female introductory chime verifying audio readiness.",
                "<b>3. Feature Highlights:</b> Swipe through the introductory slider showcasing Attendance safe-skips, Countdown deadlines, What-If GPA planner, and AI Board Snap.",
                "<b>4. Start Journey:</b> Tap <b>Let's begin / ආරම්භ කරමු</b> to launch the semester intake wizard."
            ],
            "howToSi": [
                "<b>1. යෙදුම විවෘත කිරීම:</b> ඔබගේ දුරකථනයේ UniGuide ලාංඡනය තට්ටු කර යෙදුමට පිවිසෙන්න.",
                "<b>2. කටහඬ පිළිගැනීම:</b> 'Uni Guide' යන පැහැදිලි කාන්තා කටහඬ පිළිගැනීම ශ්‍රවණය කරන්න.",
                "<b>3. විශේෂාංග සාරාංශය:</b> තිරය Swipe කරමින් පැමිණීම, Assignment Deadlines සහ GPA මෙවලම් පිළිබඳ තොරතුරු බලන්න.",
                "<b>4. ආරම්භ කිරීම:</b> <b>'ආරම්භ කරමු' (Let's begin)</b> බොත්තම තට්ටු කර නව අධ්‍යයන වාරය සකස් කරගන්න."
            ],
            "tips": [
                ["Feature / විධානය", "User Action (English)", "පරිශීලක ක්‍රියාමාර්ගය (සිංහල)"],
                ["Language Selection", "Switch between English and Sinhala at any time during onboarding.", "Onboarding තිරයේදීම භාෂාව තෝරාගැනීමේ හැකියාව."],
                ["Offline Startup", "No sign-in, OTP, or cloud account needed. Starts instantly.", "කිසිදු Password හෝ ගිණුමක් අවශ්‍ය නැත. ක්ෂණිකව විවෘත වේ."]
            ]
        },
        {
            "num": "03",
            "titleEn": "Setup Wizard & Module Intake System",
            "titleSi": "ප්‍රථම පිහිටුවීම් සහ මොඩියුල ඇතුළත් කිරීමේ පද්ධතිය",
            "desc": "Before semester classes begin, define your enrolled modules. Each module stores its official code, credit weighting (1-6), planned total lectures, and target grade to feed the automated GPA engine and 80% attendance formulas.",
            "howToEn": [
                "<b>1. Add Module:</b> Enter subject code (e.g. IT2030, SE3020) and full module name.",
                "<b>2. Credit Weight:</b> Set credits (typically 2, 3, or 4 credits). Credits determine how heavily this subject impacts your final GPA.",
                "<b>3. Planned Total Lectures:</b> Enter expected total sessions (e.g. 14 lectures for a 14-week term). This is essential for the Safe-Skip algorithm.",
                "<b>4. Target Grade:</b> Choose your personal expectation (A+, A, A-, B+).",
                "<b>5. Save & Proceed:</b> Tap 'Continue to Timetable' to lock in your semester curriculum."
            ],
            "howToSi": [
                "<b>1. විෂය කේතය:</b> නිල විෂය කේතය (Module Code - උදා: IT2030) සහ නම ඇතුළත් කරන්න.",
                "<b>2. ක්‍රෙඩිට් අගය:</b> විෂයට අදාළ Credit ප්‍රමාණය (2, 3 හෝ 4) තෝරන්න. මෙය GPA ගණනයට අත්‍යවශ්‍ය වේ.",
                "<b>3. මුළු දේශන ගණන:</b> අධ්‍යයන වාරයේ පැවැත්වෙන මුළු දේශන ගණන (උදා: 14) සටහන් කරන්න.",
                "<b>4. ඉලක්ක ශ්‍රේණිය:</b> ඔබ ලබාගැනීමට බලාපොරොත්තු වන ශ්‍රේණිය (A+, A, B+) තෝරන්න.",
                "<b>5. ඉදිරියට යන්න:</b> සියලු විෂයයන් එක් කළ පසු 'Continue to Timetable' ඔබන්න."
            ],
            "tips": [
                ["Field / ක්ෂේත්‍රය", "Recommended Setting (English)", "නිර්දේශිත සැකසුම (සිංහල)"],
                ["Module Code", "Use standard faculty codes e.g. CS2010.", "විශ්වවිද්‍යාලයේ නිල කේතය භාවිත කරන්න."],
                ["Credits", "Higher credit modules deserve more focus in your GPA plan.", "වැඩි ක්‍රෙඩිට් ඇති විෂයයන් සඳහා වැඩි අවධානයක් දෙන්න."]
            ]
        },
        {
            "num": "04",
            "titleEn": "Home Dashboard (Live Command Center)",
            "titleSi": "මුල් පුවරුව (Next Class සහ Quick Status)",
            "desc": "The home screen acts as your academic command center. It recalculates the current time upon opening to show your upcoming lecture, urgent deadlines within 48 hours, overall attendance safety, and one-tap AI shortcuts.",
            "howToEn": [
                "<b>1. Next Class Card:</b> Displays real-time countdown (e.g. 'NEXT UP IN 35 MIN'), lecture hall (e.g. Hall B402), and lecturer.",
                "<b>2. Live In-Progress Badge:</b> If you open the app while a lecture is running, a pulsating emerald badge notifies you that class is in progress.",
                "<b>3. Urgent Deadlines:</b> Red alerts flag any coursework due within 48 hours.",
                "<b>4. Attendance Gauge:</b> Instant traffic-light health badge (Green = Safe, Amber = Warning, Red = Danger)."
            ],
            "howToSi": [
                "<b>1. මීළඟ දේශනය (Next Class):</b> මීළඟට පැවැත්වෙන දේශනය, ශාලාව සහ ඉතිරි කාලය ගණනය කර පෙන්වයි.",
                "<b>2. සජීවී දේශන දැනුම්දීම:</b> මේ මොහොතේ දේශනයක් පැවැත්වේ නම් සජීවීව 'IN PROGRESS' ලකුණ පෙන්වයි.",
                "<b>3. හදිසි පැවරුම් (Urgent Deadlines):</b> පැය 48ක් ඇතුළත භාරදිය යුතු Assignment රතු පැහැයෙන් පෙන්වයි.",
                "<b>4. පැමිණීමේ සෞඛ්‍යය:</b> ඔබගේ පැමිණීම ආරක්ෂිතද යන්න එක බැල්මකින් වර්ණ මඟින් පෙන්වයි."
            ],
            "tips": [
                ["Action / ක්‍රියාව", "User Step (English)", "පරිශීලක පියවර (සිංහල)"],
                ["Tap Next Class Card", "Jumps directly to today's interactive timetable schedule.", "අද දවසේ දේශන ලැයිස්තුවට කෙලින්ම පිවිසෙන්න."],
                ["Tap Quick AI Assistant", "Launches the on-screen AI chatbot for academic advice.", "AI අධ්‍යයන සහායකයා විවෘත කිරීමට Bot අයිකනය ඔබන්න."]
            ]
        },
        {
            "num": "05",
            "titleEn": "Weekly Timetable & Free-Time Optimization",
            "titleSi": "සතිපතා දේශන කාලසටහන සහ නිදහස් කාල කවුළු",
            "desc": "Manage your entire weekly schedule effortlessly. UniGuide automatically identifies free-time gaps between consecutive lectures (e.g., '2h 00m Free Window'), empowering you to schedule productive study sessions in the library.",
            "howToEn": [
                "<b>1. Day Tabs:</b> Select any day (Monday to Sunday) to view scheduled classes.",
                "<b>2. Free-Time Banners:</b> Dashed highlight boxes automatically compute breaks between classes.",
                "<b>3. Conflict Warning:</b> If two lectures accidentally share the same time slot, an amber conflict warning prompts you to correct it.",
                "<b>4. Add Class:</b> Tap the floating (+) button, choose module, select day and start/end time, assign venue, and tap Save."
            ],
            "howToSi": [
                "<b>1. දින තේරීම:</b> සඳුදා සිට ඉරිදා දක්වා දිනයන් තෝරා දේශන වේලාවන් පරීක්ෂා කරන්න.",
                "<b>2. විවේක කාල කවුළු:</b> දේශන දෙකක් අතර ඇති නිදහස් කාලය (උදා: පැය 2ක විවේකය) ස්වයංක්‍රීයව පෙන්වයි.",
                "<b>3. කාල ගැටුම් අනතුරු ඇඟවීම:</b> එකම වේලාවට දේශන 2ක් යෙදුනහොත් වහාම අනතුරු අඟවයි.",
                "<b>4. දේශනයක් එක් කිරීම:</b> පහළ (+) බොත්තම ඔබා විෂය, ශාලාව සහ වේලාව ඇතුළත් කර Save කරන්න."
            ],
            "tips": [
                ["Action / ක්‍රියාව", "User Step (English)", "පරිශීලක පියවර (සිංහල)"],
                ["Edit / Delete Class", "Tap any class card to edit venue, or long-press to delete.", "කාඩ්පත තට්ටු කර සංස්කරණය කරන්න හෝ Long-press කර මකන්න."],
                ["Schedule Study Break", "Tap on a Free Window banner to start a 25-min Pomodoro session.", "විවේක කාලය තුළ පාඩම් කිරීමට Pomodoro Timer එක අරඹන්න."]
            ]
        },
        {
            "num": "06",
            "titleEn": "Attendance Tracking & Strict 80% Safe-Skip Formula",
            "titleSi": "පැමිණීම ලකුණු කිරීම සහ 80% Safe-Skip සූත්‍රය",
            "desc": "Never face an exam debarment penalty. UniGuide models university attendance rules to calculate your exact 'Safe Skips' (how many lectures you can miss without dropping below 80%) or 'Recovery Lectures' needed to regain eligibility.",
            "howToEn": [
                "<b>1. Safe-Skip Count:</b> If your attendance is above 80%, a green badge tells you exactly: 'Safe to skip: X more lectures'.",
                "<b>2. Deficit Alert:</b> If you drop below 80%, an amber/red warning displays: 'Must attend next Y lectures consecutively to regain 80%'.",
                "<b>3. Quick Marking:</b> Tap <b>+ Attended</b> or <b>Missed</b> after every lecture.",
                "<b>4. Instant Undo:</b> Made a mistake? A floating snackbar allows immediate 1-tap Undo without corrupting records."
            ],
            "howToSi": [
                "<b>1. Safe-Skip ගණන:</b> ඔබගේ පැමිණීම 80%ට වැඩි නම්, 'තව දේශන X ක් මඟහැරිය හැක' යන ආරක්ෂිත ගණන පෙන්වයි.",
                "<b>2. අඩු පැමිණීම් අනතුරු ඇඟවීම:</b> 80%ට අඩු වූ විට, සුදුසුකම් ලැබීමට 'ඉදිරි දේශන Y ප්‍රමාණයට නොකඩවා සහභාගී විය යුතුය' යනුවෙන් දන්වයි.",
                "<b>3. ලකුණු කිරීම:</b> සෑම දේශනයකින් පසු <b>+ Attended</b> හෝ <b>Missed</b> ඔබන්න.",
                "<b>4. Undo පහසුකම:</b> වැරදීමකින් ලකුණු කළහොත් පහළින් එන Undo බොත්තම ඔබා ක්ෂණිකව නිවැරදි කරගත හැක."
            ],
            "tips": [
                ["Status / තත්ත්වය", "Threshold & Formula (English)", "අර්ථය (සිංහල)"],
                ["Safe (Green)", "Attendance >= 80%. Safe skip > 0.", "80% ට ඉහළ ආරක්ෂිත මට්ටම."],
                ["Warning (Amber)", "Attendance near 80%. No more safe skips.", "අවධානයෙන් සිටිය යුතු සීමාව."],
                ["Debarred Risk (Red)", "Attendance < 80%. Recovery required.", "විභාගය අහිමිවීමේ දැඩි අවදානම."]
            ]
        },
        {
            "num": "07",
            "titleEn": "Coursework Deadlines & Urgency Categorization",
            "titleSi": "පැවරුම් නියමිත දිනයන් සහ හදිසි කාර්යයන් කළමනාකරණය",
            "desc": "Keep track of every assignment, lab assessment, online quiz, project viva, and exam. UniGuide categorizes each submission by time urgency to prevent late penalty deductions.",
            "howToEn": [
                "<b>1. Urgency Colors:</b> RED = Due in < 48 hours; AMBER = Due in 2 to 7 days; GREEN = Safe (> 7 days).",
                "<b>2. Add Deadline:</b> Tap (+), type title (e.g. 'REST API Architecture Report'), link module, set deadline date & time.",
                "<b>3. Swipe to Complete:</b> Swipe any completed coursework card to the right to celebrate and move it to the 'Done' archive.",
                "<b>4. Local Alarms:</b> Receive high-priority notifications 24 hours and 2 hours before submission."
            ],
            "howToSi": [
                "<b>1. හදිසි වර්ණ සංඥා:</b> රතු = පැය 48ට අඩු; කහ = දින 2-7 අතර; කොළ = දින 7ට වැඩි ආරක්ෂිත කාලය.",
                "<b>2. පැවරුමක් ඇතුළත් කිරීම:</b> (+) ඔබා නම, විෂය, සහ අවසන් දිනය/වේලාව සටහන් කර සුරකින්න.",
                "<b>3. අවසන් කිරීම (Complete):</b> අවසන් කළ Assignment එකක් දකුණට Swipe කිරීමෙන් Done ලැයිස්තුවට යැවිය හැක.",
                "<b>4. සිහිකැඳවීම් (Notifications):</b> පැවරුම භාරදීමට පැය 24කට සහ පැය 2කට පෙර ලැබෙන ස්වයංක්‍රීය Notifications."
            ],
            "tips": [
                ["Category / වර්ගය", "Usage (English)", "භාවිතය (සිංහල)"],
                ["Assignment / Quiz", "Tag specific task types for focused filtering.", "කාර්යය අනුව වෙන් කර පහසුවෙන් සොයාගන්න."],
                ["Filter Tabs", "Switch between Upcoming, Overdue, and Completed.", "ඉදිරියට ඇති, ප්‍රමාද වූ, හෝ අවසන් වූ ලෙස පෙරන්න."]
            ]
        },
        {
            "num": "08",
            "titleEn": "GPA Target Planner & Interactive What-If Simulator",
            "titleSi": "GPA ඉලක්ක සැලසුම්කරු සහ What-If සිමියුලේටරය",
            "desc": "Eliminate graduation anxiety with realistic mathematical projections. View your cumulative GPA progress toward 1st Class Honours (3.70+) or 2nd Class Upper (3.30+), and simulate exam grades before sitting for finals.",
            "howToEn": [
                "<b>1. Circular GPA Dial:</b> Displays your current cumulative GPA and your graduation target.",
                "<b>2. Required Average:</b> Dynamically calculates the exact GPA you must average across your remaining credits to reach your goal.",
                "<b>3. What-If Simulator:</b> Tap 'What-If Planner'. Adjust projected grades (A+, A, B, C) for current subjects and watch your projected GPA update in real time!",
                "<b>4. Degree Classification:</b> Outlines 1st Class (3.70 - 4.00), 2nd Upper (3.30 - 3.69), 2nd Lower (3.00 - 3.29), and General Pass."
            ],
            "howToSi": [
                "<b>1. GPA ප්‍රස්ථාරය:</b> ඔබ දැනට ලබා ඇති GPA එක සහ ඉලක්ක GPA එක එකවර සංසන්දනය කරන්න.",
                "<b>2. අවශ්‍ය සාමාන්‍යය:</b> ඉලක්කය කරා ළඟාවීමට ඉදිරි විෂයයන් සඳහා ලබාගත යුතු අවම සාමාන්‍ය ලකුණු මට්ටම.",
                "<b>3. What-If සිමියුලේටරය:</b> විභාගයට පෙර විෂයයන්ට A, B හෝ C ලැබුණහොත් අවසන් GPA එක කුමක්වේදැයි සජීවීව පරීක්ෂා කිරීම.",
                "<b>4. උපාධි සාමාර්ථ:</b> 1st Class (3.70+), 2nd Upper (3.30+) ආදී නිල සාමාර්ථ මට්ටම් පරීක්ෂා කරන්න."
            ],
            "tips": [
                ["Classification / සාමාර්ථය", "GPA Range (English)", "අවශ්‍ය GPA අගය (සිංහල)"],
                ["1st Class Honours", "3.70 - 4.00", "පළමු පෙළ සාමාර්ථය (3.70 - 4.00)"],
                ["2nd Class Upper", "3.30 - 3.69", "දෙවන පෙළ ඉහළ සාමාර්ථය (3.30 - 3.69)"],
                ["2nd Class Lower", "3.00 - 3.29", "දෙවන පෙළ පහළ සාමාර්ථය (3.00 - 3.29)"]
            ]
        },
        {
            "num": "09",
            "titleEn": "Pomodoro Focus Timer & Study Session Analytics",
            "titleSi": "Pomodoro Focus Timer සහ අධ්‍යයන කාල ප්‍රස්ථාර",
            "desc": "Build an elite study habit. UniGuide features a distraction-free 25-minute Pomodoro focus clock linked directly to your modules, complete with study streak tracking and weekly analytics.",
            "howToEn": [
                "<b>1. Tag Module:</b> Select which subject you are revising (e.g. Data Structures).",
                "<b>2. Start Clock:</b> Tap 'Start Focus' to initiate the 25-minute study interval.",
                "<b>3. Break Chimes:</b> Enjoy a 5-minute restorative short break after each session, followed by a 15-minute long break every 4 cycles.",
                "<b>4. Daily Streak:</b> Keep your flame streak burning by completing at least one session every day.",
                "<b>5. Weekly Bar Chart:</b> Inspect total study hours across the week from Monday through Sunday."
            ],
            "howToSi": [
                "<b>1. විෂය තේරීම:</b> පාඩම් කිරීමට බලාපොරොත්තු වන විෂය තෝරන්න (උදා: Data Structures).",
                "<b>2. ටයිමරය ඇරඹීම:</b> මිනිත්තු 25ක නොබෙදුණු අවධානය සඳහා 'Start Focus' ඔබන්න.",
                "<b>3. විවේක කාලය:</b> සෑම සැසියකටම පසු මිනිත්තු 5ක විවේකයක් සහ සැසි 4කට පසු මිනිත්තු 15ක දිගු විවේකයක් ලබාදෙයි.",
                "<b>4. Study Streak:</b> දිනපතා පාඩම් කිරීම මඟින් ඔබේ Streak Badge එක නොකඩවා පවත්වාගන්න.",
                "<b>5. සතිපතා ප්‍රස්ථාරය:</b> සතියේ සෑම දිනකම පාඩම් කළ මුළු පැය ගණන ප්‍රස්ථාර මඟින් පරීක්ෂා කරන්න."
            ],
            "tips": [
                ["Feature / අංගය", "Best Practice (English)", "හොඳම භාවිතය (සිංහල)"],
                ["Module Distribution", "Check weekly charts to avoid neglecting difficult modules.", "අමාරු විෂයයන් මඟහැරී ඇත්දැයි ප්‍රස්ථාරයෙන් හඳුනාගන්න."],
                ["Full Screen Focus", "Keep your phone face-down to eliminate social media distraction.", "පාඩම් කරන අතරතුර දුරකථනයෙන් වෙනත් යෙදුම් භාවිතයෙන් වළකින්න."]
            ]
        },
        {
            "num": "10",
            "titleEn": "Board Snap Vault & AI Exam Flashcards",
            "titleSi": "දේශන පුවරු සුරැකුම (Board Snap) සහ AI Flashcards",
            "desc": "Never let valuable whiteboard notes get lost in your camera roll. Board Snap automatically sorts lecture snapshots into subject folders with pinch-to-zoom support, and converts notes into interactive study flashcards.",
            "howToEn": [
                "<b>1. Snap Whiteboard:</b> Tap 'Board Snap', select current module, and take a photo of the whiteboard.",
                "<b>2. High-Res Zoom:</b> Open any saved snapshot in the pinch-to-zoom interactive viewer to read fine mathematical notations.",
                "<b>3. Module Folders:</b> Whiteboard images are automatically categorized into neat subject vaults (e.g. IT2030, DBMS).",
                "<b>4. AI Flashcards:</b> Tap 'AI Flashcards' to flip through question-and-answer study cards generated for active recall."
            ],
            "howToSi": [
                "<b>1. ඡායාරූප ගැනීම:</b> 'Board Snap' තෝරා අදාළ විෂය යටතේ දේශන පුවරුවේ ඡායාරූපයක් ලබාගන්න.",
                "<b>2. විශාල කර බැලීම:</b> Pinch-to-zoom මඟින් පුවරුවේ ලියූ කුඩා සටහන් පවා පැහැදිලිව කියවන්න.",
                "<b>3. විෂය ෆෝල්ඩර:</b> ඡායාරූප ඔබගේ සාමාන්‍ය ගැලරිය සමඟ මිශ්‍ර නොවී අදාළ විෂය ෆෝල්ඩරයේ පමණක් සුරැකේ.",
                "<b>4. AI Flashcards:</b> විභාගයට සූදානම් වීම සඳහා විෂය කරුණු මතක් කරදෙන Flashcards පෙරළා පාඩම් කරන්න."
            ],
            "tips": [
                ["Action / ක්‍රියාව", "User Step (English)", "පරිශීලක පියවර (සිංහල)"],
                ["Export Photo", "Share whiteboard notes directly to study groups via WhatsApp/Drive.", "Study Groups වෙත පුවරු සටහන් පහසුවෙන් Share කරන්න."],
                ["Flip Flashcard", "Tap anywhere on a flashcard to reveal the answer.", "පිළිතුර බලාගැනීමට Flashcard එක මත තට්ටු කරන්න."]
            ]
        },
        {
            "num": "11",
            "titleEn": "AI Study Schedule, Daily Briefing & GPA Roadmap",
            "titleSi": "ස්වයංක්‍රීය AI අධ්‍යයන සැලසුම් සහ දෛනික වාර්තාව",
            "desc": "Take advantage of 5 built-in AI student companion features: Daily Academic Briefing, AI Academic Assistant Chat, Adaptive Weekly Study Schedule, AI GPA Target Roadmap, and Board Snap Flashcards.",
            "howToEn": [
                "<b>1. Daily Academic Briefing:</b> Check your Morning Briefing card on the Home screen for your composite Academic Health Score (0-100) and today's priorities.",
                "<b>2. AI Academic Chat:</b> Tap the floating Bot icon to ask questions about study tips, time management, and exam strategy.",
                "<b>3. Adaptive Study Schedule:</b> Tap 'AI Schedule' to receive a customized weekly timetable balancing heavy modules, deadline urgency, and free periods.",
                "<b>4. AI GPA Target Roadmap:</b> Generates a custom module-by-module grade pathway to hit your target degree classification."
            ],
            "howToSi": [
                "<b>1. දෛනික සාරාංශය (Daily Briefing):</b> මුල් තිරයේ ඇති Academic Health Score (0-100) සහ අද දවසේ ප්‍රමුඛතා පරීක්ෂා කරන්න.",
                "<b>2. AI අධ්‍යයන සහායකයා:</b> විභාග උපදෙස් සහ කාල කළමනාකරණය සඳහා AI Chatbot සමඟ කතාබස් කරන්න.",
                "<b>3. ස්වයංක්‍රීය කාලසටහන:</b> ඔබගේ අමාරු විෂයයන් සහ Assignment දින සලකා බලා සකස් කළ සතිපතා පාඩම් සැලසුම ලබාගන්න.",
                "<b>4. GPA මාර්ග සිතියම:</b> ඔබගේ ඉලක්ක උපාධි මට්ටමට ළඟාවීමට එක් එක් විෂයට ගත යුතු ලකුණු මඟපෙන්වීම ලබාගන්න."
            ],
            "tips": [
                ["AI Feature / අංගය", "Benefit (English)", "වාසිය (සිංහල)"],
                ["Health Score", "Aggregates attendance % and study streak into one score.", "ඔබගේ අධ්‍යයන සාර්ථකත්වය 100න් පෙන්වන අගය."],
                ["Offline Brain", "All algorithmic intelligence runs 100% on-device.", "අන්තර්ජාලය නොමැතිව වුවද සැලසුම් සකස් කරගත හැක."]
            ]
        },
        {
            "num": "12",
            "titleEn": "Settings, Portable ZIP Backups & Custom Academic Rules",
            "titleSi": "සැකසුම්, සම්පූර්ණ ZIP උපස්ථ (Backup) සහ විභාග නීති",
            "desc": "Your academic data is your property. UniGuide includes zero tracking, zero cloud telemetry, and a built-in ZIP archive manager enabling you to export and restore all data with one tap.",
            "howToEn": [
                "<b>1. Language Toggle:</b> Switch instantly between 100% Pure English and 100% Pure Sinhala.",
                "<b>2. Dark & Light Theme:</b> Protect your eyes during late-night study sessions with our sleek AMOLED dark theme.",
                "<b>3. Export ZIP Backup:</b> Tap 'Export ZIP'. Saves a portable file containing your full database, timetable, study records, and whiteboard photos.",
                "<b>4. Restore ZIP Backup:</b> Moving to a new phone? Tap 'Import ZIP', pick your backup file, and your entire academic life is restored in seconds!",
                "<b>5. Custom Academic Rules:</b> Customize university pass marks and attendance minimums."
            ],
            "howToSi": [
                "<b>1. භාෂාව මාරු කිරීම:</b> සම්පූර්ණ ඉංග්‍රීසි හෝ සම්පූර්ණ සිංහල භාෂාවට ඕනෑම මොහොතක මාරුවන්න.",
                "<b>2. Dark Mode:</b> රාත්‍රී කාලයේදී ඇස්වලට වෙහෙසක් නොවන AMOLED Dark Theme එක සක්‍රීය කරන්න.",
                "<b>3. ZIP Backup ලබාගැනීම:</b> 'Export ZIP' ඔබන්න. ඔබගේ සියලු දත්ත සහ ඡායාරූප අඩංගු තනි ZIP ගොනුවක් ඔබගේ දුරකථනයේ සුරැකේ.",
                "<b>4. Backup එකක් නැවත ඇතුළත් කිරීම (Restore):</b> නව දුරකථනයකට මාරු වන විට 'Import ZIP' මඟින් තත්පර කිහිපයකින් පැරණි දත්ත නැවත ලබාගන්න.",
                "<b>5. විභාග නීති සැකසීම:</b> ඔබේ විශ්වවිද්‍යාලයේ අවම පැමිණීමේ සීමාවන් සහ ලකුණු මට්ටම් වෙනස් කරන්න."
            ],
            "tips": [
                ["Setting / සැකසුම", "Function (English)", "කාර්යය (සිංහල)"],
                ["Export ZIP", "Creates timestamped backup file in your phone storage.", "දුරකථන මතකයේ Backup ගොනුව සුරකියි."],
                ["Zero Cloud Policy", "No external servers. Your data stays 100% private.", "දත්ත පිටතට නොයන උපරිම පෞද්ගලික ආරක්ෂාව."]
            ]
        }
    ]

    for chap in chapters:
        story.append(Paragraph(f"{chap['num']}. {chap['titleEn']}", h1_style))
        story.append(Paragraph(chap['titleSi'], h1_si_style))
        story.append(HRFlowable(width="100%", thickness=1, color=BORDER_COLOR, spaceAfter=8))
        story.append(Paragraph(chap['desc'], desc_style))

        # Two-column steps: English on Left, Sinhala on Right
        col_en_content = [Paragraph("🇬🇧 Step-by-Step Instructions (English)", section_header_style)]
        for pt in chap['howToEn']:
            col_en_content.append(Paragraph(f"• {pt}", body_en))
            col_en_content.append(Spacer(1, 4))

        col_si_content = [Paragraph("🇱🇰 පියවරෙන් පියවර මඟපෙන්වීම (සිංහල)", section_header_style)]
        for pt in chap['howToSi']:
            col_si_content.append(Paragraph(f"• {pt}", body_si))
            col_si_content.append(Spacer(1, 4))

        col_table = Table([[col_en_content, col_si_content]], colWidths=[255, 255])
        col_table.setStyle(TableStyle([
            ('BACKGROUND', (0,0), (0,-1), LIGHT_BLUE),
            ('BACKGROUND', (1,0), (1,-1), LIGHT_GREEN),
            ('BOX', (0,0), (0,-1), 0.5, BLUE),
            ('BOX', (1,0), (1,-1), 0.5, EMERALD),
            ('PADDING', (0,0), (-1,-1), 10),
            ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ]))
        story.append(col_table)
        story.append(Spacer(1, 10))

        # Action Steps / Reference Table
        table_rows = []
        for r_idx, r in enumerate(chap['tips']):
            if r_idx == 0:
                table_rows.append([
                    Paragraph(f"<b>{r[0]}</b>", step_cell_en),
                    Paragraph(f"<b>{r[1]}</b>", step_cell_en),
                    Paragraph(f"<b>{r[2]}</b>", step_cell_si)
                ])
            else:
                table_rows.append([
                    Paragraph(f"<b>{r[0]}</b>", step_cell_en),
                    Paragraph(r[1], step_cell_en),
                    Paragraph(r[2], step_cell_si)
                ])

        action_table = Table(table_rows, colWidths=[120, 200, 200])
        action_table.setStyle(TableStyle([
            ('BACKGROUND', (0,0), (-1,0), NAVY),
            ('TEXTCOLOR', (0,0), (-1,0), colors.white),
            ('GRID', (0,0), (-1,-1), 0.5, BORDER_COLOR),
            ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, CARD_BG]),
            ('PADDING', (0,0), (-1,-1), 5),
            ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ]))
        story.append(action_table)
        story.append(PageBreak())

    # ================= BACK COVER / CONCLUSION =================
    story.append(Spacer(1, 80))
    if os.path.exists(app_icon_path):
        story.append(Image(app_icon_path, width=80, height=80))
    story.append(Spacer(1, 16))
    story.append(Paragraph("UniGuide", title_style))
    story.append(Paragraph("Know Where You Stand. Plan What's Next.", ParagraphStyle(
        'CoverSub2', parent=styles['Normal'], fontName='Poppins-Bold', fontSize=13, leading=16, textColor=AMBER, alignment=1
    )))
    story.append(Spacer(1, 20))

    closing_text = """<b>Empowering University Students Across Sri Lanka:</b><br/>UniGuide is crafted to turn academic stress into structured clarity. Whether verifying your attendance safe-skips before a trip, anticipating deadlines before late deductions, testing What-If GPA scores before study weeks, or snapping whiteboard problems for instant AI speech explanations in Sinhala, UniGuide is your faithful daily companion.<br/><br/><b>විශ්වවිද්‍යාල අධ්‍යාපනය වඩාත් සාර්ථක කරගන්න:</b><br/>විභාග සුදුසුකම්, නිදහස් කාලසටහන්, Assignment දිනයන් සහ GPA ඉලක්ක මෙන්ම කැමරාවෙන් ප්‍රශ්න ස්කෑන් කර සිංහලෙන් හා ඉංග්‍රීසියෙන් පිළිතුරු දෙන AI තාක්ෂණය තුළින් ඔබගේ උපාධිය සාර්ථකව නිම කිරීමට UniGuide නිරතුරුවම ඔබ ළඟින් සිටී."""
    closing_table = Table([[Paragraph(closing_text, body_si)]], colWidths=[500])
    closing_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), CARD_BG),
        ('BOX', (0,0), (-1,-1), 1, BORDER_COLOR),
        ('PADDING', (0,0), (-1,-1), 16),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ]))
    story.append(closing_table)
    story.append(Spacer(1, 40))

    story.append(Paragraph("""<b>UniGuide Campus Academic Companion · 100% Offline Edition</b><br/>Colombo, Sri Lanka · 2026 Edition · Official User Manual &amp; Guide Book""", ParagraphStyle('ClosingFooter', parent=styles['Normal'], fontName='Inter', fontSize=8.5, leading=14, textColor=TEXT_MUTED, alignment=1)))

    # Build PDF using NumberedCanvas
    doc.build(story, canvasmaker=NumberedCanvas)
    
    # Copy to docs directory as well
    if os.path.exists(OUT_PDF_PATH):
        with open(OUT_PDF_PATH, 'rb') as f_in:
            data = f_in.read()
            with open(DOCS_PDF_PATH, 'wb') as f_out:
                f_out.write(data)
        print(f"SUCCESS: Generated {len(data)} bytes user manual PDF at {OUT_PDF_PATH} and {DOCS_PDF_PATH}")

if __name__ == '__main__':
    create_manual()
