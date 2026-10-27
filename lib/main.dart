import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TarteelApp()));
}

class C {
  static const bg = Color(0xFF070A0D);
  static const panel = Color(0xFF10171B);
  static const panel2 = Color(0xFF192329);
  static const neon = Color(0xFFB6FF3B);
  static const muted = Color(0xFF93A29B);
  static const red = Color(0xFFFF657A);
  static const blue = Color(0xFF53B7FF);
}

final practiceCount = StateProvider<int>((ref) => 0);

class TarteelApp extends StatelessWidget {
  const TarteelApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Tarteel AI',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: C.bg,
      colorScheme: const ColorScheme.dark(primary: C.neon, secondary: C.blue, surface: C.panel),
      useMaterial3: true,
      cardTheme: CardThemeData(color: C.panel, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF253238)))),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: C.panel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
    ),
    home: const SplashScreen(),
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainAppScreen()));
    });
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(0, -.2), radius: 1.1, colors: [Color(0xFF20351A), C.bg])),
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 88, height: 88, decoration: BoxDecoration(color: C.neon.withOpacity(.1), borderRadius: BorderRadius.circular(27), border: Border.all(color: C.neon.withOpacity(.65)), boxShadow: [BoxShadow(color: C.neon.withOpacity(.15), blurRadius: 35)]), child: const Icon(Icons.graphic_eq_rounded, size: 46, color: C.neon)),
        const SizedBox(height: 22),
        const Text('TARTEEL AI', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 3)),
        const SizedBox(height: 8),
        const Text('RECITATION • MEMORIZATION • PROGRESS', style: TextStyle(color: C.muted, fontSize: 10, letterSpacing: 1)),
      ])),
    ),
  );
}

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});
  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}
class _MainAppScreenState extends State<MainAppScreen> {
  int selected = 0;
  final screens = const [RecitationScreen(), MemorizationScreen(), MistakesLogScreen()];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Row(children: [Icon(Icons.graphic_eq_rounded, color: C.neon), SizedBox(width: 10), Text('TARTEEL AI', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.3, fontSize: 17))]),
      actions: [IconButton(onPressed: () => showModalBottomSheet(context: context, backgroundColor: C.panel, showDragHandle: true, builder: (_) => const ProgressSheet()), icon: const Icon(Icons.insights_rounded, color: C.neon), tooltip: 'Progress')]),
    body: SafeArea(child: IndexedStack(index: selected, children: screens)),
    bottomNavigationBar: NavigationBar(selectedIndex: selected, onDestinationSelected: (i) => setState(() => selected = i), backgroundColor: C.panel, indicatorColor: C.neon.withOpacity(.15), destinations: const [
      NavigationDestination(icon: Icon(Icons.mic_none_rounded), selectedIcon: Icon(Icons.mic_rounded), label: 'Recitation'),
      NavigationDestination(icon: Icon(Icons.psychology_alt_outlined), selectedIcon: Icon(Icons.psychology_alt_rounded), label: 'Memorize'),
      NavigationDestination(icon: Icon(Icons.fact_check_outlined), selectedIcon: Icon(Icons.fact_check_rounded), label: 'Mistakes'),
    ]),
  );
}

