
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyProfile {
  static const website = 'https://lafasoftware.co.tz';
  static const email = 'info@lafasoftware.co.tz';
  static const copyright = '© 2026 LAFA Software Company LTD. All rights reserved.';
}

class ContactSettings {
  String phone1;
  String phone2;
  String whatsapp;

  ContactSettings({this.phone1='', this.phone2='', this.whatsapp=''});

  static Future<ContactSettings> load() async {
    final p = await SharedPreferences.getInstance();
    return ContactSettings(
      phone1: p.getString('company_phone_1') ?? '+255767006454',
      phone2: p.getString('company_phone_2') ?? '',
      whatsapp: p.getString('company_whatsapp') ?? '+255767006454',
    );
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('company_phone_1', phone1.trim());
    await p.setString('company_phone_2', phone2.trim());
    await p.setString('company_whatsapp', whatsapp.trim());
  }
}

class AboutSupportPage extends StatefulWidget {
  final String languageCode;
  const AboutSupportPage({super.key, required this.languageCode});
  @override
  State<AboutSupportPage> createState()=>_AboutSupportPageState();
}

class _AboutSupportPageState extends State<AboutSupportPage> {
  ContactSettings settings = ContactSettings();
  bool loading = true;
  String t(String sw,String en)=>widget.languageCode=='en'?en:sw;

  @override
  void initState(){super.initState();_load();}
  Future<void> _load() async {
    settings = await ContactSettings.load();
    if(mounted)setState(()=>loading=false);
  }

  Future<void> _editContacts() async {
    final p1 = TextEditingController(text: settings.phone1);
    final p2 = TextEditingController(text: settings.phone2);
    final wa = TextEditingController(text: settings.whatsapp);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t('Hariri mawasiliano','Edit contact details')),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children:[
            TextField(controller:p1,keyboardType:TextInputType.phone,decoration:InputDecoration(labelText:t('Simu 1','Phone 1'))),
            const SizedBox(height:10),
            TextField(controller:p2,keyboardType:TextInputType.phone,decoration:InputDecoration(labelText:t('Simu 2','Phone 2'))),
            const SizedBox(height:10),
            TextField(controller:wa,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'WhatsApp')),
          ]),
        ),
        actions:[
          TextButton(onPressed:()=>Navigator.pop(context,false),child:Text(t('Ghairi','Cancel'))),
          FilledButton(onPressed:()=>Navigator.pop(context,true),child:Text(t('Hifadhi','Save'))),
        ],
      ),
    );
    if(ok==true){
      settings = ContactSettings(phone1:p1.text,phone2:p2.text,whatsapp:wa.text);
      await settings.save();
      if(mounted)setState((){});
    }
  }

  @override
  Widget build(BuildContext context){
    if(loading)return const Scaffold(body:Center(child:CircularProgressIndicator()));
    return Scaffold(
      appBar:AppBar(title:Text(t('Kuhusu & Mawasiliano','About & Support'))),
      body:ListView(padding:const EdgeInsets.all(16),children:[
        Container(
          padding:const EdgeInsets.all(18),
          decoration:BoxDecoration(
            gradient:const LinearGradient(colors:[Color(0xFF073B2A),Color(0xFF238A58)]),
            borderRadius:BorderRadius.circular(26),
          ),
          child:Column(children:[
            Image.asset('assets/lafa_poultry_solution_logo.png',width:120,height:120,fit:BoxFit.contain),
            const SizedBox(height:10),
            const Text('LAFA POULTRY SOLUTION PRO',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:21)),
            const SizedBox(height:5),
            Text(t('Professional Poultry Farm ERP • POS • Health • Production','Professional Poultry Farm ERP • POS • Health • Production'),
              textAlign:TextAlign.center,style:TextStyle(color:Colors.white.withValues(alpha:.84))),
          ]),
        ),
        const SizedBox(height:14),
        _row(Icons.language,'Website',CompanyProfile.website),
        _row(Icons.email_outlined,'Email',CompanyProfile.email),
        _row(Icons.phone_outlined,t('Simu 1','Phone 1'),settings.phone1.isEmpty?t('Bado haijawekwa','Not set'):settings.phone1),
        _row(Icons.phone_android,t('Simu 2','Phone 2'),settings.phone2.isEmpty?t('Bado haijawekwa','Not set'):settings.phone2),
        _row(Icons.chat_outlined,'WhatsApp',settings.whatsapp.isEmpty?t('Bado haijawekwa','Not set'):settings.whatsapp),
        const SizedBox(height:8),
        FilledButton.tonalIcon(onPressed:_editContacts,icon:const Icon(Icons.edit),label:Text(t('Hariri namba za simu / WhatsApp','Edit phone / WhatsApp'))),
        const SizedBox(height:18),
        Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(t('Mmiliki wa Programu','Software Owner'),style:const TextStyle(fontWeight:FontWeight.w900,fontSize:17)),
          const SizedBox(height:8),
          const Text('LAFA Software Company LTD',style:TextStyle(fontWeight:FontWeight.w800)),
          const SizedBox(height:4),
          const Text(CompanyProfile.copyright),
          const SizedBox(height:8),
          Text(t('Programu hii inalindwa na haki miliki. Matumizi, usambazaji au marekebisho yasiyoidhinishwa hayaruhusiwi.',
            'This software is protected by copyright. Unauthorized distribution or modification is not permitted.')),
        ]))),
      ]),
      bottomNavigationBar:SafeArea(child:Padding(
        padding:const EdgeInsets.all(12),
        child:Text(CompanyProfile.copyright,textAlign:TextAlign.center,style:Theme.of(context).textTheme.bodySmall),
      )),
    );
  }
  Widget _row(IconData icon,String title,String value)=>Card(
    child:ListTile(leading:CircleAvatar(child:Icon(icon)),title:Text(title),subtitle:Text(value,style:const TextStyle(fontWeight:FontWeight.w700)))
  );
}
