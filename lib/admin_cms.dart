
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CmsItem {
  final String id;
  final String type;
  final String titleSw;
  final String titleEn;
  final String bodySw;
  final String bodyEn;
  final String tags;
  final bool published;
  final DateTime updatedAt;

  const CmsItem({
    required this.id,
    required this.type,
    required this.titleSw,
    required this.titleEn,
    required this.bodySw,
    required this.bodyEn,
    this.tags='',
    this.published=true,
    required this.updatedAt,
  });

  CmsItem copyWith({
    String? type,String? titleSw,String? titleEn,String? bodySw,String? bodyEn,
    String? tags,bool? published,DateTime? updatedAt,
  }) => CmsItem(
    id:id,type:type??this.type,titleSw:titleSw??this.titleSw,titleEn:titleEn??this.titleEn,
    bodySw:bodySw??this.bodySw,bodyEn:bodyEn??this.bodyEn,tags:tags??this.tags,
    published:published??this.published,updatedAt:updatedAt??this.updatedAt,
  );

  Map<String,dynamic> toJson()=>{
    'id':id,'type':type,'titleSw':titleSw,'titleEn':titleEn,'bodySw':bodySw,'bodyEn':bodyEn,
    'tags':tags,'published':published,'updatedAt':updatedAt.toIso8601String()
  };

  factory CmsItem.fromJson(Map<String,dynamic> j)=>CmsItem(
    id:j['id']??DateTime.now().microsecondsSinceEpoch.toString(),
    type:j['type']??'Guide',
    titleSw:j['titleSw']??'',
    titleEn:j['titleEn']??'',
    bodySw:j['bodySw']??'',
    bodyEn:j['bodyEn']??'',
    tags:j['tags']??'',
    published:j['published']??true,
    updatedAt:DateTime.tryParse(j['updatedAt']??'')??DateTime.now(),
  );
}

class AdminStore {
  static const _itemsKey='admin_cms_items_v54';
  static const _pinKey='admin_pin_v54';

  Future<List<CmsItem>> loadItems() async {
    final p=await SharedPreferences.getInstance();
    try{
      final raw=jsonDecode(p.getString(_itemsKey)??'[]') as List;
      return raw.map((e)=>CmsItem.fromJson(Map<String,dynamic>.from(e))).toList();
    }catch(_){return [];}
  }

  Future<void> saveItems(List<CmsItem> items) async {
    final p=await SharedPreferences.getInstance();
    await p.setString(_itemsKey,jsonEncode(items.map((e)=>e.toJson()).toList()));
  }

  Future<bool> hasPin() async {
    final p=await SharedPreferences.getInstance();
    return (p.getString(_pinKey)??'').isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final p=await SharedPreferences.getInstance();
    // Local app lock. The stored value is obfuscated, not intended as enterprise cryptography.
    await p.setString(_pinKey,base64Encode(utf8.encode('LAFA:$pin:POULTRY')));
  }

  Future<bool> verifyPin(String pin) async {
    final p=await SharedPreferences.getInstance();
    return p.getString(_pinKey)==base64Encode(utf8.encode('LAFA:$pin:POULTRY'));
  }

  Future<void> clearPin() async {
    final p=await SharedPreferences.getInstance();
    await p.remove(_pinKey);
  }

