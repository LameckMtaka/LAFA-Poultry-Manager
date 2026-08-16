import 'package:flutter/material.dart';

class VaccineEvent {
  final String id;
  final String titleSw;
  final String titleEn;
  final int day;
  final bool enabled;
  final String category;
  final int repeatEveryMonths;
  final int repeatCount;

  const VaccineEvent({
    required this.id,
    required this.titleSw,
    required this.titleEn,
    required this.day,
    this.enabled = true,
    this.category = 'vaccine',
    this.repeatEveryMonths = 0,
    this.repeatCount = 0,
  });

  VaccineEvent copyWith({
    String? id,
    String? titleSw,
    String? titleEn,
    int? day,
    bool? enabled,
    String? category,
    int? repeatEveryMonths,
    int? repeatCount,
  }) => VaccineEvent(
        id: id ?? this.id,
        titleSw: titleSw ?? this.titleSw,
        titleEn: titleEn ?? this.titleEn,
        day: day ?? this.day,
        enabled: enabled ?? this.enabled,
        category: category ?? this.category,
        repeatEveryMonths: repeatEveryMonths ?? this.repeatEveryMonths,
        repeatCount: repeatCount ?? this.repeatCount,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleSw': titleSw,
        'titleEn': titleEn,
        'day': day,
        'enabled': enabled,
        'category': category,
        'repeatEveryMonths': repeatEveryMonths,
        'repeatCount': repeatCount,
      };

  factory VaccineEvent.fromJson(Map<String, dynamic> j) => VaccineEvent(
        id: j['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
        titleSw: j['titleSw'] ?? j['title'] ?? 'Tukio',
        titleEn: j['titleEn'] ?? j['title'] ?? 'Event',
        day: (j['day'] as num?)?.toInt() ?? 0,
        enabled: j['enabled'] ?? true,
        category: j['category'] ?? 'vaccine',
        repeatEveryMonths: (j['repeatEveryMonths'] as num?)?.toInt() ?? 0,
        repeatCount: (j['repeatCount'] as num?)?.toInt() ?? 0,
      );
}

class VaccineProfile {
  final String id;
  final String nameSw;
  final String nameEn;
  final String noteSw;
  final String noteEn;
  final bool builtIn;
  final List<VaccineEvent> events;

  const VaccineProfile({
    required this.id,
    required this.nameSw,
    required this.nameEn,
    required this.noteSw,
    required this.noteEn,
    required this.events,
    this.builtIn = false,
  });

  VaccineProfile copyWith({
    String? id,
    String? nameSw,
    String? nameEn,
    String? noteSw,
    String? noteEn,
    bool? builtIn,
    List<VaccineEvent>? events,
  }) => VaccineProfile(
        id: id ?? this.id,
        nameSw: nameSw ?? this.nameSw,
        nameEn: nameEn ?? this.nameEn,
        noteSw: noteSw ?? this.noteSw,
        noteEn: noteEn ?? this.noteEn,
        events: events ?? this.events,
        builtIn: builtIn ?? this.builtIn,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameSw': nameSw,
        'nameEn': nameEn,
        'noteSw': noteSw,
        'noteEn': noteEn,
        'builtIn': builtIn,
        'events': events.map((e) => e.toJson()).toList(),
      };

