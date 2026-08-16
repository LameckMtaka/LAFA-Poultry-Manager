import 'package:flutter/material.dart';
import 'i18n.dart';

class FeedFormula {
  final String titleSw;
  final String titleEn;
  final String stageSw;
  final String stageEn;
  final double baseKg;
  final List<MapEntry<String, double>> ingredients;
  final String noteSw;
  final String noteEn;
  const FeedFormula({required this.titleSw, required this.titleEn, required this.stageSw, required this.stageEn, required this.baseKg, required this.ingredients, required this.noteSw, required this.noteEn});
}

class DiseaseGuide {
  final String nameSw;
  final String nameEn;
  final String causeSw;
  final String causeEn;
  final List<String> signsSw;
  final List<String> signsEn;
  final List<String> preventionSw;
  final List<String> preventionEn;
  final String treatmentSw;
  final String treatmentEn;
  final bool urgent;
  const DiseaseGuide({required this.nameSw, required this.nameEn, required this.causeSw, required this.causeEn, required this.signsSw, required this.signsEn, required this.preventionSw, required this.preventionEn, required this.treatmentSw, required this.treatmentEn, this.urgent = false});
}

const feedFormulas = <FeedFormula>[
  FeedFormula(
    titleSw: 'Chakula cha vifaranga wa asili', titleEn: 'Indigenous chick feed',
    stageSw: 'Kutotolewa hadi miezi 2', stageEn: 'Hatch to 2 months', baseKg: 100,
    ingredients: [MapEntry('Dagaa / fish meal', 14), MapEntry('Mahindi/mtama / grain', 40), MapEntry('Mashudu / oilseed cake', 20), MapEntry('Pumba / bran', 20.75), MapEntry('Chokaa / limestone', 2), MapEntry('Unga wa mifupa + premix', 2), MapEntry('Chumvi / salt', 0.25), MapEntry('Mchanga / grit', 1)],
    noteSw: 'Mfano wa kilo 100 kutoka kwenye mwongozo uliopakia. Dagaa umewekwa 14 kg katikati ya kiwango cha 12–15 kg; rekebisha kwa malighafi na ushauri wa mtaalamu wa lishe.',
    noteEn: '100 kg example from the uploaded guide. Fish meal is shown at 14 kg within the source range of 12–15 kg; adjust for ingredient quality with a poultry nutrition professional.'),
  FeedFormula(
    titleSw: 'Chakula cha kuku wa asili wanaokua', titleEn: 'Indigenous grower feed',
    stageSw: 'Baada ya miezi 2', stageEn: 'After 2 months', baseKg: 100,
    ingredients: [MapEntry('Dagaa / fish meal', 7), MapEntry('Mahindi/mtama / grain', 30), MapEntry('Mashudu / oilseed cake', 20), MapEntry('Pumba / bran', 37.75), MapEntry('Chokaa / limestone', 2), MapEntry('Unga wa mifupa + premix', 2), MapEntry('Chumvi / salt', 0.25), MapEntry('Mchanga / grit', 1)],
    noteSw: 'Formula ya kuku wanaokua baada ya miezi miwili; hakikisha jumla na ubora wa protini/madini vinathibitishwa kulingana na malighafi zako.',
    noteEn: 'Grower formula after two months; confirm nutrient quality and final balance for your local ingredients.'),
  FeedFormula(
    titleSw: 'Broiler Grower', titleEn: 'Broiler Grower',
    stageSw: 'Takriban siku 19–34', stageEn: 'About days 19–34', baseKg: 50.45,
    ingredients: [MapEntry('Mahindi / maize', 22), MapEntry('Pumba za mahindi / maize bran', 13), MapEntry('Damu / blood meal', 4), MapEntry('Mashudu / oilseed cake', 6), MapEntry('Dagaa/soya', 3), MapEntry('Chokaa + DCP', 2), MapEntry('Chumvi / salt', 0.1), MapEntry('Premix', 0.125), MapEntry('Lysine', 0.07), MapEntry('Methionine', 0.07), MapEntry('Threonine', 0.05), MapEntry('Toxin binder', 0.035)],
    noteSw: 'Imehamishwa kutoka kwenye mwongozo wa broiler uliopakia. Formula ya kibiashara inahitaji premix na malighafi sahihi; usibadilishe viwango vya additives bila mtaalamu.',
    noteEn: 'Transferred from the uploaded broiler guide. Commercial feed requires correct premix and ingredient specifications; do not alter additive levels without professional advice.'),
  FeedFormula(
    titleSw: 'Broiler Finisher', titleEn: 'Broiler Finisher',
    stageSw: 'Siku 35 hadi kuuzwa', stageEn: 'Day 35 to sale', baseKg: 50.45,
    ingredients: [MapEntry('Mahindi / maize', 25), MapEntry('Pumba za mahindi / maize bran', 10), MapEntry('Mashudu ya alizeti', 12), MapEntry('Dagaa', 2.5), MapEntry('Chokaa + DCP', 0.5), MapEntry('Chumvi / salt', 0.1), MapEntry('Premix', 0.125), MapEntry('Lysine', 0.07), MapEntry('Methionine', 0.07), MapEntry('Threonine', 0.05), MapEntry('Toxin binder', 0.035)],
    noteSw: 'Formula ya kumalizia makuzi kutoka kwenye mwongozo uliopakia.', noteEn: 'Finisher formula from the uploaded guide.'),
];