  Future<String> exportJson(List<CmsItem> items) async {
    final payload={
      'product':'LAFA Poultry Solution Pro',
      'format':'LAFA-CONTENT-PACK-v1',
      'exportedAt':DateTime.now().toIso8601String(),
      'items':items.map((e)=>e.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<List<CmsItem>> importJson(String text) async {
    final obj=jsonDecode(text);
    final raw=(obj is Map ? obj['items'] : obj) as List;
    return raw.map((e)=>CmsItem.fromJson(Map<String,dynamic>.from(e))).toList();
  }
}

class AdminGatePage extends StatefulWidget {
  final String languageCode;
  const AdminGatePage({super.key,required this.languageCode});
  @override State<AdminGatePage> createState()=>_AdminGatePageState();
}

class _AdminGatePageState extends State<AdminGatePage>{
  final store=AdminStore();
  final pin=TextEditingController();
  bool loading=true,hasPin=false;
  String t(String sw,String en)=>widget.languageCode=='en'?en:sw;

  @override void initState(){super.initState();_load();}
  Future<void> _load() async {
    hasPin=await store.hasPin();
    if(mounted)setState(()=>loading=false);
  }

  Future<void> _go() async {
    final value=pin.text.trim();
    if(value.length<4){
      _msg(t('PIN iwe angalau tarakimu/herufi 4.','PIN must be at least 4 characters.'));
      return;
    }
    if(!hasPin){
      await store.setPin(value);
      if(!mounted)return;
      Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>AdminCenterPage(languageCode:widget.languageCode)));
      return;
    }
    if(await store.verifyPin(value)){
      if(!mounted)return;
      Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>AdminCenterPage(languageCode:widget.languageCode)));
    }else{
      _msg(t('PIN si sahihi.','Incorrect PIN.'));
    }
  }

  void _msg(String m)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(m)));

  @override Widget build(BuildContext context){
    if(loading)return const Scaffold(body:Center(child:CircularProgressIndicator()));
    return Scaffold(
      appBar:AppBar(title:Text(t('Admin Login','Admin Login'))),
      body:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(20),child:ConstrainedBox(
        constraints:const BoxConstraints(maxWidth:480),
        child:Card(child:Padding(padding:const EdgeInsets.all(20),child:Column(children:[
          const CircleAvatar(radius:34,child:Icon(Icons.admin_panel_settings,size:36)),
          const SizedBox(height:12),
          Text(hasPin?t('Ingiza Admin PIN','Enter Admin PIN'):t('Tengeneza Admin PIN','Create Admin PIN'),
            style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900)),
          const SizedBox(height:8),
          Text(hasPin
            ?t('Admin Center inalinda maudhui na settings za mfumo.','Admin Center protects content and system settings.')
            :t('Hii ni mara ya kwanza. Chagua PIN utakayotumia kufungua Admin Center.','First-time setup: choose a PIN for Admin Center.'),
            textAlign:TextAlign.center),
          const SizedBox(height:16),
          TextField(controller:pin,obscureText:true,decoration:InputDecoration(prefixIcon:const Icon(Icons.lock_outline),labelText:'Admin PIN')),
          const SizedBox(height:14),
          SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:_go,icon:const Icon(Icons.login),label:Text(hasPin?t('Fungua Admin','Open Admin'):t('Hifadhi PIN & Endelea','Save PIN & Continue')))),
        ]))),
      ))),
    );
  }
}

class AdminCenterPage extends StatefulWidget{
  final String languageCode;
  const AdminCenterPage({super.key,required this.languageCode});
  @override State<AdminCenterPage> createState()=>_AdminCenterPageState();
}
class _AdminCenterPageState extends State<AdminCenterPage>{
  final store=AdminStore();
  List<CmsItem> items=[];
  bool loading=true;
  String filter='All';
  String query='';
  String t(String sw,String en)=>widget.languageCode=='en'?en:sw;

  @override void initState(){super.initState();_load();}
  Future<void> _load()async{items=await store.loadItems();if(mounted)setState(()=>loading=false);}
  Future<void> _save()async{await store.saveItems(items);if(mounted)setState((){});}

  Future<void> _edit([CmsItem? initial]) async {
    final x=await showDialog<CmsItem>(context:context,builder:(_)=>CmsEditorDialog(initial:initial,languageCode:widget.languageCode));
    if(x==null)return;
    final i=items.indexWhere((e)=>e.id==x.id);
    if(i>=0)items[i]=x;else items.insert(0,x);
    await _save();
  }

