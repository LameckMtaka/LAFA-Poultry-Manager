import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const PoultryApp());
}

class PoultryApp extends StatelessWidget {
  const PoultryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LAFA Poultry Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B43)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7F5),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      home: const HomePage(),
    );
  }
}

class Incubator {
  final String id;
  final String name;
  final int capacity;
  final String notes;
  Incubator({required this.id, required this.name, required this.capacity, this.notes = ''});
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'capacity': capacity, 'notes': notes};
  factory Incubator.fromJson(Map<String, dynamic> j) => Incubator(id: j['id'], name: j['name'], capacity: j['capacity'] ?? 0, notes: j['notes'] ?? '');
}

class PoultryBatch {
  final String id;
  final String name;
  final int eggs;
  final DateTime setDate;
  final String incubatorId;
  final int fertile;
  final int infertile;
  final int suspect;
  final int deadEmbryo;
  final int hatched;

  PoultryBatch({
    required this.id,
    required this.name,
    required this.eggs,
    required this.setDate,
    this.incubatorId = '',
    this.fertile = 0,
    this.infertile = 0,
    this.suspect = 0,
    this.deadEmbryo = 0,
    this.hatched = 0,
  });

  PoultryBatch copyWith({int? fertile, int? infertile, int? suspect, int? deadEmbryo, int? hatched}) => PoultryBatch(
        id: id,
        name: name,
        eggs: eggs,
        setDate: setDate,
        incubatorId: incubatorId,
        fertile: fertile ?? this.fertile,
        infertile: infertile ?? this.infertile,
        suspect: suspect ?? this.suspect,
        deadEmbryo: deadEmbryo ?? this.deadEmbryo,
        hatched: hatched ?? this.hatched,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'eggs': eggs,
        'setDate': setDate.toIso8601String(),
        'incubatorId': incubatorId,
        'fertile': fertile,
        'infertile': infertile,
        'suspect': suspect,
        'deadEmbryo': deadEmbryo,
        'hatched': hatched,
      };

  factory PoultryBatch.fromJson(Map<String, dynamic> j) => PoultryBatch(
        id: j['id'],
        name: j['name'],
        eggs: j['eggs'],
        setDate: DateTime.parse(j['setDate']),
        incubatorId: j['incubatorId'] ?? '',
        fertile: j['fertile'] ?? 0,
        infertile: j['infertile'] ?? 0,
        suspect: j['suspect'] ?? 0,
        deadEmbryo: j['deadEmbryo'] ?? 0,
        hatched: j['hatched'] ?? 0,
      );
}

class ChickBatch {
  final String id;
  final String name;
  final int chicks;
  final int mortality;
  final DateTime hatchDate;
  ChickBatch({required this.id, required this.name, required this.chicks, required this.hatchDate, this.mortality = 0});
  ChickBatch copyWith({int? mortality}) => ChickBatch(id: id, name: name, chicks: chicks, hatchDate: hatchDate, mortality: mortality ?? this.mortality);
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'chicks': chicks, 'mortality': mortality, 'hatchDate': hatchDate.toIso8601String()};
  factory ChickBatch.fromJson(Map<String, dynamic> j) => ChickBatch(id: j['id'], name: j['name'], chicks: j['chicks'], mortality: j['mortality'] ?? 0, hatchDate: DateTime.parse(j['hatchDate']));
}

class EnvironmentRecord {
  final String id;
  final String incubatorId;
  final DateTime time;
  final double temperature;
  final double humidity;
  EnvironmentRecord({required this.id, required this.incubatorId, required this.time, required this.temperature, required this.humidity});
  Map<String, dynamic> toJson() => {'id': id, 'incubatorId': incubatorId, 'time': time.toIso8601String(), 'temperature': temperature, 'humidity': humidity};
  factory EnvironmentRecord.fromJson(Map<String, dynamic> j) => EnvironmentRecord(id: j['id'], incubatorId: j['incubatorId'], time: DateTime.parse(j['time']), temperature: (j['temperature'] as num).toDouble(), humidity: (j['humidity'] as num).toDouble());
}

class CandlingRecord {
  final String id;
  final DateTime time;
  final String result;
  final double confidence;
  final double brightness;
  final double redness;
  final double darkFraction;
  CandlingRecord({required this.id, required this.time, required this.result, required this.confidence, required this.brightness, required this.redness, required this.darkFraction});
  Map<String, dynamic> toJson() => {'id': id, 'time': time.toIso8601String(), 'result': result, 'confidence': confidence, 'brightness': brightness, 'redness': redness, 'darkFraction': darkFraction};
  factory CandlingRecord.fromJson(Map<String, dynamic> j) => CandlingRecord(id: j['id'], time: DateTime.parse(j['time']), result: j['result'], confidence: (j['confidence'] as num).toDouble(), brightness: (j['brightness'] as num).toDouble(), redness: (j['redness'] as num).toDouble(), darkFraction: (j['darkFraction'] as num).toDouble());
}