class RecitationScreen extends StatefulWidget {
  const RecitationScreen({super.key});
  @override
  State<RecitationScreen> createState() => _RecitationScreenState();
}
class _RecitationScreenState extends State<RecitationScreen> {
  bool active = false, complete = false;
  int seconds = 0;
  Timer? timer;
  String surah = 'Al-Fatiha';
  final surahs = const ['Al-Fatiha', 'Al-Ikhlas', 'Al-Falaq', 'An-Nas', 'Al-Asr'];
  final verses = const ['بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', 'الرَّحْمَٰنِ الرَّحِيمِ', 'مَالِكِ يَوْمِ الدِّينِ', 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ'];
  String get durationText {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return m + ':' + s;
  }
  void start() {
    setState(() { active = true; complete = false; });
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() => seconds++); });
  }
  Future<void> finish() async {
    timer?.cancel();
    setState(() { active = false; complete = true; });
    final prefs = await SharedPreferences.getInstance();
    final total = (prefs.getInt('practice_count') ?? 0) + 1;
    await prefs.setInt('practice_count', total);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Practice session saved • Total: $total'), backgroundColor: C.panel2));
  }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 24), children: [
    const Eyebrow('YOUR DAILY RECITATION'), const SizedBox(height: 8),
    const Text('Find your rhythm.', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
    const SizedBox(height: 7), const Text('Practice calmly. Track consistency. Improve one verse at a time.', style: TextStyle(color: C.muted, height: 1.5)),
    const SizedBox(height: 20),
    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF23351C), C.panel]), border: Border.all(color: C.neon.withOpacity(.35))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Expanded(child: Text('RECITATION SESSION', style: TextStyle(color: C.neon, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 11))), Text(active ? '● LIVE' : 'READY', style: TextStyle(color: active ? C.neon : C.muted, fontSize: 10, fontWeight: FontWeight.bold))]),
      const SizedBox(height: 16), Text(durationText, style: const TextStyle(fontSize: 43, fontWeight: FontWeight.w900)),
      const Text('Session duration', style: TextStyle(color: C.muted, fontSize: 12)), const SizedBox(height: 18),
      Row(children: [
        Expanded(child: FilledButton.icon(onPressed: active ? null : start, icon: const Icon(Icons.play_arrow_rounded), label: Text(complete ? 'Practice again' : 'Start practice'), style: FilledButton.styleFrom(backgroundColor: C.neon, foregroundColor: C.bg, padding: const EdgeInsets.symmetric(vertical: 14)))),
        const SizedBox(width: 10), IconButton.filledTonal(onPressed: active ? finish : null, icon: const Icon(Icons.stop_rounded), tooltip: 'Finish session', style: IconButton.styleFrom(backgroundColor: C.panel2, foregroundColor: C.neon, padding: const EdgeInsets.all(15))),
      ]),
      if (complete) const Padding(padding: EdgeInsets.only(top: 12), child: Text('Session complete. Keep building your consistency.', style: TextStyle(color: C.neon, fontSize: 12))),
    ])),
    const SizedBox(height: 20), const SectionHeading('Practice passage', trailing: 'SELECT SURAH'), const SizedBox(height: 10),
    DropdownButtonFormField<String>(value: surah, decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)), items: surahs.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (s) => setState(() => surah = s ?? surah)),
    const SizedBox(height: 12),
    Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: C.panel, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF253238))), child: Column(children: [
      Text(surah, style: const TextStyle(color: C.neon, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)), const SizedBox(height: 12),
      ...verses.asMap().entries.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 24, height: 24, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: C.neon.withOpacity(.6))), child: Text((e.key + 1).toString(), style: const TextStyle(color: C.neon, fontSize: 10))),
        const SizedBox(width: 12), Expanded(child: Text(e.value, textAlign: TextAlign.right, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 19, height: 1.9))),
      ]))),
      const Divider(color: Color(0xFF253238), height: 25),
      const Text('Passage preview for guided practice. Audio recognition and tajweed scoring are not enabled in this build.', style: TextStyle(color: C.muted, fontSize: 11, height: 1.5)),
    ])),
    const SizedBox(height: 16), const InfoTile(icon: Icons.tips_and_updates_outlined, title: 'Practice tip', body: 'Recite slowly, listen carefully, and repeat difficult verses without rushing.'),
  ]);
}

