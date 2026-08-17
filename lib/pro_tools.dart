
import 'package:flutter/material.dart';

double _num(String v)=>double.tryParse(v.replaceAll(',',''))??0;

class ProToolsPage extends StatefulWidget{
  final String languageCode;
  const ProToolsPage({super.key,required this.languageCode});
  @override State<ProToolsPage> createState()=>_ProToolsPageState();
}
class _ProToolsPageState extends State<ProToolsPage> with SingleTickerProviderStateMixin{
  late final TabController c;
  @override void initState(){super.initState();c=TabController(length:4,vsync:this);}
  @override void dispose(){c.dispose();super.dispose();}
  String t(String sw,String en)=>widget.languageCode=='en'?en:sw;
  @override Widget build(BuildContext context)=>Column(children:[
    TabBar(controller:c,isScrollable:true,tabs:[
      Tab(icon:const Icon(Icons.account_balance_wallet_outlined),text:t('Faida/Hasara','Profit/Loss')),
      Tab(icon:const Icon(Icons.calculate_outlined),text:t('Mahesabu','Calculators')),
      Tab(icon:const Icon(Icons.water_drop_outlined),text:t('Kinyesi','Droppings')),
      Tab(icon:const Icon(Icons.question_answer_outlined),text:t('Maswali','Questions')),
    ]),
    Expanded(child:TabBarView(controller:c,children:[
      _Economics(lang:widget.languageCode),_FarmCalcs(lang:widget.languageCode),
      _Droppings(lang:widget.languageCode),_Questions(lang:widget.languageCode)
    ]))
  ]);
}

class _Economics extends StatefulWidget{final String lang;const _Economics({required this.lang});@override State<_Economics> createState()=>_EconomicsState();}
class _EconomicsState extends State<_Economics>{
  final m={for(final k in ['revenue','feed','birds','medicine','labour','utilities','housing','transport','other','sold']) k:TextEditingController()};
  String t(String sw,String en)=>widget.lang=='en'?en:sw;
  double n(String k)=>_num(m[k]!.text);
  @override Widget build(BuildContext context){
    final cost=n('feed')+n('birds')+n('medicine')+n('labour')+n('utilities')+n('housing')+n('transport')+n('other');
    final profit=n('revenue')-cost;
    final roi=cost<=0?0:profit/cost*100;
    final sold=n('sold');
    final be=sold<=0?0:cost/sold;
    return ListView(padding:const EdgeInsets.all(16),children:[
      _hero(t('Biashara ya Kundi','Flock Economics'),t('Ingiza mapato na gharama zote; App ihesabu Profit/Loss, ROI na Break-even.','Enter all revenue and costs; the app calculates Profit/Loss, ROI and Break-even.')),
      const SizedBox(height:12),
      _f('revenue',t('Mapato yote','Total revenue'),prefix:'TZS '),
      _f('feed',t('Chakula','Feed'),prefix:'TZS '),_f('birds',t('Vifaranga/kuku','Chicks/birds'),prefix:'TZS '),
      _f('medicine',t('Dawa na chanjo','Medicine & vaccines'),prefix:'TZS '),_f('labour',t('Wafanyakazi','Labour'),prefix:'TZS '),
      _f('utilities',t('Maji/umeme/fuel','Water/electricity/fuel'),prefix:'TZS '),_f('housing',t('Banda/equipment allocation','Housing/equipment allocation'),prefix:'TZS '),
      _f('transport',t('Transport','Transport'),prefix:'TZS '),_f('other',t('Gharama nyingine','Other costs'),prefix:'TZS '),
      _f('sold',t('Idadi inayouzwa','Birds sold')),
      const SizedBox(height:10),
      Row(children:[Expanded(child:_k(t('Gharama','Cost'),cost)),const SizedBox(width:8),Expanded(child:_k(profit>=0?t('Faida','Profit'):t('Hasara','Loss'),profit))]),
      Row(children:[Expanded(child:_k('ROI %',roi)),const SizedBox(width:8),Expanded(child:_k(t('Break-even/bird','Break-even/bird'),be))]),
    ]);
  }
  Widget _f(String k,String l,{String? prefix})=>Padding(padding:const EdgeInsets.only(bottom:8),child:TextField(controller:m[k],keyboardType:const TextInputType.numberWithOptions(decimal:true),onChanged:(_)=>setState((){}),decoration:InputDecoration(labelText:l,prefixText:prefix)));
  Widget _k(String l,double v)=>Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(children:[Text(l,style:const TextStyle(fontWeight:FontWeight.w700)),Text(v.toStringAsFixed(1),style:const TextStyle(fontSize:21,fontWeight:FontWeight.w900))])));
}
Widget _hero(String a,String b)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF073B2A),Color(0xFF2B8C59)]),borderRadius:BorderRadius.circular(22)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(a,style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:4),Text(b,style:TextStyle(color:Colors.white.withValues(alpha:.85)))]));