class AppStore {
  List<Incubator> incubators = [];
  List<PoultryBatch> batches = [];
  List<ChickBatch> chicks = [];
  List<EnvironmentRecord> environment = [];
  List<CandlingRecord> candling = [];

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    incubators = _decodeList(p.getString('incubators'), Incubator.fromJson);
    batches = _decodeList(p.getString('batches_v2'), PoultryBatch.fromJson);
    if (batches.isEmpty) {
      final old = p.getStringList('batches') ?? [];
      batches = old.map((e) => PoultryBatch.fromJson(jsonDecode(e))).toList();
    }
    chicks = _decodeList(p.getString('chicks_v2'), ChickBatch.fromJson);
    if (chicks.isEmpty) {
      final old = p.getStringList('chicks') ?? [];
      chicks = old.map((e) => ChickBatch.fromJson(jsonDecode(e))).toList();
    }
    environment = _decodeList(p.getString('environment'), EnvironmentRecord.fromJson);
    candling = _decodeList(p.getString('candling_records'), CandlingRecord.fromJson);
  }

  List<T> _decodeList<T>(String? raw, T Function(Map<String, dynamic>) fromJson) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('incubators', jsonEncode(incubators.map((e) => e.toJson()).toList()));
    await p.setString('batches_v2', jsonEncode(batches.map((e) => e.toJson()).toList()));
    await p.setString('chicks_v2', jsonEncode(chicks.map((e) => e.toJson()).toList()));
    await p.setString('environment', jsonEncode(environment.map((e) => e.toJson()).toList()));
    await p.setString('candling_records', jsonEncode(candling.map((e) => e.toJson()).toList()));
  }

  Map<String, dynamic> backupJson() => {
        'app': 'LAFA Poultry Manager',
        'version': 2,
        'createdAt': DateTime.now().toIso8601String(),
        'incubators': incubators.map((e) => e.toJson()).toList(),
        'batches': batches.map((e) => e.toJson()).toList(),
        'chicks': chicks.map((e) => e.toJson()).toList(),
        'environment': environment.map((e) => e.toJson()).toList(),
        'candling': candling.map((e) => e.toJson()).toList(),
      };

  Future<void> restore(Map<String, dynamic> data) async {
    incubators = (data['incubators'] as List? ?? []).map((e) => Incubator.fromJson(Map<String, dynamic>.from(e))).toList();
    batches = (data['batches'] as List? ?? []).map((e) => PoultryBatch.fromJson(Map<String, dynamic>.from(e))).toList();
    chicks = (data['chicks'] as List? ?? []).map((e) => ChickBatch.fromJson(Map<String, dynamic>.from(e))).toList();
    environment = (data['environment'] as List? ?? []).map((e) => EnvironmentRecord.fromJson(Map<String, dynamic>.from(e))).toList();
    candling = (data['candling'] as List? ?? []).map((e) => CandlingRecord.fromJson(Map<String, dynamic>.from(e))).toList();
    await save();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final store = AppStore();
  int index = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await store.load();
    if (mounted) setState(() => loading = false);
  }

  Future<void> _persist() async {
    await store.save();
    if (mounted) setState(() {});
  }

  Future<void> _backup() async {
    final dir = await getTemporaryDirectory();
    final name = 'LAFA_Poultry_Backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json';
    final file = File('${dir.path}/$name');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(store.backupJson()));
    await Share.shareXFiles([XFile(file.path)], text: 'Backup ya LAFA Poultry Manager');
  }

  Future<void> _restore() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (picked == null || picked.files.single.path == null) return;
    try {
      final raw = await File(picked.files.single.path!).readAsString();
      final data = Map<String, dynamic>.from(jsonDecode(raw));
      await store.restore(data);
      for (final b in store.batches) {
        await NotificationService.instance.scheduleIncubation(b);
      }
      for (final c in store.chicks) {
        await NotificationService.instance.scheduleVaccines(c);
      }
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup imerudishwa vizuri.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup haikusomeka: $e')));
    }
  }

  Future<void> _addEggBatch() async {
    final b = await showDialog<PoultryBatch>(context: context, builder: (_) => AddEggBatchDialog(incubators: store.incubators));
    if (b == null) return;
    store.batches.insert(0, b);
    await _persist();
    await NotificationService.instance.scheduleIncubation(b);
  }

  Future<void> _addChicks() async {
    final c = await showDialog<ChickBatch>(context: context, builder: (_) => const AddChickBatchDialog());
    if (c == null) return;
    store.chicks.insert(0, c);
    await _persist();
    await NotificationService.instance.scheduleVaccines(c);
  }

  Future<void> _addIncubator() async {
    final i = await showDialog<Incubator>(context: context, builder: (_) => const AddIncubatorDialog());
    if (i == null) return;
    store.incubators.insert(0, i);
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final pages = [
      Dashboard(store: store),
      EggBatches(store: store, onChanged: _persist),
      ChickBatches(store: store, onChanged: _persist),
      IncubatorsPage(store: store, onChanged: _persist),
      CameraCandlingPage(store: store, onChanged: _persist),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('LAFA Poultry Manager v2', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'test') NotificationService.instance.showTest();
              if (v == 'backup') _backup();
              if (v == 'restore') _restore();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'test', child: ListTile(leading: Icon(Icons.notifications_active_outlined), title: Text('Jaribu alarm'))),
              PopupMenuItem(value: 'backup', child: ListTile(leading: Icon(Icons.backup_outlined), title: Text('Backup / Share'))),
              PopupMenuItem(value: 'restore', child: ListTile(leading: Icon(Icons.restore), title: Text('Restore backup'))),
            ],
          )
        ],
      ),
      body: SafeArea(child: pages[index]),
      floatingActionButton: index == 1
          ? FloatingActionButton.extended(onPressed: _addEggBatch, icon: const Icon(Icons.egg_alt), label: const Text('Batch mpya'))
          : index == 2
              ? FloatingActionButton.extended(onPressed: _addChicks, icon: const Icon(Icons.pets), label: const Text('Vifaranga'))
              : index == 3
                  ? FloatingActionButton.extended(onPressed: _addIncubator, icon: const Icon(Icons.add), label: const Text('Incubator'))
                  : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Leo'),
          NavigationDestination(icon: Icon(Icons.egg_outlined), selectedIcon: Icon(Icons.egg), label: 'Mayai'),
          NavigationDestination(icon: Icon(Icons.pets_outlined), selectedIcon: Icon(Icons.pets), label: 'Makuzi'),
          NavigationDestination(icon: Icon(Icons.device_thermostat_outlined), selectedIcon: Icon(Icons.device_thermostat), label: 'Incubator'),
          NavigationDestination(icon: Icon(Icons.camera_alt_outlined), selectedIcon: Icon(Icons.camera_alt), label: 'Candling'),
        ],
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  final AppStore store;
  const Dashboard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final due = <_DueItem>[];
    for (final b in store.batches) {
      due.addAll([
        _DueItem('Candling ya siku ya 8', b.name, b.setDate.add(const Duration(days: 8)), Icons.visibility),
        _DueItem('Shusha mayai / lockdown', b.name, b.setDate.add(const Duration(days: 18)), Icons.move_down),
        _DueItem('Siku ya kutotolesha', b.name, b.setDate.add(const Duration(days: 21)), Icons.egg_alt),
        _DueItem('Toa vifaranga', b.name, b.setDate.add(const Duration(days: 22)), Icons.pets),
      ]);
    }
    for (final c in store.chicks) {
      due.addAll(vaccineSchedule(c));
    }
    due.removeWhere((e) => e.date.isBefore(DateUtils.dateOnly(now).subtract(const Duration(days: 1))) || e.date.isAfter(now.add(const Duration(days: 8))));
    due.sort((a, b) => a.date.compareTo(b.date));
    final totalEggs = store.batches.fold<int>(0, (a, b) => a + b.eggs);
    final totalHatched = store.batches.fold<int>(0, (a, b) => a + b.hatched);
    final hatchRate = totalEggs == 0 ? 0.0 : totalHatched * 100 / totalEggs;
    final totalChicks = store.chicks.fold<int>(0, (a, b) => a + b.chicks);
    final deaths = store.chicks.fold<int>(0, (a, b) => a + b.mortality);
    final mortality = totalChicks == 0 ? 0.0 : deaths * 100 / totalChicks;

    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF174F36), borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Poultry Command Center', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text('Incubation, candling, hatch, chanjo na makuzi — automatic.', style: TextStyle(color: Colors.white.withValues(alpha: .85))),
          const SizedBox(height: 18),
          Row(children: [Expanded(child: _metric('${store.batches.length}', 'Batch mayai')), const SizedBox(width: 10), Expanded(child: _metric('${store.chicks.length}', 'Batch vifaranga'))]),
        ]),
      ),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _statCard(context, 'Hatch rate', '${hatchRate.toStringAsFixed(1)}%', Icons.auto_graph)),
        const SizedBox(width: 10),
        Expanded(child: _statCard(context, 'Mortality', '${mortality.toStringAsFixed(1)}%', Icons.monitor_heart_outlined)),
      ]),
      const SizedBox(height: 18),
      const Text('Yanayokuja ndani ya siku 7', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      if (due.isEmpty) const _EmptyCard(icon: Icons.event_available, title: 'Hakuna kazi ya karibu', subtitle: 'Ratiba itaonekana hapa baada ya kuongeza batch.'),
      ...due.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Card(child: ListTile(
            leading: CircleAvatar(child: Icon(e.icon)),
            title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text('${e.batch} • ${fmt(e.date)}'),
            trailing: Chip(label: Text(_relativeDay(e.date), style: const TextStyle(fontWeight: FontWeight.w800))),
          )))),
      const SizedBox(height: 12),
      const _TimelineCard(),
    ]);
  }

  Widget _metric(String n, String label) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .10), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)), Text(label, style: TextStyle(color: Colors.white.withValues(alpha: .82)))]));
  Widget _statCard(BuildContext context, String title, String value, IconData icon) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Icon(icon, size: 30), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), Text(title)]))])));
}

