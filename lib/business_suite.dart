
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class FarmTxn {
  final String id,type,category,note,payment;
  final double amount;
  final DateTime date;
  FarmTxn({required this.id,required this.type,required this.category,required this.amount,required this.date,this.note='',this.payment='Cash'});
  Map<String,dynamic> toJson()=>{'id':id,'type':type,'category':category,'amount':amount,'date':date.toIso8601String(),'note':note,'payment':payment};
  factory FarmTxn.fromJson(Map<String,dynamic> j)=>FarmTxn(id:j['id'],type:j['type'],category:j['category'],amount:(j['amount'] as num).toDouble(),date:DateTime.parse(j['date']),note:j['note']??'',payment:j['payment']??'Cash');
}
class SaleRecord {
  final String id,item,customer,payment,note;
  final double qty,unitPrice;
  final DateTime date;
  SaleRecord({required this.id,required this.item,required this.qty,required this.unitPrice,required this.date,this.customer='',this.payment='Cash',this.note=''});
  double get total=>qty*unitPrice;
  Map<String,dynamic> toJson()=>{'id':id,'item':item,'qty':qty,'unitPrice':unitPrice,'date':date.toIso8601String(),'customer':customer,'payment':payment,'note':note};
  factory SaleRecord.fromJson(Map<String,dynamic> j)=>SaleRecord(id:j['id'],item:j['item'],qty:(j['qty'] as num).toDouble(),unitPrice:(j['unitPrice'] as num).toDouble(),date:DateTime.parse(j['date']),customer:j['customer']??'',payment:j['payment']??'Cash',note:j['note']??'');
}
class BusinessStore{
  List<FarmTxn> txns=[]; List<SaleRecord> sales=[];
  Future<void> load()async{final p=await SharedPreferences.getInstance();try{txns=(jsonDecode(p.getString('farm_txns_v51')??'[]') as List).map((e)=>FarmTxn.fromJson(Map<String,dynamic>.from(e))).toList();}catch(_){txns=[];}try{sales=(jsonDecode(p.getString('farm_sales_v51')??'[]') as List).map((e)=>SaleRecord.fromJson(Map<String,dynamic>.from(e))).toList();}catch(_){sales=[];}}
  Future<void> save()async{final p=await SharedPreferences.getInstance();await p.setString('farm_txns_v51',jsonEncode(txns.map((e)=>e.toJson()).toList()));await p.setString('farm_sales_v51',jsonEncode(sales.map((e)=>e.toJson()).toList()));}
  double get salesTotal=>sales.fold(0,(a,b)=>a+b.total);
  double get otherIncome=>txns.where((x)=>x.type=='income').fold(0,(a,b)=>a+b.amount);
  double get expenses=>txns.where((x)=>x.type=='expense').fold(0,(a,b)=>a+b.amount);
  double get income=>salesTotal+otherIncome;
  double get profit=>income-expenses;
}

class BusinessSuitePage extends StatefulWidget{
 final String languageCode;
 const BusinessSuitePage({super.key,required this.languageCode});
 @override State<BusinessSuitePage> createState()=>_BusinessSuitePageState();
}
class _BusinessSuitePageState extends State<BusinessSuitePage> with SingleTickerProviderStateMixin{
 final store=BusinessStore(); late final TabController tabs; bool loading=true;
 String t(String sw,String en)=>widget.languageCode=='en'?en:sw;
 @override void initState(){super.initState();tabs=TabController(length:4,vsync:this);_load();}
 Future<void> _load()async{await store.load();if(mounted)setState(()=>loading=false);}
 Future<void> changed()async{await store.save();if(mounted)setState((){});}
 @override void dispose(){tabs.dispose();super.dispose();}
 @override Widget build(BuildContext context){
  if(loading)return const Center(child:CircularProgressIndicator());
  return Column(children:[
   Container(padding:const EdgeInsets.fromLTRB(14,12,14,10),decoration:const BoxDecoration(gradient:LinearGradient(colors:[Color(0xFF073B2A),Color(0xFF238A58)])),child:SafeArea(bottom:false,child:Column(children:[
    Row(children:[const Icon(Icons.storefront,color:Colors.white,size:34),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Text(t('Biashara ya Shamba','Farm Business'),style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),
     Text(t('Mauzo • Mapato • Matumizi • Faida','Sales • Income • Expenses • Profit'),style:TextStyle(color:Colors.white.withValues(alpha:.8)))
    ]))]),
    const SizedBox(height:12),Row(children:[_metric(t('Mapato','Income'),store.income),_metric(t('Matumizi','Expenses'),store.expenses),_metric(store.profit>=0?t('Faida','Profit'):t('Hasara','Loss'),store.profit)]),
   ]))),
   TabBar(controller:tabs,isScrollable:true,tabs:[
    Tab(icon:const Icon(Icons.point_of_sale),text:t('Mauzo','Sales')),
    Tab(icon:const Icon(Icons.south_west),text:t('Mapato','Income')),
    Tab(icon:const Icon(Icons.north_east),text:t('Matumizi','Expenses')),
    Tab(icon:const Icon(Icons.assessment_outlined),text:t('Ripoti','Report')),
   ]),
   Expanded(child:TabBarView(controller:tabs,children:[
    _Sales(store:store,onChanged:changed,lang:widget.languageCode),
    _Transactions(store:store,onChanged:changed,type:'income',lang:widget.languageCode),
    _Transactions(store:store,onChanged:changed,type:'expense',lang:widget.languageCode),
    _Report(store:store,lang:widget.languageCode),
   ]))
  ]);
 }
 Widget _metric(String l,double v)=>Expanded(child:Container(margin:const EdgeInsets.symmetric(horizontal:3),padding:const EdgeInsets.all(9),decoration:BoxDecoration(color:Colors.white.withValues(alpha:.12),borderRadius:BorderRadius.circular(14)),child:Column(children:[Text(l,style:const TextStyle(color:Colors.white,fontSize:11)),FittedBox(child:Text(NumberFormat('#,##0').format(v),style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:17)))])));
}