class MemorizationScreen extends StatefulWidget {
  const MemorizationScreen({super.key});
  @override
  State<MemorizationScreen> createState() => _MemorizationScreenState();
}
class _MemorizationScreenState extends State<MemorizationScreen> {
  final tasks = [_MemoryTask('Al-Fatiha', '7 verses', true), _MemoryTask('Al-Ikhlas', '4 verses', false), _MemoryTask('Al-Falaq', '5 verses', false), _MemoryTask('An-Nas', '6 verses', false)];
  @override
  Widget build(BuildContext context) {
    final done = tasks.where((t) => t.done).length;
    final percent = (done / tasks.length * 100).round();
    return ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 24), children: [
      const Eyebrow('MEMORIZATION PLAN'), const SizedBox(height: 8),
      const Text('Make it stick.', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 7),
      const Text('A revision list you can update as you progress.', style: TextStyle(color: C.muted)), const SizedBox(height: 20),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: C.panel, borderRadius: BorderRadius.circular(22), border: Border.all(color: C.neon.withOpacity(.25))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('YOUR CHECKLIST', style: TextStyle(color: C.muted, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.bold)), Text(done.toString() + ' / ' + tasks.length.toString(), style: const TextStyle(color: C.neon, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 14), ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: done / tasks.length, minHeight: 8, backgroundColor: C.panel2, color: C.neon)),
        const SizedBox(height: 8), Text(percent.toString() + '% of this sample plan marked complete', style: const TextStyle(color: C.muted, fontSize: 11)),
      ])),
      const SizedBox(height: 20), const SectionHeading('Revision queue', trailing: 'TAP TO UPDATE'), const SizedBox(height: 10),
      ...tasks.map((task) => Padding(padding: const EdgeInsets.only(bottom: 10), child: InkWell(borderRadius: BorderRadius.circular(18), onTap: () => setState(() => task.done = !task.done), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: C.panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: task.done ? C.neon.withOpacity(.45) : const Color(0xFF253238))), child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: task.done ? C.neon.withOpacity(.12) : C.panel2, borderRadius: BorderRadius.circular(14)), child: Icon(task.done ? Icons.check_circle_rounded : Icons.menu_book_rounded, color: task.done ? C.neon : C.muted)),
        const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(height: 4), Text(task.subtitle, style: const TextStyle(color: C.muted, fontSize: 12))])),
        Icon(task.done ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: task.done ? C.neon : C.muted),
      ]))))),
      const SizedBox(height: 8), const InfoTile(icon: Icons.repeat_rounded, title: 'Revision rhythm', body: 'Review yesterday’s passage before adding a new one. Return to older passages regularly.'),
    ]);
  }
}

class MistakesLogScreen extends StatefulWidget {
  const MistakesLogScreen({super.key});
  @override
  State<MistakesLogScreen> createState() => _MistakesLogScreenState();
}
class _MistakesLogScreenState extends State<MistakesLogScreen> {
  final entries = <_MistakeEntry>[
    _MistakeEntry('Al-Fatiha', 'Repeat the verse slowly', 'Review', DateTime.now().subtract(const Duration(days: 1))),
    _MistakeEntry('Al-Ikhlas', 'Focus on clear articulation', 'Pronunciation', DateTime.now().subtract(const Duration(days: 2))),
  ];
  Future<void> addEntry() async {
    final surah = TextEditingController();
    final note = TextEditingController();
    final saved = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      backgroundColor: C.panel, title: const Text('Log a practice note'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: surah, decoration: const InputDecoration(labelText: 'Surah / passage')), const SizedBox(height: 10), TextField(controller: note, decoration: const InputDecoration(labelText: 'What should you review?'), maxLines: 2)]),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save'))],
    ));
    if (saved == true && surah.text.trim().isNotEmpty && note.text.trim().isNotEmpty && mounted) setState(() => entries.insert(0, _MistakeEntry(surah.text.trim(), note.text.trim(), 'Personal note', DateTime.now())));
    surah.dispose(); note.dispose();
  }
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 24), children: [
    const Eyebrow('REVIEW & REFINE'), const SizedBox(height: 8),
    const Text('Every mistake teaches.', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)), const SizedBox(height: 7),
    const Text('Keep personal notes about passages to revisit.', style: TextStyle(color: C.muted)), const SizedBox(height: 20),
    Row(children: [Expanded(child: MetricCard(value: entries.length.toString(), label: 'NOTES LOGGED', color: C.neon)), const SizedBox(width: 10), const Expanded(child: MetricCard(value: '—', label: 'AI DETECTION', color: C.blue))]),
    const SizedBox(height: 18),
    FilledButton.icon(onPressed: addEntry, icon: const Icon(Icons.add_rounded), label: const Text('Add review note'), style: FilledButton.styleFrom(backgroundColor: C.neon, foregroundColor: C.bg, padding: const EdgeInsets.symmetric(vertical: 14))),
    const SizedBox(height: 18), SectionHeading('Your review log', trailing: entries.length.toString() + ' ENTRIES'), const SizedBox(height: 10),
    if (entries.isEmpty) const InfoTile(icon: Icons.fact_check_outlined, title: 'Nothing logged yet', body: 'Add a note whenever you find a verse you want to revisit.'),
    ...entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: C.panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF253238))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: C.red.withOpacity(.1), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.replay_rounded, color: C.red)),
      const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(e.surah, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(e.note, style: const TextStyle(color: C.muted, height: 1.4)), const SizedBox(height: 8),
        Text(e.category + ' • ' + e.date.day.toString() + '/' + e.date.month.toString() + '/' + e.date.year.toString(), style: const TextStyle(color: C.neon, fontSize: 10, fontWeight: FontWeight.bold)),
      ])),
      IconButton(onPressed: () => setState(() => entries.remove(e)), icon: const Icon(Icons.close_rounded, size: 18, color: C.muted), tooltip: 'Remove note'),
    ])))),
    const SizedBox(height: 8), const Text('AI recitation detection is not yet connected. These are manual review notes, not automatically detected errors.', style: TextStyle(color: C.muted, fontSize: 11, height: 1.5)),
  ]);
}