class EggBatches extends StatelessWidget {
  final AppStore store;
  final Future<void> Function() onChanged;
  const EggBatches({super.key, required this.store, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (store.batches.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: _EmptyCard(icon: Icons.egg_outlined, title: 'Hakuna batch ya mayai', subtitle: 'Bonyeza Batch mpya kuanza.')));
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: store.batches.length,
      itemBuilder: (_, i) {
        final b = store.batches[i];
        final incubator = store.incubators.where((x) => x.id == b.incubatorId).map((x) => x.name).firstOrNull ?? 'Haijachaguliwa';
        final day = math.max(0, DateUtils.dateOnly(DateTime.now()).difference(DateUtils.dateOnly(b.setDate)).inDays);
        final hatchRate = b.eggs == 0 ? 0 : b.hatched * 100 / b.eggs;
        return Padding(padding: const EdgeInsets.only(bottom: 12), child: Card(child: ExpansionTile(
          leading: const CircleAvatar(child: Icon(Icons.egg_alt)),
          title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text('${b.eggs} mayai • $incubator • Siku $day'),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            _scheduleRow('Siku 8', 'Candling', b.setDate.add(const Duration(days: 8))),
            _scheduleRow('Siku 18', 'Shusha mayai / lockdown', b.setDate.add(const Duration(days: 18))),
            _scheduleRow('Siku 21', 'Kutotolesha', b.setDate.add(const Duration(days: 21))),
            _scheduleRow('Siku 22', 'Toa vifaranga', b.setDate.add(const Duration(days: 22))),
            const Divider(),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _chip('Fertile ${b.fertile}'), _chip('Infertile ${b.infertile}'), _chip('Dead ${b.deadEmbryo}'), _chip('Suspect ${b.suspect}'), _chip('Hatched ${b.hatched}'), _chip('Hatch ${hatchRate.toStringAsFixed(1)}%'),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: FilledButton.tonalIcon(onPressed: () async {
                final updated = await showDialog<PoultryBatch>(context: context, builder: (_) => CandlingCountDialog(batch: b));
                if (updated != null) { store.batches[i] = updated; await onChanged(); }
              }, icon: const Icon(Icons.fact_check_outlined), label: const Text('Candling'))),
              const SizedBox(width: 8),
              Expanded(child: FilledButton.tonalIcon(onPressed: () async {
                final updated = await showDialog<PoultryBatch>(context: context, builder: (_) => HatchResultDialog(batch: b));
                if (updated != null) { store.batches[i] = updated; await onChanged(); }
              }, icon: const Icon(Icons.pets), label: const Text('Hatch result'))),
            ]),
            TextButton.icon(onPressed: () async { await NotificationService.instance.cancelBatch(b.id); store.batches.removeAt(i); await onChanged(); }, icon: const Icon(Icons.delete_outline), label: const Text('Futa batch')),
          ],
        )));
      },
    );
  }

  Widget _scheduleRow(String day, String title, DateTime date) => ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: Chip(label: Text(day)), title: Text(title), trailing: Text(DateFormat('dd/MM').format(date), style: const TextStyle(fontWeight: FontWeight.w800)));
  Widget _chip(String s) => Chip(label: Text(s));
}