class _Sales extends StatelessWidget{
 final BusinessStore store;final Future<void> Function() onChanged;final String lang;
 const _Sales({required this.store,required this.onChanged,required this.lang});
 String t(String sw,String en)=>lang=='en'?en:sw;
 @override Widget build(BuildContext context)=>Scaffold(
  floatingActionButton:FloatingActionButton.extended(onPressed:()async{final s=await showDialog<SaleRecord>(context:context,builder:(_)=>_SaleDialog(lang:lang));if(s!=null){store.sales.insert(0,s);await onChanged();}},icon:const Icon(Icons.add_shopping_cart),label:Text(t('Rekodi Mauzo','Record Sale'))),
  body:store.sales.isEmpty?Center(child:Text(t('Bado hakuna mauzo. Bonyeza Rekodi Mauzo.','No sales yet. Tap Record Sale.'))):ListView.builder(padding:const EdgeInsets.all(12),itemCount:store.sales.length,itemBuilder:(c,i){final s=store.sales[i];return Card(child:ListTile(
   leading:const CircleAvatar(child:Icon(Icons.receipt_long)),title:Text(s.item,style:const TextStyle(fontWeight:FontWeight.w800)),
   subtitle:Text('${DateFormat('dd MMM yyyy').format(s.date)} • ${s.qty} × TZS ${NumberFormat('#,##0').format(s.unitPrice)}${s.customer.isEmpty?'':' • ${s.customer}'}\n${s.payment}'),
   trailing:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.end,children:[Text('TZS ${NumberFormat('#,##0').format(s.total)}',style:const TextStyle(fontWeight:FontWeight.w900)),IconButton(icon:const Icon(Icons.delete_outline,size:20),onPressed:()async{store.sales.removeAt(i);await onChanged();})]),
  ));})
 );
}
class _SaleDialog extends StatefulWidget{final String lang;const _SaleDialog({required this.lang});@override State<_SaleDialog> createState()=>_SaleDialogState();}
class _SaleDialogState extends State<_SaleDialog>{
 final item=TextEditingController(),qty=TextEditingController(text:'1'),price=TextEditingController(),customer=TextEditingController(),note=TextEditingController();String payment='Cash';
 String t(String sw,String en)=>widget.lang=='en'?en:sw;
 @override Widget build(BuildContext context)=>AlertDialog(title:Text(t('Rekodi Mauzo','Record Sale')),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
  TextField(controller:item,decoration:InputDecoration(labelText:t('Bidhaa: Kuku, Mayai, Vifaranga...','Item: Chicken, Eggs, Chicks...'))),
  TextField(controller:qty,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:t('Idadi/Quantity','Quantity'))),
  TextField(controller:price,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:t('Bei kwa unit','Unit price'),prefixText:'TZS ')),
  TextField(controller:customer,decoration:InputDecoration(labelText:t('Mteja (optional)','Customer (optional)'))),
  DropdownButtonFormField(value:payment,items:['Cash','Mobile Money','Bank','Credit'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>payment=v!),decoration:InputDecoration(labelText:t('Malipo','Payment'))),
  TextField(controller:note,decoration:InputDecoration(labelText:t('Maelezo','Notes'))),
 ])),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:Text(t('Ghairi','Cancel'))),FilledButton(onPressed:(){final q=double.tryParse(qty.text)??0,p=double.tryParse(price.text.replaceAll(',',''))??0;if(item.text.trim().isEmpty||q<=0||p<0)return;Navigator.pop(context,SaleRecord(id:DateTime.now().microsecondsSinceEpoch.toString(),item:item.text.trim(),qty:q,unitPrice:p,date:DateTime.now(),customer:customer.text.trim(),payment:payment,note:note.text.trim()));},child:Text(t('Hifadhi Mauzo','Save Sale')))]);
}