  Future<void> _export() async {
    final text=await store.exportJson(items);
    final dir=await getTemporaryDirectory();
    final file=File('${dir.path}/LAFA_Poultry_Content_Pack_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(text);
    await Share.shareXFiles([XFile(file.path)],text:t('LAFA Poultry content pack','LAFA Poultry content pack'));
  }

  Future<void> _import() async {
    final pick=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['json'],withData:true);
    if(pick==null)return;
    final f=pick.files.single;
    String text;
    if(f.bytes!=null){text=utf8.decode(f.bytes!);}
    else if(f.path!=null){text=await File(f.path!).readAsString();}
    else{return;}
    try{
      final imported=await store.importJson(text);
      final replace=await showDialog<bool>(context:context,builder:(_)=>AlertDialog(
        title:Text(t('Import Content Pack','Import Content Pack')),
        content:Text(t('Replace maudhui yote ya Admin na content pack hii? Chagua Cancel kama hutaki kubadilisha data.','Replace all Admin content with this content pack?')),
        actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:Text(t('Ghairi','Cancel'))),FilledButton(onPressed:()=>Navigator.pop(context,true),child:Text(t('Import','Import')))],
      ));
      if(replace==true){items=imported;await _save();}
    }catch(e){
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('${t('Import imeshindikana','Import failed')}: $e')));
    }
  }

  Future<void> _resetPin() async {
    final ok=await showDialog<bool>(context:context,builder:(_)=>AlertDialog(
      title:Text(t('Reset Admin PIN?','Reset Admin PIN?')),
      content:Text(t('Utahitaji kutengeneza PIN mpya mara nyingine utakapoingia Admin.','You will create a new PIN on the next Admin login.')),
      actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:Text(t('Ghairi','Cancel'))),FilledButton(onPressed:()=>Navigator.pop(context,true),child:Text(t('Reset','Reset')))],
    ));
    if(ok==true){await store.clearPin();if(mounted)Navigator.pop(context);}
  }

  @override Widget build(BuildContext context){
    if(loading)return const Scaffold(body:Center(child:CircularProgressIndicator()));
    final visible=items.where((x){
      final okType=filter=='All'||x.type==filter;
      final q=query.trim().toLowerCase();
      final okQ=q.isEmpty||'${x.titleSw} ${x.titleEn} ${x.bodySw} ${x.bodyEn} ${x.tags}'.toLowerCase().contains(q);
      return okType&&okQ;
    }).toList();
    final published=items.where((x)=>x.published).length;

    return Scaffold(
      appBar:AppBar(
        title:Text(t('Admin & Content Manager','Admin & Content Manager')),
        actions:[
          PopupMenuButton<String>(
            onSelected:(v){if(v=='export')_export();if(v=='import')_import();if(v=='pin')_resetPin();},
            itemBuilder:(_)=>[
              PopupMenuItem(value:'export',child:ListTile(leading:const Icon(Icons.upload_file),title:Text(t('Export Content Pack','Export Content Pack')))),
              PopupMenuItem(value:'import',child:ListTile(leading:const Icon(Icons.download_for_offline_outlined),title:Text(t('Import Content Pack','Import Content Pack')))),
              PopupMenuItem(value:'pin',child:ListTile(leading:const Icon(Icons.password),title:Text(t('Reset Admin PIN','Reset Admin PIN')))),
            ],
          )
        ],
      ),
      floatingActionButton:FloatingActionButton.extended(onPressed:()=>_edit(),icon:const Icon(Icons.add),label:Text(t('Ongeza Content','Add Content'))),
      body:ListView(padding:const EdgeInsets.fromLTRB(16,16,16,100),children:[
        Container(
          padding:const EdgeInsets.all(18),
          decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF073B2A),Color(0xFF218B59)]),borderRadius:BorderRadius.circular(24)),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Icon(Icons.admin_panel_settings,color:Colors.white,size:36),
            const SizedBox(height:8),
            Text(t('LAFA Poultry Admin Center','LAFA Poultry Admin Center'),style:const TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w900)),
            const SizedBox(height:5),
            Text(t('Ongeza na uboreshe maudhui bila kujenga APK mpya. Export/Import Content Pack kwa updates za haraka.',
              'Add and improve content without rebuilding the APK. Export/Import Content Packs for fast updates.'),style:TextStyle(color:Colors.white.withValues(alpha:.85))),
            const SizedBox(height:12),
            Row(children:[
              Expanded(child:_metric(t('Jumla','Total'),'${items.length}')),
              const SizedBox(width:8),
              Expanded(child:_metric(t('Published','Published'),'$published')),
              const SizedBox(width:8),
              Expanded(child:_metric(t('Drafts','Drafts'),'${items.length-published}')),
            ]),
          ]),
        ),
        const SizedBox(height:14),
        Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(children:[
          TextField(decoration:InputDecoration(prefixIcon:const Icon(Icons.search),labelText:t('Tafuta content','Search content')),onChanged:(v)=>setState(()=>query=v)),
          const SizedBox(height:10),
          SizedBox(height:46,child:ListView(scrollDirection:Axis.horizontal,children:[
            for(final type in ['All','Disease','Treatment','Feed','FAQ','Guide','Vaccination','Announcement'])
              Padding(padding:const EdgeInsets.only(right:8),child:ChoiceChip(label:Text(type),selected:filter==type,onSelected:(_)=>setState(()=>filter=type))),
          ])),
        ]))),
        const SizedBox(height:10),
        if(visible.isEmpty) Card(child:Padding(padding:const EdgeInsets.all(22),child:Column(children:[
          const Icon(Icons.library_add_outlined,size:44),
          const SizedBox(height:8),
          Text(t('Hakuna content hapa bado.','No content here yet.'),style:const TextStyle(fontWeight:FontWeight.w900)),
          Text(t('Bonyeza “Ongeza Content” kuongeza ugonjwa, tiba, formula, FAQ, guide au announcement.','Tap “Add Content” to add a disease, treatment, feed note, FAQ, guide or announcement.'),textAlign:TextAlign.center),
        ]))),
        ...visible.map((x)=>Padding(padding:const EdgeInsets.only(bottom:10),child:Card(child:ListTile(
          leading:CircleAvatar(child:Icon(_typeIcon(x.type))),
          title:Text(widget.languageCode=='en'&&x.titleEn.isNotEmpty?x.titleEn:x.titleSw,style:const TextStyle(fontWeight:FontWeight.w900)),
          subtitle:Text('${x.type} • ${x.published?t('Published','Published'):t('Draft','Draft')}'),
          trailing:PopupMenuButton<String>(
            onSelected:(v)async{
              final i=items.indexWhere((e)=>e.id==x.id);
              if(i<0)return;
              if(v=='edit')await _edit(x);
              if(v=='publish'){items[i]=x.copyWith(published:!x.published,updatedAt:DateTime.now());await _save();}
              if(v=='delete'){items.removeAt(i);await _save();}
            },
            itemBuilder:(_)=>[
              PopupMenuItem(value:'edit',child:ListTile(leading:const Icon(Icons.edit_outlined),title:Text(t('Hariri','Edit')))),
              PopupMenuItem(value:'publish',child:ListTile(leading:Icon(x.published?Icons.visibility_off_outlined:Icons.publish),title:Text(x.published?t('Weka Draft','Unpublish'):t('Publish','Publish')))),
              PopupMenuItem(value:'delete',child:ListTile(leading:const Icon(Icons.delete_outline),title:Text(t('Futa','Delete')))),
            ],
          ),
          onTap:()=>_edit(x),
        )))),
      ]),
    );
  }
  Widget _metric(String l,String v)=>Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:Colors.white.withValues(alpha:.12),borderRadius:BorderRadius.circular(14)),child:Column(children:[Text(v,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:20)),Text(l,style:const TextStyle(color:Colors.white,fontSize:11))]));
}