class ChickBatches extends StatelessWidget {
  final AppStore store;
  final Future<void> Function() onChanged;
  const ChickBatches({super.key, required this.store, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    if (store.chicks.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: _EmptyCard(icon: Icons.pets_outlined, title: 'Hakuna batch ya vifaranga', subtitle: 'Ongeza batch baada ya hatch.')));
    return ListView.builder(padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), itemCount: store.chicks.length, itemBuilder: (_, i) {
      final c = store.chicks[i];
      final mortality = c.chicks == 0 ? 0 : c.mortality * 100 / c.chicks;
      return Padding(padding: const EdgeInsets.only(bottom: 12), child: Card(child: ExpansionTile(
        leading: const CircleAvatar(child: Icon(Icons.pets)),
        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text('${c.chicks} vifaranga • Vifo ${c.mortality} (${mortality.toStringAsFixed(1)}%)'),
        children: [
          ...vaccineSchedule(c).map((v) => ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 20), leading: const Icon(Icons.vaccines_outlined), title: Text(v.title), subtitle: Text(fmt(v.date)), trailing: Chip(label: Text(v.dayLabel)))),
          Padding(padding: const EdgeInsets.all(16), child: FilledButton.tonalIcon(onPressed: () async {
            final n = await showDialog<int>(context: context, builder: (_) => NumberDialog(title: 'Rekodi vifo', label: 'Jumla ya vifo hadi sasa', initial: c.mortality));
            if (n != null && n >= 0 && n <= c.chicks) { store.chicks[i] = c.copyWith(mortality: n); await onChanged(); }
          }, icon: const Icon(Icons.monitor_heart_outlined), label: const Text('Update mortality'))),
        ],
      )));
    });
  }
}