class _Transactions extends StatelessWidget{
 final BusinessStore store;final Future<void> Function() onChanged;final String type,lang;
 const _Transactions({required this.store,required this.onChanged,required this.type,required this.lang});
 String t(String sw,String en)=>lang=='en'?en:sw;
 @override Widget build(BuildContext context){final list=store.txns.where((x)=>x.type==type).toList();return Scaffold(
  floatingActionButton:FloatingActionButton.extended(onPressed:()async{final x=await showDialog<FarmTxn>(context:context,builder:(_)=>_TxnDialog(type:type,lang:lang));if(x!=null){store.txns.insert(0,x);await onChanged();}},icon:const Icon(Icons.add),label:Text(type=='income'?t('Ongeza Mapato','Add Income'):t('Ongeza Matumizi','Add Expense'))),
  body:list.isEmpty?Center(child:Text(type=='income'?t('Bado hakuna mapato mengine.','No other income yet.'):t('Bado hakuna matumizi.','No expenses yet.'))):ListView(padding:const EdgeInsets.all(12),children:list.map((x)=>Card(child:ListTile(
   leading:CircleAvatar(child:Icon(type=='income'?Icons.south_west:Icons.north_east)),title:Text(x.category,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${DateFormat('dd MMM yyyy').format(x.date)} • ${x.payment}${x.note.isEmpty?'':'\n${x.note}'}'),trailing:Text('TZS ${NumberFormat('#,##0').format(x.amount)}',style:const TextStyle(fontWeight:FontWeight.w900))
  ))).toList())
 );}
}
class _TxnDialog extends StatefulWidget{final String type,lang;const _TxnDialog({required this.type,required this.lang});@override State<_TxnDialog> createState()=>_TxnDialogState();}
class _TxnDialogState extends State<_TxnDialog>{
 final amount=TextEditingController(),note=TextEditingController();String category='',payment='Cash';
 String t(String sw,String en)=>widget.lang=='en'?en:sw;
 @override void initState(){super.initState();category=widget.type=='income'?'Other income':'Feed';}
 @override Widget build(BuildContext context){final cats=widget.type=='income'?['Other income','Egg income','Manure','Culled birds','Services']:['Feed','Chicks','Medicine/Vaccine','Labour','Water/Electricity','Transport','Housing/Equipment','Litter','Other'];return AlertDialog(title:Text(widget.type=='income'?t('Ongeza Mapato','Add Income'):t('Ongeza Matumizi','Add Expense')),content:Column(mainAxisSize:MainAxisSize.min,children:[
  DropdownButtonFormField(value:category,items:cats.map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>category=v!),decoration:InputDecoration(labelText:t('Aina','Category'))),
  TextField(controller:amount,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Amount',prefixText:'TZS ')),
  DropdownButtonFormField(value:payment,items:['Cash','Mobile Money','Bank','Credit'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>payment=v!),decoration:InputDecoration(labelText:t('Njia','Method'))),
  TextField(controller:note,decoration:InputDecoration(labelText:t('Maelezo','Notes')))
 ]),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:Text(t('Ghairi','Cancel'))),FilledButton(onPressed:(){final a=double.tryParse(amount.text.replaceAll(',',''))??0;if(a<=0)return;Navigator.pop(context,FarmTxn(id:DateTime.now().microsecondsSinceEpoch.toString(),type:widget.type,category:category,amount:a,date:DateTime.now(),note:note.text.trim(),payment:payment));},child:Text(t('Hifadhi','Save')))]);}
}
class _Report extends StatelessWidget{
 final BusinessStore store;final String lang;const _Report({required this.store,required this.lang});
 String t(String sw,String en)=>lang=='en'?en:sw;
 @override Widget build(BuildContext context){final margin=store.income<=0?0:store.profit/store.income*100;return ListView(padding:const EdgeInsets.all(16),children:[
  _r(t('Mauzo','Sales'),store.salesTotal),_r(t('Mapato mengine','Other income'),store.otherIncome),_r(t('Mapato yote','Total income'),store.income),_r(t('Matumizi yote','Total expenses'),store.expenses),_r(store.profit>=0?t('Faida halisi','Net profit'):t('Hasara','Loss'),store.profit),
  Card(child:ListTile(title:Text(t('Profit Margin','Profit Margin')),trailing:Text('${margin.toStringAsFixed(1)}%',style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)))),
  const SizedBox(height:10),Text(t('Muhtasari huu unatokana na mauzo, mapato na matumizi yaliyorekodiwa kwenye App.','This summary is calculated from sales, income and expenses recorded in the app.'),style:Theme.of(context).textTheme.bodySmall)
 ]);}
 Widget _r(String l,double v)=>Card(child:ListTile(title:Text(l),trailing:Text('TZS ${NumberFormat('#,##0').format(v)}',style:const TextStyle(fontWeight:FontWeight.w900,fontSize:18))));
}