class _FarmCalcs extends StatefulWidget{final String lang;const _FarmCalcs({required this.lang});@override State<_FarmCalcs> createState()=>_FarmCalcsState();}
class _FarmCalcsState extends State<_FarmCalcs>{
  final x={for(final k in ['placed','deaths','hens','eggs','set','fertile','hatched','feed','gain'])k:TextEditingController()};
  String t(String sw,String en)=>widget.lang=='en'?en:sw;
  double n(String k)=>_num(x[k]!.text);
  @override Widget build(BuildContext context){
    double pct(double a,double b)=>b<=0?0:a/b*100;
    final mort=pct(n('deaths'),n('placed')), lay=pct(n('eggs'),n('hens')), fert=pct(n('fertile'),n('set')), hatch=pct(n('hatched'),n('fertile')), fcr=n('gain')<=0?0:n('feed')/n('gain');
    return ListView(padding:const EdgeInsets.all(16),children:[
      _card(t('Mortality Rate','Mortality Rate'),['placed','deaths'],[t('Kuku waliowekwa','Birds placed'),t('Vifo','Deaths')],'${mort.toStringAsFixed(2)}%'),
      _card(t('Egg Production Rate','Egg Production Rate'),['hens','eggs'],[t('Kuku hai wanaotaga','Live hens'),t('Mayai leo','Eggs today')],'${lay.toStringAsFixed(2)}%'),
      _card(t('Fertility & Hatch','Fertility & Hatch'),['set','fertile','hatched'],[t('Mayai yaliyowekwa','Eggs set'),t('Mayai fertile','Fertile eggs'),t('Vifaranga','Chicks hatched')],'Fertility ${fert.toStringAsFixed(1)}% • Hatch ${hatch.toStringAsFixed(1)}%'),
      _card('FCR',['feed','gain'],[t('Chakula kg','Feed kg'),t('Uzito ulioongezeka kg','Weight gain kg')],fcr.toStringAsFixed(3)),
    ]);
  }
  Widget _card(String title,List<String> ks,List<String> labels,String result)=>Card(margin:const EdgeInsets.only(bottom:12),child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(height:8),
    for(int i=0;i<ks.length;i++) Padding(padding:const EdgeInsets.only(bottom:8),child:TextField(controller:x[ks[i]],keyboardType:const TextInputType.numberWithOptions(decimal:true),onChanged:(_)=>setState((){}),decoration:InputDecoration(labelText:labels[i]))),
    Container(width:double.infinity,padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:const Color(0xFFE8F4ED),borderRadius:BorderRadius.circular(12)),child:Text(result,textAlign:TextAlign.center,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)))
  ])));
}