class IncubatorsPage extends StatelessWidget {
  final AppStore store;
  final Future<void> Function() onChanged;
  const IncubatorsPage({super.key, required this.store, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    if (store.incubators.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: _EmptyCard(icon: Icons.device_thermostat, title: 'Ongeza incubator', subtitle: 'Unaweza kusimamia incubator nyingi na records za temperature/humidity.')));
    return ListView.builder(padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), itemCount: store.incubators.length, itemBuilder: (_, i) {
      final inc = store.incubators[i];
      final records = store.environment.where((e) => e.incubatorId == inc.id).toList()..sort((a, b) => b.time.compareTo(a.time));
      final latest = records.isEmpty ? null : records.first;
      return Padding(padding: const EdgeInsets.only(bottom: 12), child: Card(child: ExpansionTile(
        leading: const CircleAvatar(child: Icon(Icons.device_thermostat)),
        title: Text(inc.name, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text('Capacity ${inc.capacity}${latest == null ? '' : ' • ${latest.temperature.toStringAsFixed(1)}°C • ${latest.humidity.toStringAsFixed(0)}% RH'}'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (inc.notes.isNotEmpty) Align(alignment: Alignment.centerLeft, child: Text(inc.notes)),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(onPressed: () async {
            final r = await showDialog<EnvironmentRecord>(context: context, builder: (_) => EnvironmentDialog(incubatorId: inc.id));
            if (r != null) { store.environment.insert(0, r); await onChanged(); }
          }, icon: const Icon(Icons.add_chart), label: const Text('Rekodi temperature & humidity')),
          const SizedBox(height: 8),
          ...records.take(10).map((r) => ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text('${r.temperature.toStringAsFixed(1)} °C   •   ${r.humidity.toStringAsFixed(0)}% RH', style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(r.time)))),
        ],
      )));
    });
  }
}

class CameraCandlingPage extends StatefulWidget {
  final AppStore store;
  final Future<void> Function() onChanged;
  const CameraCandlingPage({super.key, required this.store, required this.onChanged});
  @override
  State<CameraCandlingPage> createState() => _CameraCandlingPageState();
}

class _CameraCandlingPageState extends State<CameraCandlingPage> {
  XFile? photo;
  CandlingRecord? result;
  bool analyzing = false;

