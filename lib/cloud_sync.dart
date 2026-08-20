
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_cms.dart';

class CloudSyncConfig {
  static const String baseUrl = 'https://lafasoftware.co.tz/lafa-poultry-api';
  static const String contentEndpoint = '$baseUrl/content.php';
  static const String versionEndpoint = '$baseUrl/version.php';
}

class CloudSyncResult {
  final bool ok;
  final String message;
  final int remoteVersion;
  final int imported;
  const CloudSyncResult({required this.ok,required this.message,this.remoteVersion=0,this.imported=0});
}

class CloudSyncService {
  static const _lastSyncKey='cloud_last_sync_v55';
  static const _remoteVersionKey='cloud_remote_version_v55';
  static const _autoSyncKey='cloud_auto_sync_v55';

  final AdminStore adminStore=AdminStore();

  Future<DateTime?> lastSync() async {
    final p=await SharedPreferences.getInstance();
    final v=p.getString(_lastSyncKey);
    return v==null?null:DateTime.tryParse(v);
  }

  Future<int> localRemoteVersion() async {
    final p=await SharedPreferences.getInstance();
    return p.getInt(_remoteVersionKey)??0;
  }

  Future<bool> autoSyncEnabled() async {
    final p=await SharedPreferences.getInstance();
    return p.getBool(_autoSyncKey)??true;
  }

  Future<void> setAutoSync(bool value) async {
    final p=await SharedPreferences.getInstance();
    await p.setBool(_autoSyncKey,value);
  }

  Future<int> checkRemoteVersion() async {
    final res=await http.get(Uri.parse(CloudSyncConfig.versionEndpoint)).timeout(const Duration(seconds:15));
    if(res.statusCode!=200)throw Exception('Server returned ${res.statusCode}');
    final data=jsonDecode(res.body);
    if(data is! Map)throw Exception('Invalid version response');
    return (data['version'] as num?)?.toInt()??0;
  }

  Future<CloudSyncResult> syncNow() async {
    try{
      final remote=await checkRemoteVersion();
      final current=await localRemoteVersion();
      if(remote<=current){
        final p=await SharedPreferences.getInstance();
        await p.setString(_lastSyncKey,DateTime.now().toIso8601String());
        return CloudSyncResult(ok:true,message:'Content is already up to date.',remoteVersion:remote,imported:0);
      }

      final uri=Uri.parse('${CloudSyncConfig.contentEndpoint}?version=$remote');
      final res=await http.get(uri).timeout(const Duration(seconds:30));
      if(res.statusCode!=200)throw Exception('Server returned ${res.statusCode}');
      final data=jsonDecode(res.body);
      if(data is! Map)throw Exception('Invalid content response');
      final raw=(data['items'] as List? ?? []);
      final incoming=raw.map((e)=>CmsItem.fromJson(Map<String,dynamic>.from(e))).toList();

      // Cloud-published content replaces prior cloud content pack. Local Admin content can still be
      // exported/imported separately if needed.
      await adminStore.saveItems(incoming);

      final p=await SharedPreferences.getInstance();
      await p.setInt(_remoteVersionKey,remote);
      await p.setString(_lastSyncKey,DateTime.now().toIso8601String());

      return CloudSyncResult(ok:true,message:'Updated successfully.',remoteVersion:remote,imported:incoming.length);
    }catch(e){
      return CloudSyncResult(ok:false,message:'Sync failed: $e');
    }
  }

  Future<void> autoSyncIfEnabled() async {
    if(!await autoSyncEnabled())return;
    await syncNow();
  }
}

class CloudSyncPage extends StatefulWidget {
  final String languageCode;
  const CloudSyncPage({super.key,required this.languageCode});
  @override State<CloudSyncPage> createState()=>_CloudSyncPageState();
}

class _CloudSyncPageState extends State<CloudSyncPage> {
  final service=CloudSyncService();
  bool loading=true,autoSync=true,syncing=false;
  DateTime? last;
  int version=0;
  String t(String sw,String en)=>widget.languageCode=='en'?en:sw;

  @override void initState(){super.initState();_load();}
  Future<void> _load()async{
    autoSync=await service.autoSyncEnabled();
    last=await service.lastSync();
    version=await service.localRemoteVersion();
    if(mounted)setState(()=>loading=false);
  }

  Future<void> _sync()async{
    setState(()=>syncing=true);
    final r=await service.syncNow();
    last=await service.lastSync();
    version=await service.localRemoteVersion();
    if(mounted){
      setState(()=>syncing=false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(
        r.ok
          ? (r.imported>0?t('Maudhui ${r.imported} yamesasishwa.','${r.imported} content items updated.'):t('App tayari ina content mpya.','Content is already up to date.'))
          : r.message
      )));
    }
  }

  @override Widget build(BuildContext context){
    if(loading)return const Scaffold(body:Center(child:CircularProgressIndicator()));
    return Scaffold(
      appBar:AppBar(title:Text(t('Cloud Content Sync','Cloud Content Sync'))),
      body:ListView(padding:const EdgeInsets.all(16),children:[
        Container(
          padding:const EdgeInsets.all(18),
          decoration:BoxDecoration(
            gradient:const LinearGradient(colors:[Color(0xFF073B2A),Color(0xFF258D5B)]),
            borderRadius:BorderRadius.circular(24),
          ),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Icon(Icons.cloud_sync,color:Colors.white,size:38),
            const SizedBox(height:8),
            Text(t('LAFA Cloud Update System','LAFA Cloud Update System'),style:const TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w900)),
            const SizedBox(height:5),
            Text(t('Pokea magonjwa, tiba, formula, FAQ, vaccination notes na announcements kutoka server bila APK mpya.',
              'Receive diseases, treatment notes, feed content, FAQs, vaccination notes and announcements from the server without a new APK.'),
              style:TextStyle(color:Colors.white.withValues(alpha:.85))),
          ]),
        ),
        const SizedBox(height:14),
        Card(child:SwitchListTile(
          value:autoSync,
          onChanged:(v)async{await service.setAutoSync(v);setState(()=>autoSync=v);},
          secondary:const Icon(Icons.sync),
          title:Text(t('Auto Sync','Auto Sync')),
          subtitle:Text(t('App itajaribu kusync content inapofunguliwa ikiwa internet ipo.','The app will try to sync content when opened if internet is available.')),
        )),
        Card(child:ListTile(
          leading:const Icon(Icons.tag),
          title:Text(t('Content Version','Content Version')),
          trailing:Text('$version',style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
        )),
        Card(child:ListTile(
          leading:const Icon(Icons.schedule),
          title:Text(t('Last Sync','Last Sync')),
          subtitle:Text(last==null?t('Bado haijasync','Never synced'):last.toString()),
        )),
        const SizedBox(height:12),
        FilledButton.icon(
          onPressed:syncing?null:_sync,
          icon:syncing?const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.cloud_download),
          label:Text(syncing?t('Inasync...','Syncing...'):t('Check & Sync Now','Check & Sync Now')),
        ),
        const SizedBox(height:16),
        Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(t('Offline First','Offline First'),style:const TextStyle(fontWeight:FontWeight.w900,fontSize:17)),
          const SizedBox(height:6),
          Text(t('Internet ikikosekana, App itaendelea kutumia content iliyohifadhiwa kwenye simu. Sync itajaribiwa tena internet ikipatikana.',
            'If internet is unavailable, the app continues using locally saved content and can sync again when connectivity returns.')),
        ]))),
      ]),
    );
  }
}