class ManagedKnowledgePage extends StatefulWidget{
  final String languageCode;
  const ManagedKnowledgePage({super.key,required this.languageCode});
  @override State<ManagedKnowledgePage> createState()=>_ManagedKnowledgePageState();
}
class _ManagedKnowledgePageState extends State<ManagedKnowledgePage>{
  final store=AdminStore();
  List<CmsItem> items=[];bool loading=true;String query='';String type='All';
  String t(String sw,String en)=>widget.languageCode=='en'?en:sw;
  @override void initState(){super.initState();_load();}
  Future<void> _load()async{items=(await store.loadItems()).where((x)=>x.published).toList();if(mounted)setState(()=>loading=false);}
  @override Widget build(BuildContext context){
    if(loading)return const Scaffold(body:Center(child:CircularProgressIndicator()));
    final data=items.where((x){
      final okT=type=='All'||x.type==type;final q=query.toLowerCase();
      return okT&&(q.isEmpty||'${x.titleSw} ${x.titleEn} ${x.bodySw} ${x.bodyEn} ${x.tags}'.toLowerCase().contains(q));
    }).toList();
    return Scaffold(
      appBar:AppBar(title:Text(t('Knowledge Updates','Knowledge Updates'))),
      body:ListView(padding:const EdgeInsets.all(16),children:[
        TextField(decoration:InputDecoration(prefixIcon:const Icon(Icons.search),labelText:t('Tafuta maudhui','Search knowledge')),onChanged:(v)=>setState(()=>query=v)),
        const SizedBox(height:10),
        SizedBox(height:46,child:ListView(scrollDirection:Axis.horizontal,children:[
          for(final x in ['All','Disease','Treatment','Feed','FAQ','Guide','Vaccination','Announcement'])
            Padding(padding:const EdgeInsets.only(right:8),child:ChoiceChip(label:Text(x),selected:type==x,onSelected:(_)=>setState(()=>type=x))),
        ])),
        const SizedBox(height:10),
        if(data.isEmpty)Card(child:Padding(padding:const EdgeInsets.all(20),child:Text(t('Hakuna content iliyopublish bado. Admin anaweza kuongeza kupitia Admin Center.','No published custom content yet. Admin can add it in Admin Center.'),textAlign:TextAlign.center))),
        ...data.map((x)=>Card(child:ExpansionTile(
          leading:Icon(_typeIcon(x.type)),
          title:Text(widget.languageCode=='en'&&x.titleEn.isNotEmpty?x.titleEn:x.titleSw,style:const TextStyle(fontWeight:FontWeight.w900)),
          subtitle:Text(x.type),
          children:[Padding(padding:const EdgeInsets.fromLTRB(16,0,16,16),child:Align(alignment:Alignment.centerLeft,child:Text(widget.languageCode=='en'&&x.bodyEn.isNotEmpty?x.bodyEn:x.bodySw)))],
        ))),
      ]),
    );
  }
}