  Future<void> _capture() async {
    final x = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 82, maxWidth: 1200);
    if (x == null) return;
    setState(() { photo = x; result = null; });
    await _analyze(x);
  }

  Future<void> _gallery() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 82, maxWidth: 1200);
    if (x == null) return;
    setState(() { photo = x; result = null; });
    await _analyze(x);
  }

  Future<void> _analyze(XFile x) async {
    setState(() => analyzing = true);
    try {
      final bytes = await x.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) throw Exception('Picha haijasomeka');
      final small = img.copyResize(decoded, width: 120);
      double lum = 0, redIndex = 0, dark = 0;
      int n = 0;
      for (final p in small) {
        final r = p.r.toDouble(), g = p.g.toDouble(), b = p.b.toDouble();
        final l = (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255.0;
        lum += l;
        redIndex += math.max(0.0, r - ((g + b) / 2)) / 255.0;
        if (l < 0.28) dark += 1;
        n++;
      }
      final brightness = lum / n;
      final redness = redIndex / n;
      final darkFraction = dark / n;
      String label;
      double confidence;
      if (brightness > 0.60 && darkFraction < 0.10 && redness < 0.06) {
        label = 'Infertile / Clear (makadirio)';
        confidence = _clamp(0.58 + (brightness - .60) + (.10 - darkFraction));
      } else if (darkFraction > 0.48 && redness < 0.055) {
        label = 'Dead Embryo / Suspect (makadirio)';
        confidence = _clamp(0.52 + (darkFraction - .48));
      } else if (redness > 0.075 && darkFraction > 0.12 && darkFraction < 0.55) {
        label = 'Fertile / Developing (makadirio)';
        confidence = _clamp(0.56 + (redness - .075) * 2 + math.min(.18, darkFraction));
      } else {
        label = 'Suspect — piga tena kwa mwanga bora';
        confidence = 0.50;
      }
      final rec = CandlingRecord(id: DateTime.now().microsecondsSinceEpoch.toString(), time: DateTime.now(), result: label, confidence: confidence, brightness: brightness, redness: redness, darkFraction: darkFraction);
      widget.store.candling.insert(0, rec);
      await widget.onChanged();
      if (mounted) setState(() => result = rec);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Analysis imekataa: $e')));
    } finally {
      if (mounted) setState(() => analyzing = false);
    }
  }

  double _clamp(double v) => v < .45 ? .45 : v > .88 ? .88 : v;

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Camera Candling Assistant', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      const Text('Siku ya 8: weka yai juu ya candling light, zima mwanga wa chumba, kisha piga picha. App huchambua mwangaza, maeneo meusi na red/vascular signal kutoa makadirio.'),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: FilledButton.icon(onPressed: analyzing ? null : _capture, icon: const Icon(Icons.camera_alt), label: const Text('Piga picha'))),
        const SizedBox(width: 8),
        Expanded(child: FilledButton.tonalIcon(onPressed: analyzing ? null : _gallery, icon: const Icon(Icons.photo_library_outlined), label: const Text('Gallery'))),
      ]),
      const SizedBox(height: 14),
      if (photo != null) ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(File(photo!.path), height: 260, fit: BoxFit.cover)),
      if (analyzing) const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
      if (result != null) ...[
        const SizedBox(height: 14),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(result!.result, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text('Confidence ${(result!.confidence * 100).toStringAsFixed(0)}%'),
          Text('Brightness ${(result!.brightness * 100).toStringAsFixed(0)}% • Red signal ${(result!.redness * 100).toStringAsFixed(1)}% • Dark area ${(result!.darkFraction * 100).toStringAsFixed(0)}%'),
        ]))),
      ],
      const SizedBox(height: 14),
      const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('MUHIMU: Camera Candling ya v2.0 ni experimental image-analysis assistant, si model ya veterinary iliyothibitishwa. Rangi ya ganda, aina ya taa, exposure na angle vinaweza kubadilisha matokeo. Tumia kama msaada; yai la “Suspect” lichunguzwe tena baada ya siku 1–2 na usiondoe yai kwa prediction pekee.'))),
      const SizedBox(height: 18),
      const Text('Historia ya Camera Candling', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      ...widget.store.candling.take(12).map((r) => Card(child: ListTile(leading: const Icon(Icons.analytics_outlined), title: Text(r.result), subtitle: Text('${DateFormat('dd/MM/yyyy HH:mm').format(r.time)} • ${(r.confidence * 100).toStringAsFixed(0)}%')))),
    ]);
  }
}

class AddEggBatchDialog extends StatefulWidget {
  final List<Incubator> incubators;
  const AddEggBatchDialog({super.key, required this.incubators});
  @override
  State<AddEggBatchDialog> createState() => _AddEggBatchDialogState();
}

class _AddEggBatchDialogState extends State<AddEggBatchDialog> {
  final name = TextEditingController();
  final eggs = TextEditingController();
  DateTime date = DateTime.now();
  String incubatorId = '';
  @override
  Widget build(BuildContext context) => AlertDialog(title: const Text('Batch mpya ya mayai'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
    TextField(controller: name, decoration: const InputDecoration(labelText: 'Jina la batch')), const SizedBox(height: 10),
    TextField(controller: eggs, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Idadi ya mayai')), const SizedBox(height: 10),
    if (widget.incubators.isNotEmpty) DropdownButtonFormField<String>(initialValue: incubatorId.isEmpty ? null : incubatorId, decoration: const InputDecoration(labelText: 'Incubator'), items: widget.incubators.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(), onChanged: (v) => setState(() => incubatorId = v ?? '')), const SizedBox(height: 10),
    ListTile(contentPadding: EdgeInsets.zero, title: const Text('Tarehe ya kuweka mayai'), subtitle: Text(fmt(date)), trailing: const Icon(Icons.calendar_month), onTap: () async { final d = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2040)); if (d != null) setState(() => date = d); }),
  ])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ghairi')), FilledButton(onPressed: () { final n = int.tryParse(eggs.text); if (name.text.trim().isEmpty || n == null || n <= 0) return; Navigator.pop(context, PoultryBatch(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name.text.trim(), eggs: n, setDate: date, incubatorId: incubatorId)); }, child: const Text('Hifadhi + alarms'))]);
}