class _Droppings extends StatefulWidget{final String lang;const _Droppings({required this.lang});@override State<_Droppings> createState()=>_DroppingsState();}
class _DroppingsState extends State<_Droppings>{
  String q='';
  final items=const [
    ['Brown + white cap','Mara nyingi normal ikiwa kuku yuko active, anakula na kunywa kawaida.','Monitor; colour alone is not a diagnosis.'],
    ['Dark brown / cecal','Cecal dropping inaweza kuwa soft, sticky na dark-brown mara chache.','Ikiwa inakuwa frequent, watery, bloody au performance inashuka, chunguza zaidi.'],
    ['Green','Inaweza kuonekana kuku akipunguza kula na pia kwenye magonjwa mbalimbali; si Newcastle peke yake.','Angalia appetite, breathing, neurologic signs, mortality, heat stress na feed changes.'],
    ['Yellow / yellow-green','Inaweza kuambatana na enteric/systemic disease au bile-rich droppings wakati kuku hali.','Persistent cases zinahitaji veterinary assessment.'],
    ['White / chalky','White component ni urate; excessive white diarrhoea hasa kwa chicks inahitaji uchunguzi.','Check pasted vents, dehydration, brooder temperature, depression na mortality.'],
    ['Bloody / red','Abnormal; intestinal bleeding. Coccidiosis ni differential muhimu hasa kwa young birds.','Urgent: isolate, keep litter dry, seek diagnosis and correct anticoccidial plan.'],
    ['Black / tarry','Inaweza kuwa digested blood au diet; persistent tarry droppings ni abnormal.','Check weakness/pallor and seek veterinary examination if persistent.'],
    ['Watery / foamy','Inaweza kutokana na heat, excess water, diet change, gut irritation, parasites au enteric disease.','Review feed, water, litter moisture and flock performance.'],
  ];
  @override Widget build(BuildContext context){
    final list=items.where((e)=>e.join(' ').toLowerCase().contains(q.toLowerCase())).toList();
    return ListView(padding:const EdgeInsets.all(16),children:[
      TextField(decoration:const InputDecoration(prefixIcon:Icon(Icons.search),labelText:'Tafuta rangi / Search'),onChanged:(v)=>setState(()=>q=v)),
      const SizedBox(height:8),
      Card(color:Colors.amber.shade50,child:const Padding(padding:EdgeInsets.all(12),child:Text('Rangi ya kinyesi ni clue, si diagnosis. Tumia pamoja na dalili, umri, feed, water intake, mortality na flock performance.'))),
      ...list.map((e)=>Card(child:ExpansionTile(title:Text(e[0],style:const TextStyle(fontWeight:FontWeight.w900)),children:[Padding(padding:const EdgeInsets.fromLTRB(16,0,16,16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(e[1]),const SizedBox(height:8),Text('Hatua: ${e[2]}')]))])))
    ]);
  }
}

class _Questions extends StatefulWidget{final String lang;const _Questions({required this.lang});@override State<_Questions> createState()=>_QuestionsState();}
class _QuestionsState extends State<_Questions>{
  String q='';
  final qa=const [
    ['Kwa nini kuku wanaharisha damu?','Coccidiosis ni sababu muhimu hasa kwa kuku wadogo, lakini diagnosis haitolewi kwa rangi pekee. Tenga wagonjwa, kausha matandazo, hakikisha maji safi na tafuta ushauri wa mtaalamu.'],
    ['Kinyesi cha kijani maana yake nini?','Kinaweza kuonekana kuku anapopunguza kula na pia kwenye magonjwa mbalimbali. Hakithibitishi Newcastle peke yake. Angalia dalili nyingine na mortality.'],
    ['Ninahesabuje profit?','Profit = Mapato yote - Gharama zote. ROI = Profit ÷ Gharama × 100.'],
    ['Ninahesabuje FCR?','FCR = kilo za chakula kilicholiwa ÷ kilo za uzito ulioongezeka.'],
    ['Ninahesabuje hatch rate?','Hatch rate = vifaranga vilivyotoka ÷ mayai fertile × 100. Fertility rate = mayai fertile ÷ mayai yaliyowekwa × 100.'],
    ['Nikiona vifo vingi ghafla nifanye nini?','Tenga kundi, punguza movement ya watu/vifaa, hifadhi taarifa za dalili na vifo, na wasiliana haraka na Afisa/Daktari wa Mifugo.'],
  ];
  @override Widget build(BuildContext context){
    final list=qa.where((e)=>e.join(' ').toLowerCase().contains(q.toLowerCase())).toList();
    return ListView(padding:const EdgeInsets.all(16),children:[
      TextField(decoration:const InputDecoration(prefixIcon:Icon(Icons.search),labelText:'Uliza / Search'),onChanged:(v)=>setState(()=>q=v)),
      const SizedBox(height:8),
      ...list.map((e)=>Card(child:ExpansionTile(title:Text(e[0],style:const TextStyle(fontWeight:FontWeight.w800)),children:[Padding(padding:const EdgeInsets.fromLTRB(16,0,16,16),child:Text(e[1]))])))
    ]);
  }
}