const diseases = <DiseaseGuide>[
  DiseaseGuide(
    nameSw: 'Kideri / Mdondo (Newcastle)', nameEn: 'Newcastle Disease', causeSw: 'Virusi', causeEn: 'Virus', urgent: true,
    signsSw: ['Kuzubaa, kushusha mabawa na kukosa hamu ya kula', 'Kupumua kwa shida, kukohoa/kupiga chafya', 'Shingo kupinda au kupooza', 'Kinyesi kijani na vifo vingi'],
    signsEn: ['Depression, drooped wings and poor appetite', 'Breathing difficulty, coughing/sneezing', 'Twisted neck or paralysis', 'Green droppings and potentially high mortality'],
    preventionSw: ['Chanjo kwa ratiba inayofaa eneo lako', 'Tenga wagonjwa na dhibiti watu/vifaa vinavyoingia bandani', 'Usafi na biosecurity'],
    preventionEn: ['Vaccination using a locally appropriate schedule', 'Isolate sick birds and control people/equipment movement', 'Hygiene and biosecurity'],
    treatmentSw: 'Mwongozo uliopakia unasema Newcastle ni ugonjwa wa virusi na hauna tiba maalumu; lengo ni kinga, isolation na supportive care chini ya daktari wa mifugo.',
    treatmentEn: 'The uploaded guide states Newcastle is viral and has no specific cure; focus on prevention, isolation and veterinary-directed supportive care.'),
  DiseaseGuide(
    nameSw: 'Ndui ya Kuku (Fowl Pox)', nameEn: 'Fowl Pox', causeSw: 'Virusi', causeEn: 'Virus',
    signsSw: ['Vipele sehemu zisizo na manyoya', 'Kupoteza hamu ya kula na uzito', 'Vipele vinaweza kuziba macho', 'Kamasi puani'],
    signsEn: ['Scabs on unfeathered areas', 'Poor appetite and weight loss', 'Lesions may obstruct the eyes', 'Nasal discharge'],
    preventionSw: ['Chanjo', 'Dhibiti mbu na maji yaliyotuama', 'Tenga kuku wagonjwa'], preventionEn: ['Vaccination', 'Mosquito/stagnant-water control', 'Separate sick birds'],
    treatmentSw: 'Mwongozo unasema ugonjwa wa virusi hauna tiba maalumu. Huduma ya majeraha inaweza kusaidia, lakini dawa/antibiotic za secondary infection zitumike tu kwa ushauri wa daktari wa mifugo.',
    treatmentEn: 'The guide describes it as viral with no specific cure. Wound support may help; antibiotics for secondary infection should only follow veterinary advice.'),
  DiseaseGuide(
    nameSw: 'Kuhara Damu (Coccidiosis)', nameEn: 'Coccidiosis', causeSw: 'Protozoa', causeEn: 'Protozoa', urgent: true,
    signsSw: ['Kinyesi chenye damu', 'Kudhoofu na kupungua uzito', 'Kushusha mabawa/kuzubaa', 'Kupoteza hamu ya kula'],
    signsEn: ['Bloody droppings', 'Weakness and weight loss', 'Drooped wings/depression', 'Loss of appetite'],
    preventionSw: ['Weka matandazo makavu', 'Usafi wa maji na vyombo', 'Tenganisha vifaranga na kuku wakubwa inapofaa'], preventionEn: ['Keep litter dry', 'Clean water and equipment', 'Separate chicks from older birds where appropriate'],
    treatmentSw: 'Vitabu ulivyopakia vinataja Amprolium na baadhi ya dawa za sulfa/anticoccidial. App haitoi dose moja kwa moja: tumia dawa iliyosajiliwa, lebo yake na ushauri wa daktari wa mifugo, hasa kwa withdrawal period ya mayai/nyama.',
    treatmentEn: 'Your uploaded books mention amprolium and some sulfa/anticoccidial products. The app does not prescribe a dose: use a registered product, its label and veterinary guidance, including egg/meat withdrawal periods.'),
  DiseaseGuide(
    nameSw: 'Homa ya Matumbo (Fowl Typhoid)', nameEn: 'Fowl Typhoid', causeSw: 'Bakteria', causeEn: 'Bacteria',
    signsSw: ['Homa na manyoya kusimama', 'Kukosa hamu ya kula', 'Kudhoofika', 'Utagaji kushuka'], signsEn: ['Fever and ruffled feathers', 'Poor appetite', 'Weakness', 'Reduced egg production'],
    preventionSw: ['Usafi wa banda, maji na chakula', 'Tenga wagonjwa', 'Epuka kusambaza vimelea kupitia vifaa'], preventionEn: ['Housing, water and feed hygiene', 'Separate sick birds', 'Prevent spread via equipment'],
    treatmentSw: 'Chanzo kinataja antibiotics/sulfa, lakini uchaguzi wa antibiotic unapaswa kufanywa na daktari wa mifugo kutokana na resistance, diagnosis na withdrawal period.', treatmentEn: 'The source mentions antibiotics/sulfa, but antibiotic selection should be veterinary-directed because of resistance, diagnosis and withdrawal periods.'),
  DiseaseGuide(
    nameSw: 'Mafua ya Kuku (Infectious Coryza)', nameEn: 'Infectious Coryza', causeSw: 'Bakteria', causeEn: 'Bacteria',
    signsSw: ['Uso/macho kuvimba', 'Kupumua kwa shida/kukoroma', 'Kamasi puani', 'Usaha wenye harufu'], signsEn: ['Facial/eye swelling', 'Difficult/noisy breathing', 'Nasal discharge', 'Foul-smelling discharge'],
    preventionSw: ['Tenga kuku wapya na wagonjwa', 'Usafi na ventilation', 'Punguza msongamano'], preventionEn: ['Quarantine new/sick birds', 'Hygiene and ventilation', 'Reduce overcrowding'],
    treatmentSw: 'Vitabu vinataja antibiotic kwa magonjwa ya bakteria; thibitisha diagnosis na dawa sahihi kwa daktari wa mifugo kabla ya kutumia antibiotic.', treatmentEn: 'The books mention antibiotics for bacterial disease; confirm diagnosis and the correct medicine with a veterinarian before use.'),
];