class AddChickBatchDialog extends StatefulWidget {
  const AddChickBatchDialog({super.key});
  @override
  State<AddChickBatchDialog> createState() => _AddChickBatchDialogState();
}
class _AddChickBatchDialogState extends State<AddChickBatchDialog> {
  final name = TextEditingController();
  final count = TextEditingController();
  DateTime date = DateTime.now();
  @override
  Widget build(BuildContext context) => AlertDialog(title: const Text('Batch ya vifaranga'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
    TextField(controller: name, decoration: const InputDecoration(labelText: 'Jina la batch')), const SizedBox(height: 10),
    TextField(controller: count, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Idadi ya vifaranga')), const SizedBox(height: 10),
    ListTile(contentPadding: EdgeInsets.zero, title: const Text('Tarehe ya kutotolewa'), subtitle: Text(fmt(date)), trailing: const Icon(Icons.calendar_month), onTap: () async { final d = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2040)); if (d != null) setState(() => date = d); }),
  ])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ghairi')), FilledButton(onPressed: () { final n = int.tryParse(count.text); if (name.text.trim().isEmpty || n == null || n <= 0) return; Navigator.pop(context, ChickBatch(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name.text.trim(), chicks: n, hatchDate: date)); }, child: const Text('Hifadhi + chanjo'))]);
}

class AddIncubatorDialog extends StatefulWidget {
  const AddIncubatorDialog({super.key});
  @override
  State<AddIncubatorDialog> createState() => _AddIncubatorDialogState();
}
class _AddIncubatorDialogState extends State<AddIncubatorDialog> {
  final name = TextEditingController(); final capacity = TextEditingController(); final notes = TextEditingController();
  @override
  Widget build(BuildContext context) => AlertDialog(title: const Text('Ongeza incubator'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Jina / namba')), const SizedBox(height: 10), TextField(controller: capacity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacity ya mayai')), const SizedBox(height: 10), TextField(controller: notes, decoration: const InputDecoration(labelText: 'Maelezo (optional)'))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ghairi')), FilledButton(onPressed: () { final c = int.tryParse(capacity.text); if (name.text.trim().isEmpty || c == null || c <= 0) return; Navigator.pop(context, Incubator(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name.text.trim(), capacity: c, notes: notes.text.trim())); }, child: const Text('Hifadhi'))]);
}

class EnvironmentDialog extends StatefulWidget {
  final String incubatorId;
  const EnvironmentDialog({super.key, required this.incubatorId});
  @override
  State<EnvironmentDialog> createState() => _EnvironmentDialogState();
}
class _EnvironmentDialogState extends State<EnvironmentDialog> {
  final t = TextEditingController(); final h = TextEditingController();
  @override
  Widget build(BuildContext context) => AlertDialog(title: const Text('Temperature & Humidity'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: t, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Temperature °C')), const SizedBox(height: 10), TextField(controller: h, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Humidity % RH'))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ghairi')), FilledButton(onPressed: () { final tv = double.tryParse(t.text); final hv = double.tryParse(h.text); if (tv == null || hv == null) return; Navigator.pop(context, EnvironmentRecord(id: DateTime.now().microsecondsSinceEpoch.toString(), incubatorId: widget.incubatorId, time: DateTime.now(), temperature: tv, humidity: hv)); }, child: const Text('Hifadhi'))]);
}

class CandlingCountDialog extends StatefulWidget {
  final PoultryBatch batch;
  const CandlingCountDialog({super.key, required this.batch});
  @override
  State<CandlingCountDialog> createState() => _CandlingCountDialogState();
}
class _CandlingCountDialogState extends State<CandlingCountDialog> {
  late final TextEditingController f = TextEditingController(text: '${widget.batch.fertile}');
  late final TextEditingController i = TextEditingController(text: '${widget.batch.infertile}');
  late final TextEditingController s = TextEditingController(text: '${widget.batch.suspect}');
  late final TextEditingController d = TextEditingController(text: '${widget.batch.deadEmbryo}');
  @override
  Widget build(BuildContext context) => AlertDialog(title: const Text('Matokeo ya candling'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: f, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fertile')), const SizedBox(height: 8), TextField(controller: i, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Infertile / clear')), const SizedBox(height: 8), TextField(controller: d, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dead embryo')), const SizedBox(height: 8), TextField(controller: s, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Suspect'))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ghairi')), FilledButton(onPressed: () { Navigator.pop(context, widget.batch.copyWith(fertile: int.tryParse(f.text) ?? 0, infertile: int.tryParse(i.text) ?? 0, deadEmbryo: int.tryParse(d.text) ?? 0, suspect: int.tryParse(s.text) ?? 0)); }, child: const Text('Hifadhi'))]);
}