class CmsEditorDialog extends StatefulWidget{
  final CmsItem? initial;final String languageCode;
  const CmsEditorDialog({super.key,this.initial,required this.languageCode});
  @override State<CmsEditorDialog> createState()=>_CmsEditorDialogState();
}
class _CmsEditorDialogState extends State<CmsEditorDialog>{
  late final TextEditingController titleSw,titleEn,bodySw,bodyEn,tags;
  late String type;late bool published;
  String t(String sw,String en)=>widget.languageCode=='en'?en:sw;
  @override void initState(){
    super.initState();final x=widget.initial;
    titleSw=TextEditingController(text:x?.titleSw??'');titleEn=TextEditingController(text:x?.titleEn??'');
    bodySw=TextEditingController(text:x?.bodySw??'');bodyEn=TextEditingController(text:x?.bodyEn??'');tags=TextEditingController(text:x?.tags??'');
    type=x?.type??'Guide';published=x?.published??true;
  }
  @override Widget build(BuildContext context)=>AlertDialog(
    title:Text(widget.initial==null?t('Ongeza Content','Add Content'):t('Hariri Content','Edit Content')),
    content:SizedBox(width:600,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      DropdownButtonFormField<String>(initialValue:type,decoration:InputDecoration(labelText:t('Aina','Type')),items:['Disease','Treatment','Feed','FAQ','Guide','Vaccination','Announcement'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>type=v??type)),
      const SizedBox(height:10),
      TextField(controller:titleSw,decoration:const InputDecoration(labelText:'Kichwa - Kiswahili')),
      const SizedBox(height:10),
      TextField(controller:titleEn,decoration:const InputDecoration(labelText:'Title - English')),
      const SizedBox(height:10),
      TextField(controller:bodySw,maxLines:7,decoration:const InputDecoration(labelText:'Maelezo / Content - Kiswahili')),
      const SizedBox(height:10),
      TextField(controller:bodyEn,maxLines:7,decoration:const InputDecoration(labelText:'Content - English')),
      const SizedBox(height:10),
      TextField(controller:tags,decoration:InputDecoration(labelText:t('Tags (mf. coccidiosis, broiler, feed)','Tags (e.g. coccidiosis, broiler, feed)'))),
      SwitchListTile(contentPadding:EdgeInsets.zero,value:published,onChanged:(v)=>setState(()=>published=v),title:Text(t('Publish mara moja','Publish immediately'))),
    ]))),
    actions:[
      TextButton(onPressed:()=>Navigator.pop(context),child:Text(t('Ghairi','Cancel'))),
      FilledButton(onPressed:(){
        if(titleSw.text.trim().isEmpty&&titleEn.text.trim().isEmpty)return;
        Navigator.pop(context,CmsItem(
          id:widget.initial?.id??DateTime.now().microsecondsSinceEpoch.toString(),type:type,
          titleSw:titleSw.text.trim(),titleEn:titleEn.text.trim(),bodySw:bodySw.text.trim(),bodyEn:bodyEn.text.trim(),
          tags:tags.text.trim(),published:published,updatedAt:DateTime.now(),
        ));
      },child:Text(t('Hifadhi','Save'))),
    ],
  );
}

IconData _typeIcon(String type){
  switch(type){
    case 'Disease': return Icons.coronavirus_outlined;
    case 'Treatment': return Icons.medication_outlined;
    case 'Feed': return Icons.restaurant_outlined;
    case 'FAQ': return Icons.question_answer_outlined;
    case 'Vaccination': return Icons.vaccines_outlined;
    case 'Announcement': return Icons.campaign_outlined;
    default: return Icons.menu_book_outlined;
  }
}