class PoultryKnowledgePage extends StatefulWidget {
  final String languageCode;
  const PoultryKnowledgePage({super.key, required this.languageCode});
  @override State<PoultryKnowledgePage> createState() => _PoultryKnowledgePageState();
}

class _PoultryKnowledgePageState extends State<PoultryKnowledgePage> {
  int tab = 0;
  double targetKg = 100;
  String query = '';
  String t(String sw, String en) => AppI18n.tr(widget.languageCode, sw, en);

  @override
  Widget build(BuildContext context) {
    final titles = [t('Chakula & Formula','Feed & Formulas'), t('Magonjwa','Diseases'), t('Banda & Usafi','Housing & Hygiene'), t('Kumbukumbu','Records')];
    return Column(children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F5132), Color(0xFF2E8B57)])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t('Poultry Solution Center','Poultry Solution Center'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(t('Maktaba ya offline ya lishe, afya, banda na usimamizi.','Offline library for nutrition, health, housing and management.'), style: const TextStyle(color: Colors.white70)),
        ]),
      ),
      SizedBox(height: 56, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(8), itemCount: titles.length, separatorBuilder: (_,__)=>const SizedBox(width:8), itemBuilder: (_,i)=>ChoiceChip(label: Text(titles[i]), selected: tab==i, onSelected: (_)=>setState(()=>tab=i)))),
      Expanded(child: [ _feed(), _diseases(), _housing(), _records() ][tab]),
    ]);
  }

  Widget _feed() => ListView(padding: const EdgeInsets.all(12), children: [
    Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t('Mpango wa msingi kwa aina ya kuku','Core feeding plan by bird type'), style: const TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
      const SizedBox(height:8),
      _bullet(t('Kienyeji: chick feed kutoka kutotolewa hadi miezi 2; baada ya hapo grower.','Indigenous: chick feed from hatch to 2 months; then grower.')),
      _bullet(t('Chotara: starter wiki 1–4; grower takriban wiki 5–10; kiasi huongezeka kadri umri unavyoongezeka.','Crossbred: starter weeks 1–4; grower roughly weeks 5–10; daily intake increases with age.')),
      _bullet(t('Layers: starter hadi takriban wiki 6, grower hadi kuanza kutaga, kisha layers mash.','Layers: starter to about week 6, grower until onset of lay, then layers mash.')),
      _bullet(t('Broiler: starter → grower → finisher; fuata target ya uzito na feed specification ya breed.','Broiler: starter → grower → finisher; follow breed weight targets and feed specifications.')),
    ]))),
    const SizedBox(height:12),
    Text(t('Feed Formula Calculator','Feed Formula Calculator'), style: const TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
    Slider(min: 10, max: 500, divisions: 49, value: targetKg.clamp(10,500).toDouble(), label:'${targetKg.toStringAsFixed(0)} kg', onChanged:(v)=>setState(()=>targetKg=v)),
    Text('${t('Kiasi unachotaka kutengeneza','Target batch')}: ${targetKg.toStringAsFixed(0)} kg', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
    const SizedBox(height:8),
    ...feedFormulas.map((f)=>_formulaCard(f)),
    Card(color: Colors.amber.shade50, child: Padding(padding: const EdgeInsets.all(12), child: Text(t('Tahadhari: Formula hizi zimetolewa/kuundwa kutoka kwenye vitabu ulivyopakia. Ubora wa mahindi, dagaa, mashudu na premix hubadilika; kwa chakula cha kibiashara thibitisha nutrient analysis na mtaalamu wa lishe ya kuku.','Caution: These formulas are transferred/structured from your uploaded books. Ingredient quality varies; for commercial feed, confirm nutrient analysis with a poultry nutrition professional.')))),
  ]);

  Widget _formulaCard(FeedFormula f) {
    final factor = targetKg / f.baseKg;
    return Card(margin: const EdgeInsets.only(bottom:10), child: ExpansionTile(
      title: Text(t(f.titleSw,f.titleEn), style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(t(f.stageSw,f.stageEn)),
      children: [Padding(padding: const EdgeInsets.fromLTRB(16,0,16,16), child: Column(children:[
        ...f.ingredients.map((e)=>Padding(padding: const EdgeInsets.symmetric(vertical:3), child: Row(children:[Expanded(child:Text(e.key)), Text('${(e.value*factor).toStringAsFixed(e.value*factor<1?3:2)} kg', style: const TextStyle(fontWeight: FontWeight.w700))]))),
        const Divider(), Text(t(f.noteSw,f.noteEn), style: TextStyle(color: Colors.grey.shade700)),
      ]))]
    ));
  }

  Widget _diseases() {
    final list = diseases.where((d)=>('${d.nameSw} ${d.nameEn} ${d.causeSw}').toLowerCase().contains(query.toLowerCase())).toList();
    return ListView(padding: const EdgeInsets.all(12), children:[
      TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), labelText:t('Tafuta ugonjwa au dalili','Search disease or signs')), onChanged:(v)=>setState(()=>query=v)),
      const SizedBox(height:10),
      Card(color: Colors.red.shade50, child: Padding(padding: const EdgeInsets.all(12), child: Text(t('Hii ni elimu na decision-support, si diagnosis. Vifo vya ghafla, dalili kali, au ugonjwa unaoenea haraka: tenga kuku wagonjwa na wasiliana na daktari/Afisa Mifugo. Dawa za antibiotic/anticoccidial zitumike kwa lebo, diagnosis na withdrawal period sahihi.','This is education and decision support, not a diagnosis. For sudden deaths, severe signs, or fast-spreading disease: isolate sick birds and contact a veterinarian/livestock officer. Use antibiotics/anticoccidials only with correct diagnosis, label directions and withdrawal periods.')))),
      const SizedBox(height:8),
      ...list.map((d)=>Card(margin: const EdgeInsets.only(bottom:10), child: ExpansionTile(
        leading: CircleAvatar(backgroundColor:d.urgent?Colors.red.shade100:Colors.green.shade100, child:Icon(d.urgent?Icons.warning_amber:Icons.health_and_safety)),
        title:Text(t(d.nameSw,d.nameEn), style: const TextStyle(fontWeight:FontWeight.bold)), subtitle:Text('${t('Chanzo','Cause')}: ${t(d.causeSw,d.causeEn)}'),
        children:[Padding(padding: const EdgeInsets.fromLTRB(16,0,16,16), child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          _sectionTitle(t('Dalili','Signs')), ...((widget.languageCode=='en'?d.signsEn:d.signsSw).map(_bullet)),
          _sectionTitle(t('Kinga','Prevention')), ...((widget.languageCode=='en'?d.preventionEn:d.preventionSw).map(_bullet)),
          _sectionTitle(t('Tiba / Hatua','Treatment / Action')), Text(t(d.treatmentSw,d.treatmentEn)),
        ]))]
      )))
    ]);
  }

  Widget _housing()=>ListView(padding:const EdgeInsets.all(12),children:[
    _infoCard(Icons.air,'Ventilation',t('Banda liingize hewa safi na libaki kavu. Unyevunyevu na msongamano huongeza hatari ya magonjwa.','Provide good airflow and keep the house dry. Moisture and overcrowding increase disease risk.')),
    _infoCard(Icons.square_foot,t('Nafasi','Space'),t('Miongozo uliopakia inaonyesha nafasi hutegemea umri na mfumo. Mfano: vifaranga 16 kwa m² hadi takriban wiki 4; kuku wakubwa wa asili karibu 4–8 kwa m² kutegemea mfumo.','Uploaded guides show stocking density depends on age/system. Example: about 16 chicks/m² to ~4 weeks; mature indigenous birds roughly 4–8/m² depending on system.')),
    _infoCard(Icons.water_drop,t('Maji','Water'),t('Maji safi yawepo muda wote. Vyombo visimwage maji kwenye matandazo na visafishwe mara kwa mara.','Provide clean water continuously. Drinkers should minimize litter wetting and be cleaned regularly.')),
    _infoCard(Icons.cleaning_services,t('Matandazo & Biosecurity','Litter & Biosecurity'),t('Ondoa sehemu zilizolowa, safisha feeders/drinkers, dhibiti wageni/vifaa, na tenga kuku wapya au wagonjwa.','Remove wet litter, clean feeders/drinkers, control visitors/equipment, and quarantine new or sick birds.')),
    _infoCard(Icons.egg,t('Viota','Nests'),t('Viota viwe sehemu tulivu, ya faragha na yenye mwanga hafifu ili kupunguza mayai kupotea/kuvunjika na tabia ya kula mayai.','Nests should be quiet, private and dim to reduce lost/broken eggs and egg-eating behavior.')),
  ]);

  Widget _records()=>ListView(padding:const EdgeInsets.all(12),children:[
    _infoCard(Icons.inventory_2,t('Kumbukumbu za uzalishaji','Production records'),t('Idadi ya kuku, mayai, hatch, vifo, uzito na feed consumption.','Bird counts, eggs, hatch, mortality, weight and feed consumption.')),
    _infoCard(Icons.medical_information,t('Afya','Health'),t('Magonjwa, tarehe za chanjo, dawa, waliotibiwa, waliopona na withdrawal period.','Diseases, vaccination dates, medicines, treated/recovered birds and withdrawal periods.')),
    _infoCard(Icons.payments,t('Fedha','Finance'),t('Gharama za vifaranga, chakula, dawa, vifaa, mayai/nyama iliyouzwa, mapato, faida na hasara.','Costs for chicks, feed, medicine and equipment; sales, income, profit and loss.')),
    _infoCard(Icons.analytics,t('KPIs za biashara','Business KPIs'),t('Hatch rate, mortality %, feed cost/bird, feed conversion (broiler), laying %, cost/egg na gross margin.','Hatch rate, mortality %, feed cost/bird, feed conversion (broiler), laying %, cost/egg and gross margin.')),
  ]);

  Widget _bullet(String s)=>Padding(padding:const EdgeInsets.only(bottom:5),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('•  '),Expanded(child:Text(s))]));
  Widget _sectionTitle(String s)=>Padding(padding:const EdgeInsets.only(top:10,bottom:5),child:Text(s,style:const TextStyle(fontWeight:FontWeight.w900)));
  Widget _infoCard(IconData icon,String title,String body)=>Card(margin:const EdgeInsets.only(bottom:10),child:ListTile(leading:CircleAvatar(child:Icon(icon)),title:Text(title,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Padding(padding:const EdgeInsets.only(top:6),child:Text(body))));
}