class HatchResultDialog extends StatefulWidget {
  final PoultryBatch batch;
  const HatchResultDialog({super.key, required this.batch});
  @override
  State<HatchResultDialog> createState() => _HatchResultDialogState();
}
class _HatchResultDialogState extends State<HatchResultDialog> {
  late final TextEditingController h = TextEditingController(text: '${widget.batch.hatched}');
  @override
  Widget build(BuildContext context) => AlertDialog(title: const Text('Hatch result'), content: TextField(controller: h, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Vifaranga vilivyototolewa', helperText: 'Mayai ya mwanzo: ${widget.batch.eggs}')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ghairi')), FilledButton(onPressed: () { final n = int.tryParse(h.text); if (n == null || n < 0 || n > widget.batch.eggs) return; Navigator.pop(context, widget.batch.copyWith(hatched: n)); }, child: const Text('Hifadhi'))]);
}

class NumberDialog extends StatefulWidget {
  final String title; final String label; final int initial;
  const NumberDialog({super.key, required this.title, required this.label, required this.initial});
  @override
  State<NumberDialog> createState() => _NumberDialogState();
}
class _NumberDialogState extends State<NumberDialog> {
  late final TextEditingController c = TextEditingController(text: '${widget.initial}');
  @override
  Widget build(BuildContext context) => AlertDialog(title: Text(widget.title), content: TextField(controller: c, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: widget.label)), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ghairi')), FilledButton(onPressed: () => Navigator.pop(context, int.tryParse(c.text)), child: const Text('Hifadhi'))]);
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard();
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: const [
    _StaticRow('Incubation', 'Day 8', 'Candling / chunguza kiini'),
    _StaticRow('Incubation', 'Day 18', 'Shusha mayai / lockdown tray'),
    _StaticRow('Incubation', 'Day 21', 'Hatch day'),
    _StaticRow('Incubation', 'Day 22', 'Toa vifaranga'),
    Divider(),
    _StaticRow('Chanjo', 'Day 7', 'Newcastle I'),
    _StaticRow('Chanjo', 'Day 14', 'Gumboro I'),
    _StaticRow('Chanjo', 'Day 21', 'Newcastle II'),
    _StaticRow('Chanjo', 'Day 28', 'Gumboro II'),
    _StaticRow('Chanjo', 'Day 35', 'Ndui / Fowl Pox'),
    _StaticRow('Kuku wakubwa', 'Kila miezi 3', 'Booster reminder'),
  ])));
}
class _StaticRow extends StatelessWidget {
  final String group, day, task;
  const _StaticRow(this.group, this.day, this.task);
  @override
  Widget build(BuildContext context) => ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.check_circle_outline), title: Text(task), subtitle: Text(group), trailing: Text(day, style: const TextStyle(fontWeight: FontWeight.w800)));
}
class _EmptyCard extends StatelessWidget {
  final IconData icon; final String title, subtitle;
  const _EmptyCard({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 48), const SizedBox(height: 10), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(subtitle, textAlign: TextAlign.center)])));
}
class _DueItem {
  final String title, batch; final DateTime date; final IconData icon; final String dayLabel;
  _DueItem(this.title, this.batch, this.date, this.icon, [this.dayLabel = '']);
}

List<_DueItem> vaccineSchedule(ChickBatch c) {
  final items = <_DueItem>[
    _DueItem('Newcastle I', c.name, c.hatchDate.add(const Duration(days: 7)), Icons.vaccines, 'Day 7'),
    _DueItem('Gumboro I', c.name, c.hatchDate.add(const Duration(days: 14)), Icons.vaccines, 'Day 14'),
    _DueItem('Newcastle II', c.name, c.hatchDate.add(const Duration(days: 21)), Icons.vaccines, 'Day 21'),
    _DueItem('Gumboro II', c.name, c.hatchDate.add(const Duration(days: 28)), Icons.vaccines, 'Day 28'),
    _DueItem('Ndui / Fowl Pox', c.name, c.hatchDate.add(const Duration(days: 35)), Icons.vaccines, 'Day 35'),
  ];
  var booster = DateTime(c.hatchDate.year, c.hatchDate.month, c.hatchDate.day + 35);
  for (var i = 1; i <= 12; i++) {
    booster = DateTime(booster.year, booster.month + 3, booster.day);
    items.add(_DueItem('Booster ya kuku wakubwa', c.name, booster, Icons.vaccines, 'Miezi 3 × $i'));
  }
  return items;
}

String fmt(DateTime d) => DateFormat('dd MMM yyyy').format(d);
String _relativeDay(DateTime d) {
  final x = DateUtils.dateOnly(d).difference(DateUtils.dateOnly(DateTime.now())).inDays;
  if (x == 0) return 'LEO';
  if (x == 1) return 'KESHO';
  return 'Siku $x';
}

extension FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