  factory VaccineProfile.fromJson(Map<String, dynamic> j) => VaccineProfile(
        id: j['id'],
        nameSw: j['nameSw'] ?? j['name'] ?? 'Ratiba',
        nameEn: j['nameEn'] ?? j['name'] ?? 'Schedule',
        noteSw: j['noteSw'] ?? '',
        noteEn: j['noteEn'] ?? '',
        builtIn: j['builtIn'] ?? false,
        events: (j['events'] as List? ?? [])
            .map((e) => VaccineEvent.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

const String defaultVaccineProfileId = 'custom';

List<VaccineProfile> defaultVaccineProfiles() => const [
  VaccineProfile(
    id: 'kienyeji',
    nameSw: 'Kienyeji',
    nameEn: 'Indigenous',
    builtIn: true,
    noteSw: 'Profile ya kuanzia inayotokana na ratiba zilizo kwenye miongozo uliyopakia. Ratiba za eneo zinaweza kutofautiana; ihakikishe na mtaalamu wa mifugo.',
    noteEn: 'Starter profile based on schedules in the uploaded guides. Local programs may differ; confirm with a veterinary professional.',
    events: [
      VaccineEvent(id:'k-nc1', titleSw:'Kideri / Newcastle I', titleEn:'Newcastle I', day:3),
      VaccineEvent(id:'k-gu1', titleSw:'Gumboro I', titleEn:'Gumboro I', day:14),
      VaccineEvent(id:'k-gu2', titleSw:'Gumboro II', titleEn:'Gumboro II', day:28),
      VaccineEvent(id:'k-gu3', titleSw:'Gumboro III', titleEn:'Gumboro III', day:42),
      VaccineEvent(id:'k-ncb', titleSw:'Newcastle booster', titleEn:'Newcastle booster', day:21, repeatEveryMonths:3, repeatCount:12),
    ],
  ),
  VaccineProfile(
    id: 'broiler',
    nameSw: 'Broiler',
    nameEn: 'Broiler',
    builtIn: true,
    noteSw: 'Profile ya broiler kutoka ratiba ya msingi kwenye mwongozo uliopakia: Newcastle siku 7, Gumboro siku 14, Newcastle kurudiwa siku 21. Hariri kama program ya hatchery/mtaalamu wako ni tofauti.',
    noteEn: 'Broiler starter profile from the uploaded guide: Newcastle day 7, Gumboro day 14, Newcastle repeat day 21. Edit if your hatchery/veterinary program differs.',
    events: [
      VaccineEvent(id:'b-nc1', titleSw:'Newcastle I', titleEn:'Newcastle I', day:7),
      VaccineEvent(id:'b-gu1', titleSw:'Gumboro I', titleEn:'Gumboro I', day:14),
      VaccineEvent(id:'b-nc2', titleSw:'Newcastle II', titleEn:'Newcastle II', day:21),
    ],
  ),
  VaccineProfile(
    id: 'layer',
    nameSw: 'Layer / Kuku wa Mayai',
    nameEn: 'Layer',
    builtIn: true,
    noteSw: 'Profile ya kuanzia kutoka mwongozo wa layers uliopakia. Ina Newcastle siku 7, Gumboro siku 14, Fowl Typhoid wiki 9, Fowl Pox wiki 18 na deworming wiki 19.',
    noteEn: 'Starter profile from the uploaded layer guide. Includes Newcastle day 7, Gumboro day 14, Fowl Typhoid week 9, Fowl Pox week 18 and deworming week 19.',
    events: [
      VaccineEvent(id:'l-nc1', titleSw:'Newcastle', titleEn:'Newcastle', day:7),
      VaccineEvent(id:'l-gu1', titleSw:'Gumboro', titleEn:'Gumboro', day:14),
      VaccineEvent(id:'l-ft', titleSw:'Fowl Typhoid', titleEn:'Fowl Typhoid', day:63),
      VaccineEvent(id:'l-fp', titleSw:'Ndui / Fowl Pox', titleEn:'Fowl Pox', day:126),
      VaccineEvent(id:'l-dw', titleSw:'Dawa ya minyoo', titleEn:'Deworming', day:133, category:'deworming', repeatEveryMonths:6, repeatCount:8),
    ],
  ),
  VaccineProfile(
    id: 'chotara',
    nameSw: 'Chotara',
    nameEn: 'Dual-purpose / Crossbred',
    builtIn: true,
    noteSw: 'Profile salama ya kuanzia inayofuata ratiba yako ya awali. Kwa kuwa miongozo uliyopakia haina ratiba moja ya chanjo inayofanana kwa chotara wote, profile hii imeachwa editable.',
    noteEn: 'Editable starter profile based on your original operational schedule. The uploaded guides do not provide one universal schedule for all crossbreds.',
    events: [
      VaccineEvent(id:'c-nc1', titleSw:'Newcastle I', titleEn:'Newcastle I', day:7),
      VaccineEvent(id:'c-gu1', titleSw:'Gumboro I', titleEn:'Gumboro I', day:14),
      VaccineEvent(id:'c-nc2', titleSw:'Newcastle II', titleEn:'Newcastle II', day:21),
      VaccineEvent(id:'c-gu2', titleSw:'Gumboro II', titleEn:'Gumboro II', day:28),
      VaccineEvent(id:'c-fp', titleSw:'Ndui / Fowl Pox', titleEn:'Fowl Pox', day:35),
      VaccineEvent(id:'c-b', titleSw:'Booster ya kuku wakubwa', titleEn:'Adult booster', day:35, repeatEveryMonths:3, repeatCount:12),
    ],
  ),
  VaccineProfile(
    id: 'custom',
    nameSw: 'Custom / Ratiba Yangu',
    nameEn: 'Custom / My Schedule',
    builtIn: true,
    noteSw: 'Hii ndiyo ratiba yako ya awali: Day 7 Newcastle, Day 14 Gumboro, Day 21 Newcastle II, Day 28 Gumboro II, Day 35 Ndui, kisha booster kila miezi 3.',
    noteEn: 'Your original schedule: Day 7 Newcastle, Day 14 Gumboro, Day 21 Newcastle II, Day 28 Gumboro II, Day 35 Fowl Pox, then a booster every 3 months.',
    events: [
      VaccineEvent(id:'x-nc1', titleSw:'Newcastle I', titleEn:'Newcastle I', day:7),
      VaccineEvent(id:'x-gu1', titleSw:'Gumboro I', titleEn:'Gumboro I', day:14),
      VaccineEvent(id:'x-nc2', titleSw:'Newcastle II', titleEn:'Newcastle II', day:21),
      VaccineEvent(id:'x-gu2', titleSw:'Gumboro II', titleEn:'Gumboro II', day:28),
      VaccineEvent(id:'x-fp', titleSw:'Ndui / Fowl Pox', titleEn:'Fowl Pox', day:35),
      VaccineEvent(id:'x-b', titleSw:'Booster ya kuku wakubwa', titleEn:'Adult booster', day:35, repeatEveryMonths:3, repeatCount:12),
    ],
  ),
];

IconData vaccineCategoryIcon(String category) {
  switch (category) {
    case 'deworming': return Icons.medication_liquid_outlined;
    case 'management': return Icons.task_alt;
    default: return Icons.vaccines_outlined;
  }
}