class ProgressSheet extends StatefulWidget {
  const ProgressSheet({super.key});
  @override
  State<ProgressSheet> createState() => _ProgressSheetState();
}
class _ProgressSheetState extends State<ProgressSheet> {
  int sessions = 0;
  @override
  void initState() { super.initState(); load(); }
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => sessions = prefs.getInt('practice_count') ?? 0);
  }
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(22, 8, 22, 28), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Your progress', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)), const SizedBox(height: 6),
    const Text('A snapshot of your consistency on this device.', style: TextStyle(color: C.muted)), const SizedBox(height: 18),
    MetricCard(value: sessions.toString(), label: 'COMPLETED PRACTICE SESSIONS', color: C.neon), const SizedBox(height: 12),
    const Text('This build includes a practice timer and manual review tools. It does not yet listen to recitation or score tajweed.', style: TextStyle(color: C.muted, height: 1.5, fontSize: 12)),
  ]));
}
class Eyebrow extends StatelessWidget {
  final String text;
  const Eyebrow(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(color: C.neon, letterSpacing: 1.5, fontWeight: FontWeight.w800, fontSize: 10));
}
class SectionHeading extends StatelessWidget {
  final String title;
  final String? trailing;
  const SectionHeading(this.title, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))), if (trailing != null) Text(trailing!, style: const TextStyle(color: C.muted, fontSize: 9, letterSpacing: .8, fontWeight: FontWeight.bold))]);
}
class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const InfoTile({super.key, required this.icon, required this.title, required this.body});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: C.panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF253238))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, color: C.neon, size: 22), const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(body, style: const TextStyle(color: C.muted, fontSize: 12, height: 1.5))])),
  ]));
}
class MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const MetricCard({super.key, required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: C.panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF253238))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color)), const SizedBox(height: 5),
    Text(label, style: const TextStyle(fontSize: 9, color: C.muted, letterSpacing: .8, fontWeight: FontWeight.bold)),
  ]));
}
class _MemoryTask {
  final String title;
  final String subtitle;
  bool done;
  _MemoryTask(this.title, this.subtitle, this.done);
}
class _MistakeEntry {
  final String surah;
  final String note;
  final String category;
  final DateTime date;
  _MistakeEntry(this.surah, this.note, this.category, this.date);
}
