
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StockItem {
  final String id,name,category,unit;
  final double qty,costPrice,salePrice,reorderLevel;
  const StockItem({
    required this.id,required this.name,required this.category,required this.unit,
    required this.qty,required this.costPrice,required this.salePrice,required this.reorderLevel,
  });
  StockItem copyWith({double? qty,double? costPrice,double? salePrice,double? reorderLevel,String? name,String? category,String? unit})=>StockItem(
    id:id,name:name??this.name,category:category??this.category,unit:unit??this.unit,
    qty:qty??this.qty,costPrice:costPrice??this.costPrice,salePrice:salePrice??this.salePrice,reorderLevel:reorderLevel??this.reorderLevel);
  Map<String,dynamic> toJson()=>{'id':id,'name':name,'category':category,'unit':unit,'qty':qty,'costPrice':costPrice,'salePrice':salePrice,'reorderLevel':reorderLevel};
  factory StockItem.fromJson(Map<String,dynamic> j)=>StockItem(
    id:j['id'],name:j['name'],category:j['category']??'Other',unit:j['unit']??'unit',
    qty:(j['qty'] as num).toDouble(),costPrice:(j['costPrice'] as num?)?.toDouble()??0,
    salePrice:(j['salePrice'] as num?)?.toDouble()??0,reorderLevel:(j['reorderLevel'] as num?)?.toDouble()??0);
}

class PosSale {
  final String id,receiptNo,itemId,itemName,customer,payment,note;
  final double qty,unitPrice,costPrice,paid;
  final DateTime date;
  const PosSale({
    required this.id,required this.receiptNo,required this.itemId,required this.itemName,
    required this.qty,required this.unitPrice,required this.costPrice,required this.paid,required this.date,
    this.customer='',this.payment='Cash',this.note='',
  });
  double get total=>qty*unitPrice;
  double get debt=>(total-paid).clamp(0.0,double.infinity).toDouble();
  double get grossProfit=>(unitPrice-costPrice)*qty;
  Map<String,dynamic> toJson()=>{'id':id,'receiptNo':receiptNo,'itemId':itemId,'itemName':itemName,'customer':customer,'payment':payment,'note':note,'qty':qty,'unitPrice':unitPrice,'costPrice':costPrice,'paid':paid,'date':date.toIso8601String()};
  factory PosSale.fromJson(Map<String,dynamic> j)=>PosSale(
    id:j['id'],receiptNo:j['receiptNo'],itemId:j['itemId'],itemName:j['itemName'],
    customer:j['customer']??'',payment:j['payment']??'Cash',note:j['note']??'',
    qty:(j['qty'] as num).toDouble(),unitPrice:(j['unitPrice'] as num).toDouble(),
    costPrice:(j['costPrice'] as num?)?.toDouble()??0,paid:(j['paid'] as num?)?.toDouble()??0,date:DateTime.parse(j['date']));
}

class PurchaseRecord {
  final String id,itemId,itemName,supplier,payment,note;
  final double qty,unitCost,paid;
  final DateTime date;
  const PurchaseRecord({required this.id,required this.itemId,required this.itemName,required this.qty,required this.unitCost,required this.paid,required this.date,this.supplier='',this.payment='Cash',this.note=''});
  double get total=>qty*unitCost;
  double get balance=>(total-paid).clamp(0.0,double.infinity).toDouble();
  Map<String,dynamic> toJson()=>{'id':id,'itemId':itemId,'itemName':itemName,'supplier':supplier,'payment':payment,'note':note,'qty':qty,'unitCost':unitCost,'paid':paid,'date':date.toIso8601String()};
  factory PurchaseRecord.fromJson(Map<String,dynamic> j)=>PurchaseRecord(
    id:j['id'],itemId:j['itemId'],itemName:j['itemName'],supplier:j['supplier']??'',payment:j['payment']??'Cash',note:j['note']??'',
    qty:(j['qty'] as num).toDouble(),unitCost:(j['unitCost'] as num).toDouble(),paid:(j['paid'] as num?)?.toDouble()??0,date:DateTime.parse(j['date']));
}

class DebtPayment {
  final String id,saleId,customer,method;
  final double amount;
  final DateTime date;
  const DebtPayment({required this.id,required this.saleId,required this.customer,required this.amount,required this.date,this.method='Cash'});
  Map<String,dynamic> toJson()=>{'id':id,'saleId':saleId,'customer':customer,'amount':amount,'date':date.toIso8601String(),'method':method};
  factory DebtPayment.fromJson(Map<String,dynamic> j)=>DebtPayment(id:j['id'],saleId:j['saleId'],customer:j['customer']??'',amount:(j['amount'] as num).toDouble(),date:DateTime.parse(j['date']),method:j['method']??'Cash');
}

class CashClosing {
  final String id,note;
  final DateTime date;
  final double expectedCash,countedCash;
  const CashClosing({required this.id,required this.date,required this.expectedCash,required this.countedCash,this.note=''});
  double get variance=>countedCash-expectedCash;
  Map<String,dynamic> toJson()=>{'id':id,'date':date.toIso8601String(),'expectedCash':expectedCash,'countedCash':countedCash,'note':note};
  factory CashClosing.fromJson(Map<String,dynamic> j)=>CashClosing(id:j['id'],date:DateTime.parse(j['date']),expectedCash:(j['expectedCash'] as num).toDouble(),countedCash:(j['countedCash'] as num).toDouble(),note:j['note']??'');
}

class PosStore {
  List<StockItem> stock=[];
  List<PosSale> sales=[];
  List<PurchaseRecord> purchases=[];
  List<DebtPayment> debtPayments=[];
  List<CashClosing> closings=[];

  Future<void> load() async {
    final p=await SharedPreferences.getInstance();
    List<T> dec<T>(String key,T Function(Map<String,dynamic>) f){
      try{return (jsonDecode(p.getString(key)??'[]') as List).map((e)=>f(Map<String,dynamic>.from(e))).toList();}catch(_){return <T>[];}
    }
    stock=dec('pos_stock_v52',StockItem.fromJson);
    sales=dec('pos_sales_v52',PosSale.fromJson);
    purchases=dec('pos_purchases_v52',PurchaseRecord.fromJson);
    debtPayments=dec('pos_debt_payments_v52',DebtPayment.fromJson);
    closings=dec('pos_closings_v52',CashClosing.fromJson);
  }
  Future<void> save() async {
    final p=await SharedPreferences.getInstance();
    await p.setString('pos_stock_v52',jsonEncode(stock.map((e)=>e.toJson()).toList()));
    await p.setString('pos_sales_v52',jsonEncode(sales.map((e)=>e.toJson()).toList()));
    await p.setString('pos_purchases_v52',jsonEncode(purchases.map((e)=>e.toJson()).toList()));
    await p.setString('pos_debt_payments_v52',jsonEncode(debtPayments.map((e)=>e.toJson()).toList()));
    await p.setString('pos_closings_v52',jsonEncode(closings.map((e)=>e.toJson()).toList()));
  }
  double paidForSale(String saleId)=>debtPayments.where((x)=>x.saleId==saleId).fold(0,(a,b)=>a+b.amount);
  double saleDebt(PosSale s)=>(s.debt-paidForSale(s.id)).clamp(0.0,double.infinity).toDouble();
  double get totalReceivables=>sales.fold(0,(a,s)=>a+saleDebt(s));
  double get stockValue=>stock.fold(0,(a,s)=>a+s.qty*s.costPrice);
  List<StockItem> get lowStock=>stock.where((s)=>s.qty<=s.reorderLevel).toList();

  double salesIn(DateTime from,DateTime to)=>sales.where((x)=>!x.date.isBefore(from)&&x.date.isBefore(to)).fold(0,(a,b)=>a+b.total);
  double grossProfitIn(DateTime from,DateTime to)=>sales.where((x)=>!x.date.isBefore(from)&&x.date.isBefore(to)).fold(0,(a,b)=>a+b.grossProfit);
  double purchasesIn(DateTime from,DateTime to)=>purchases.where((x)=>!x.date.isBefore(from)&&x.date.isBefore(to)).fold(0,(a,b)=>a+b.total);
  double cashReceivedIn(DateTime from,DateTime to){
    final direct=sales.where((x)=>!x.date.isBefore(from)&&x.date.isBefore(to)&&x.payment=='Cash').fold(0.0,(a,b)=>a+b.paid);
    final debt=debtPayments.where((x)=>!x.date.isBefore(from)&&x.date.isBefore(to)&&x.method=='Cash').fold(0.0,(a,b)=>a+b.amount);
    return direct+debt;
  }
}

class PosInventoryPage extends StatefulWidget{
  final String languageCode;
  const PosInventoryPage({super.key,required this.languageCode});
  @override State<PosInventoryPage> createState()=>_PosInventoryPageState();
}
class _PosInventoryPageState extends State<PosInventoryPage> with SingleTickerProviderStateMixin{
  final store=PosStore(); late final TabController tabs; bool loading=true;
  String t(String sw,String en)=>widget.languageCode=='en'?en:sw;
  @override void initState(){super.initState();tabs=TabController(length:7,vsync:this);_load();}
  Future<void> _load()async{await store.load();if(mounted)setState(()=>loading=false);}
  Future<void> changed()async{await store.save();if(mounted)setState((){});}
  @override void dispose(){tabs.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    if(loading)return const Center(child:CircularProgressIndicator());
    final now=DateTime.now(),today=DateTime(now.year,now.month,now.day),tomorrow=today.add(const Duration(days:1));
    return Column(children:[
      Container(
        padding:const EdgeInsets.fromLTRB(14,12,14,12),
        decoration:const BoxDecoration(gradient:LinearGradient(colors:[Color(0xFF062F23),Color(0xFF176B43),Color(0xFF2D9B63)])),
        child:SafeArea(bottom:false,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(children:[const Icon(Icons.point_of_sale,color:Colors.white,size:34),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(t('Poultry POS & Inventory','Poultry POS & Inventory'),style:const TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.w900)),
            Text(t('Stock • Mauzo • Madeni • Purchases • Cash Closing','Stock • Sales • Debts • Purchases • Cash Closing'),style:TextStyle(color:Colors.white.withValues(alpha:.8))),
          ]))]),
          const SizedBox(height:12),
          Row(children:[
            _metric(t('Mauzo Leo','Sales Today'),store.salesIn(today,tomorrow)),
            _metric(t('Stock Value','Stock Value'),store.stockValue),
            _metric(t('Madeni','Receivables'),store.totalReceivables),
          ]),
          if(store.lowStock.isNotEmpty) Padding(padding:const EdgeInsets.only(top:10),child:Container(
            padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:Colors.orange.withValues(alpha:.18),borderRadius:BorderRadius.circular(12)),
            child:Row(children:[const Icon(Icons.warning_amber,color:Colors.white),const SizedBox(width:8),Expanded(child:Text('${store.lowStock.length} ${t('bidhaa ziko low stock','items are low stock')}',style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800)))]))),
        ])),
      ),
      TabBar(controller:tabs,isScrollable:true,tabs:[
        Tab(icon:const Icon(Icons.dashboard_outlined),text:t('Dashboard','Dashboard')),
        Tab(icon:const Icon(Icons.inventory_2_outlined),text:t('Stock','Stock')),
        Tab(icon:const Icon(Icons.shopping_cart_checkout),text:t('POS','POS')),
        Tab(icon:const Icon(Icons.local_shipping_outlined),text:t('Purchases','Purchases')),
        Tab(icon:const Icon(Icons.people_alt_outlined),text:t('Madeni','Debts')),
        Tab(icon:const Icon(Icons.receipt_long),text:t('Receipts','Receipts')),
        Tab(icon:const Icon(Icons.point_of_sale_outlined),text:t('Closing','Closing')),
      ]),
      Expanded(child:TabBarView(controller:tabs,children:[
        _Dash(store:store,lang:widget.languageCode),
        _Stock(store:store,onChanged:changed,lang:widget.languageCode),
        _Pos(store:store,onChanged:changed,lang:widget.languageCode),
        _Purchases(store:store,onChanged:changed,lang:widget.languageCode),
        _Debts(store:store,onChanged:changed,lang:widget.languageCode),
        _Receipts(store:store,lang:widget.languageCode),
        _Closing(store:store,onChanged:changed,lang:widget.languageCode),
      ]))
    ]);
  }
  Widget _metric(String l,double v)=>Expanded(child:Container(margin:const EdgeInsets.symmetric(horizontal:3),padding:const EdgeInsets.all(9),decoration:BoxDecoration(color:Colors.white.withValues(alpha:.12),borderRadius:BorderRadius.circular(14)),child:Column(children:[Text(l,style:const TextStyle(color:Colors.white,fontSize:10)),FittedBox(child:Text('TZS ${NumberFormat('#,##0').format(v)}',style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:15)))])));
}

class _Dash extends StatelessWidget{
  final PosStore store;final String lang;const _Dash({required this.store,required this.lang});
  String t(String sw,String en)=>lang=='en'?en:sw;
  DateTime startDay(DateTime d)=>DateTime(d.year,d.month,d.day);
  @override Widget build(BuildContext context){
    final now=DateTime.now(),today=startDay(now),tomorrow=today.add(const Duration(days:1));
    final week=today.subtract(Duration(days:today.weekday-1));
    final month=DateTime(now.year,now.month,1),nextMonth=DateTime(now.year,now.month+1,1);
    final todaySales=store.salesIn(today,tomorrow),weekSales=store.salesIn(week,tomorrow),monthSales=store.salesIn(month,nextMonth);
    final todayProfit=store.grossProfitIn(today,tomorrow),weekProfit=store.grossProfitIn(week,tomorrow),monthProfit=store.grossProfitIn(month,nextMonth);
    return ListView(padding:const EdgeInsets.all(14),children:[
      _section(t('Business Performance','Business Performance')),
      Row(children:[Expanded(child:_k(t('Today Sales','Today Sales'),todaySales)),Expanded(child:_k(t('Week Sales','Week Sales'),weekSales)),Expanded(child:_k(t('Month Sales','Month Sales'),monthSales))]),
      Row(children:[Expanded(child:_k(t('Today Gross Profit','Today Gross Profit'),todayProfit)),Expanded(child:_k(t('Week Gross Profit','Week Gross Profit'),weekProfit)),Expanded(child:_k(t('Month Gross Profit','Month Gross Profit'),monthProfit))]),
      const SizedBox(height:8),
      _section(t('Inventory Health','Inventory Health')),
      Card(child:ListTile(leading:const Icon(Icons.inventory),title:Text(t('Stock Value','Stock Value')),trailing:Text('TZS ${NumberFormat('#,##0').format(store.stockValue)}',style:const TextStyle(fontWeight:FontWeight.w900)))),
      Card(child:ListTile(leading:Icon(Icons.warning_amber,color:store.lowStock.isEmpty?Colors.green:Colors.orange),title:Text(t('Low Stock Items','Low Stock Items')),trailing:Text('${store.lowStock.length}',style:const TextStyle(fontWeight:FontWeight.w900,fontSize:20)))),
      Card(child:ListTile(leading:const Icon(Icons.credit_score),title:Text(t('Customer Receivables','Customer Receivables')),trailing:Text('TZS ${NumberFormat('#,##0').format(store.totalReceivables)}',style:const TextStyle(fontWeight:FontWeight.w900)))),
      if(store.lowStock.isNotEmpty)...[
        const SizedBox(height:8),_section(t('Stock Alerts','Stock Alerts')),
        ...store.lowStock.map((x)=>Card(color:Colors.orange.shade50,child:ListTile(leading:const Icon(Icons.notifications_active_outlined),title:Text(x.name),subtitle:Text('${t('Baki','Remaining')}: ${x.qty} ${x.unit} • ${t('Reorder','Reorder')}: ${x.reorderLevel}')))),
      ]
    ]);
  }
  Widget _section(String s)=>Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Text(s,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)));
  Widget _k(String l,double v)=>Card(child:Padding(padding:const EdgeInsets.all(10),child:Column(children:[Text(l,textAlign:TextAlign.center,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w700)),FittedBox(child:Text(NumberFormat.compact().format(v),style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)))])));
}

class _Stock extends StatelessWidget{
  final PosStore store;final Future<void> Function() onChanged;final String lang;
  const _Stock({required this.store,required this.onChanged,required this.lang});
  String t(String sw,String en)=>lang=='en'?en:sw;
  @override Widget build(BuildContext context)=>Scaffold(
    floatingActionButton:FloatingActionButton.extended(onPressed:()async{final x=await showDialog<StockItem>(context:context,builder:(_)=>_StockDialog(lang:lang));if(x!=null){store.stock.add(x);await onChanged();}},icon:const Icon(Icons.add),label:Text(t('Bidhaa','Item'))),
    body:store.stock.isEmpty?Center(child:Text(t('Ongeza stock: mayai, kuku, vifaranga, chakula, dawa...','Add stock: eggs, chickens, chicks, feed, medicine...'))):ListView.builder(padding:const EdgeInsets.all(12),itemCount:store.stock.length,itemBuilder:(c,i){final x=store.stock[i],low=x.qty<=x.reorderLevel;return Card(child:ListTile(
      leading:CircleAvatar(backgroundColor:low?Colors.orange.shade100:Colors.green.shade100,child:Icon(low?Icons.warning_amber:Icons.inventory_2_outlined)),
      title:Text(x.name,style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('${x.category} • ${x.qty} ${x.unit}\nCost TZS ${NumberFormat('#,##0').format(x.costPrice)} • Sell TZS ${NumberFormat('#,##0').format(x.salePrice)}'),
      trailing:PopupMenuButton<String>(onSelected:(v)async{
        if(v=='edit'){final e=await showDialog<StockItem>(context:context,builder:(_)=>_StockDialog(lang:lang,item:x));if(e!=null){store.stock[i]=e;await onChanged();}}
        if(v=='delete'){store.stock.removeAt(i);await onChanged();}
      },itemBuilder:(_)=>[PopupMenuItem(value:'edit',child:Text(t('Hariri','Edit'))),PopupMenuItem(value:'delete',child:Text(t('Futa','Delete')))]),
    ));})
  );
}
class _StockDialog extends StatefulWidget{final String lang;final StockItem? item;const _StockDialog({required this.lang,this.item});@override State<_StockDialog> createState()=>_StockDialogState();}
class _StockDialogState extends State<_StockDialog>{
  late final TextEditingController name,qty,cost,price,reorder,unit;late String category;
  String t(String sw,String en)=>widget.lang=='en'?en:sw;
  @override void initState(){super.initState();final x=widget.item;name=TextEditingController(text:x?.name??'');qty=TextEditingController(text:x==null?'0':'${x.qty}');cost=TextEditingController(text:x==null?'0':'${x.costPrice}');price=TextEditingController(text:x==null?'0':'${x.salePrice}');reorder=TextEditingController(text:x==null?'0':'${x.reorderLevel}');unit=TextEditingController(text:x?.unit??'unit');category=x?.category??'Eggs';}
  @override Widget build(BuildContext context)=>AlertDialog(title:Text(t('Stock Item','Stock Item')),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
    TextField(controller:name,decoration:InputDecoration(labelText:t('Jina','Name'))),
    DropdownButtonFormField(value:category,items:['Eggs','Chickens','Chicks','Feed','Medicine','Vaccine','Manure','Other'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>category=v!),decoration:InputDecoration(labelText:t('Aina','Category'))),
    TextField(controller:unit,decoration:InputDecoration(labelText:t('Unit (tray, bird, kg...)','Unit (tray, bird, kg...)'))),
    TextField(controller:qty,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:t('Opening Quantity','Opening Quantity'))),
    TextField(controller:cost,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Cost price',prefixText:'TZS ')),
    TextField(controller:price,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Selling price',prefixText:'TZS ')),
    TextField(controller:reorder,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:t('Low stock alert level','Low stock alert level'))),
  ])),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:Text(t('Ghairi','Cancel'))),FilledButton(onPressed:(){
    final q=double.tryParse(qty.text)??0,c=double.tryParse(cost.text)??0,p=double.tryParse(price.text)??0,r=double.tryParse(reorder.text)??0;if(name.text.trim().isEmpty)return;
    Navigator.pop(context,StockItem(id:widget.item?.id??DateTime.now().microsecondsSinceEpoch.toString(),name:name.text.trim(),category:category,unit:unit.text.trim().isEmpty?'unit':unit.text.trim(),qty:q,costPrice:c,salePrice:p,reorderLevel:r));
  },child:Text(t('Hifadhi','Save')))]);
}

class _Pos extends StatelessWidget{
  final PosStore store;final Future<void> Function() onChanged;final String lang;const _Pos({required this.store,required this.onChanged,required this.lang});
  String t(String sw,String en)=>lang=='en'?en:sw;
  @override Widget build(BuildContext context)=>Scaffold(
    floatingActionButton:FloatingActionButton.extended(onPressed:store.stock.isEmpty?null:()async{
      final s=await showDialog<PosSale>(context:context,builder:(_)=>_SaleDialog(stock:store.stock,lang:lang,saleNo:store.sales.length+1));
      if(s==null)return;final i=store.stock.indexWhere((x)=>x.id==s.itemId);if(i<0)return;final item=store.stock[i];
      if(s.qty>item.qty){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(t('Stock haitoshi','Insufficient stock'))));return;}
      store.stock[i]=item.copyWith(qty:item.qty-s.qty);store.sales.insert(0,s);await onChanged();
    },icon:const Icon(Icons.point_of_sale),label:Text(t('New Sale','New Sale'))),
    body:store.sales.isEmpty?Center(child:Text(t('Hakuna mauzo ya POS bado.','No POS sales yet.'))):ListView.builder(padding:const EdgeInsets.all(12),itemCount:store.sales.length,itemBuilder:(c,i){final s=store.sales[i];return Card(child:ListTile(
      leading:const CircleAvatar(child:Icon(Icons.receipt)),title:Text('${s.receiptNo} • ${s.itemName}',style:const TextStyle(fontWeight:FontWeight.w900)),
      subtitle:Text('${DateFormat('dd MMM yyyy HH:mm').format(s.date)} • ${s.qty} × TZS ${NumberFormat('#,##0').format(s.unitPrice)}\n${s.customer.isEmpty?t('Walk-in','Walk-in'):s.customer} • ${s.payment}'),
      trailing:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.end,children:[Text('TZS ${NumberFormat('#,##0').format(s.total)}',style:const TextStyle(fontWeight:FontWeight.w900)),if(store.saleDebt(s)>0)Text('${t('Debt','Debt')} ${NumberFormat('#,##0').format(store.saleDebt(s))}',style:const TextStyle(color:Colors.red,fontSize:11))]),
    ));})
  );
}
class _SaleDialog extends StatefulWidget{final List<StockItem> stock;final String lang;final int saleNo;const _SaleDialog({required this.stock,required this.lang,required this.saleNo});@override State<_SaleDialog> createState()=>_SaleDialogState();}
class _SaleDialogState extends State<_SaleDialog>{
  late String itemId;late TextEditingController qty,price,paid,customer,note;String payment='Cash';
  StockItem get item=>widget.stock.firstWhere((x)=>x.id==itemId);
  String t(String sw,String en)=>widget.lang=='en'?en:sw;
  @override void initState(){super.initState();itemId=widget.stock.first.id;qty=TextEditingController(text:'1');price=TextEditingController(text:'${widget.stock.first.salePrice}');paid=TextEditingController();customer=TextEditingController();note=TextEditingController();}
  @override Widget build(BuildContext context)=>AlertDialog(title:Text(t('Poultry POS Sale','Poultry POS Sale')),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
    DropdownButtonFormField(value:itemId,items:widget.stock.where((x)=>x.qty>0).map((x)=>DropdownMenuItem(value:x.id,child:Text('${x.name} (${x.qty} ${x.unit})'))).toList(),onChanged:(v)=>setState((){itemId=v!;price.text='${item.salePrice}';}),decoration:InputDecoration(labelText:t('Bidhaa','Item'))),
    TextField(controller:qty,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:t('Quantity','Quantity'))),
    TextField(controller:price,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Unit price',prefixText:'TZS ')),
    TextField(controller:customer,decoration:InputDecoration(labelText:t('Mteja','Customer'))),
    DropdownButtonFormField(value:payment,items:['Cash','Mobile Money','Bank','Credit'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>payment=v!),decoration:InputDecoration(labelText:t('Malipo','Payment'))),
    TextField(controller:paid,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:t('Kiasi kilicholipwa','Amount paid'),prefixText:'TZS ')),
    TextField(controller:note,decoration:InputDecoration(labelText:t('Maelezo','Notes'))),
  ])),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:Text(t('Ghairi','Cancel'))),FilledButton(onPressed:(){
    final q=double.tryParse(qty.text)??0,p=double.tryParse(price.text.replaceAll(',',''))??0,total=q*p;double pd=double.tryParse(paid.text.replaceAll(',',''))??(payment=='Credit'?0:total);if(q<=0||p<0||q>item.qty)return;pd=pd.clamp(0.0,total).toDouble();
    final no='LPS-${DateFormat('yyyyMMdd').format(DateTime.now())}-${widget.saleNo.toString().padLeft(4,'0')}';
    Navigator.pop(context,PosSale(id:DateTime.now().microsecondsSinceEpoch.toString(),receiptNo:no,itemId:item.id,itemName:item.name,qty:q,unitPrice:p,costPrice:item.costPrice,paid:pd,date:DateTime.now(),customer:customer.text.trim(),payment:payment,note:note.text.trim()));
  },child:Text(t('Complete Sale','Complete Sale')))]);
}

class _Purchases extends StatelessWidget{
 final PosStore store;final Future<void> Function() onChanged;final String lang;const _Purchases({required this.store,required this.onChanged,required this.lang});
 String t(String sw,String en)=>lang=='en'?en:sw;
 @override Widget build(BuildContext context)=>Scaffold(
  floatingActionButton:FloatingActionButton.extended(onPressed:store.stock.isEmpty?null:()async{final x=await showDialog<PurchaseRecord>(context:context,builder:(_)=>_PurchaseDialog(stock:store.stock,lang:lang));if(x!=null){final i=store.stock.indexWhere((s)=>s.id==x.itemId);final old=store.stock[i];store.stock[i]=old.copyWith(qty:old.qty+x.qty,costPrice:x.unitCost);store.purchases.insert(0,x);await onChanged();}},icon:const Icon(Icons.add_business),label:Text(t('Purchase','Purchase'))),
  body:store.purchases.isEmpty?Center(child:Text(t('Rekodi ununuzi; quantity itaongezwa kwenye stock.','Record purchases; quantity will be added to stock.'))):ListView(padding:const EdgeInsets.all(12),children:store.purchases.map((x)=>Card(child:ListTile(leading:const Icon(Icons.local_shipping),title:Text(x.itemName,style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('${DateFormat('dd MMM yyyy').format(x.date)} • ${x.qty} × TZS ${NumberFormat('#,##0').format(x.unitCost)}${x.supplier.isEmpty?'':' • ${x.supplier}'}'),trailing:Text('TZS ${NumberFormat('#,##0').format(x.total)}',style:const TextStyle(fontWeight:FontWeight.w900))))).toList())
 );
}
class _PurchaseDialog extends StatefulWidget{final List<StockItem> stock;final String lang;const _PurchaseDialog({required this.stock,required this.lang});@override State<_PurchaseDialog> createState()=>_PurchaseDialogState();}
class _PurchaseDialogState extends State<_PurchaseDialog>{
 late String itemId;final qty=TextEditingController(),cost=TextEditingController(),paid=TextEditingController(),supplier=TextEditingController(),note=TextEditingController();String payment='Cash';
 StockItem get item=>widget.stock.firstWhere((x)=>x.id==itemId);String t(String sw,String en)=>widget.lang=='en'?en:sw;
 @override void initState(){super.initState();itemId=widget.stock.first.id;cost.text='${widget.stock.first.costPrice}';}
 @override Widget build(BuildContext context)=>AlertDialog(title:Text(t('Stock Purchase','Stock Purchase')),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
  DropdownButtonFormField(value:itemId,items:widget.stock.map((x)=>DropdownMenuItem(value:x.id,child:Text(x.name))).toList(),onChanged:(v)=>setState((){itemId=v!;cost.text='${item.costPrice}';}),decoration:InputDecoration(labelText:t('Bidhaa','Item'))),
  TextField(controller:qty,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:t('Quantity','Quantity'))),
  TextField(controller:cost,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Unit cost',prefixText:'TZS ')),
  TextField(controller:supplier,decoration:InputDecoration(labelText:t('Supplier','Supplier'))),
  DropdownButtonFormField(value:payment,items:['Cash','Mobile Money','Bank','Credit'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>payment=v!),decoration:InputDecoration(labelText:t('Payment','Payment'))),
  TextField(controller:paid,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:t('Amount paid','Amount paid'),prefixText:'TZS ')),
  TextField(controller:note,decoration:InputDecoration(labelText:t('Maelezo','Notes'))),
 ])),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:Text(t('Ghairi','Cancel'))),FilledButton(onPressed:(){final q=double.tryParse(qty.text)??0,c=double.tryParse(cost.text)??0,total=q*c,pd=(double.tryParse(paid.text)??(payment=='Credit'?0.0:total)).clamp(0.0,total).toDouble();if(q<=0||c<0)return;Navigator.pop(context,PurchaseRecord(id:DateTime.now().microsecondsSinceEpoch.toString(),itemId:item.id,itemName:item.name,qty:q,unitCost:c,paid:pd,date:DateTime.now(),supplier:supplier.text.trim(),payment:payment,note:note.text.trim()));},child:Text(t('Receive Stock','Receive Stock')))]);
}

class _Debts extends StatelessWidget{
 final PosStore store;final Future<void> Function() onChanged;final String lang;const _Debts({required this.store,required this.onChanged,required this.lang});
 String t(String sw,String en)=>lang=='en'?en:sw;
 @override Widget build(BuildContext context){final debts=store.sales.where((s)=>store.saleDebt(s)>0).toList();return debts.isEmpty?Center(child:Text(t('Hakuna madeni ya wateja.','No customer receivables.'))):ListView(padding:const EdgeInsets.all(12),children:debts.map((s)=>Card(child:ListTile(
  leading:const CircleAvatar(child:Icon(Icons.person)),title:Text(s.customer.isEmpty?t('Mteja','Customer'):s.customer,style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('${s.receiptNo} • ${s.itemName}\n${t('Deni','Debt')}: TZS ${NumberFormat('#,##0').format(store.saleDebt(s))}'),
  trailing:FilledButton.tonal(onPressed:()async{final pay=await showDialog<DebtPayment>(context:context,builder:(_)=>_DebtDialog(sale:s,balance:store.saleDebt(s),lang:lang));if(pay!=null){store.debtPayments.add(pay);await onChanged();}},child:Text(t('Lipa','Pay')))
 ))).toList());}
}
class _DebtDialog extends StatefulWidget{final PosSale sale;final double balance;final String lang;const _DebtDialog({required this.sale,required this.balance,required this.lang});@override State<_DebtDialog> createState()=>_DebtDialogState();}
class _DebtDialogState extends State<_DebtDialog>{final amount=TextEditingController();String method='Cash';String t(String sw,String en)=>widget.lang=='en'?en:sw;@override Widget build(BuildContext context)=>AlertDialog(title:Text(t('Debt Payment','Debt Payment')),content:Column(mainAxisSize:MainAxisSize.min,children:[Text('${t('Balance','Balance')}: TZS ${NumberFormat('#,##0').format(widget.balance)}'),TextField(controller:amount,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Amount',prefixText:'TZS ')),DropdownButtonFormField(value:method,items:['Cash','Mobile Money','Bank'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>method=v!),decoration:InputDecoration(labelText:t('Method','Method')))]),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:Text(t('Ghairi','Cancel'))),FilledButton(onPressed:(){final a=double.tryParse(amount.text)??0;if(a<=0||a>widget.balance)return;Navigator.pop(context,DebtPayment(id:DateTime.now().microsecondsSinceEpoch.toString(),saleId:widget.sale.id,customer:widget.sale.customer,amount:a,date:DateTime.now(),method:method));},child:Text(t('Save Payment','Save Payment')))]);}
}

class _Receipts extends StatelessWidget{
 final PosStore store;final String lang;const _Receipts({required this.store,required this.lang});String t(String sw,String en)=>lang=='en'?en:sw;
 @override Widget build(BuildContext context)=>store.sales.isEmpty?Center(child:Text(t('Hakuna receipts bado.','No receipts yet.'))):ListView(padding:const EdgeInsets.all(12),children:store.sales.map((s)=>Card(child:ExpansionTile(
  leading:const Icon(Icons.receipt_long),title:Text(s.receiptNo,style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('${s.customer.isEmpty?t('Walk-in Customer','Walk-in Customer'):s.customer} • ${DateFormat('dd MMM yyyy HH:mm').format(s.date)}'),
  children:[Padding(padding:const EdgeInsets.fromLTRB(16,0,16,16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('${s.itemName}: ${s.qty} × TZS ${NumberFormat('#,##0').format(s.unitPrice)}'),Text('${t('TOTAL','TOTAL')}: TZS ${NumberFormat('#,##0').format(s.total)}',style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),
    Text('${t('Paid','Paid')}: TZS ${NumberFormat('#,##0').format(s.paid+store.paidForSale(s.id))}'),Text('${t('Balance','Balance')}: TZS ${NumberFormat('#,##0').format(store.saleDebt(s))}'),Text('${t('Payment','Payment')}: ${s.payment}')
  ]))]
 ))).toList());
}

class _Closing extends StatefulWidget{final PosStore store;final Future<void> Function() onChanged;final String lang;const _Closing({required this.store,required this.onChanged,required this.lang});@override State<_Closing> createState()=>_ClosingState();}
class _ClosingState extends State<_Closing>{
 final counted=TextEditingController(),note=TextEditingController();String t(String sw,String en)=>widget.lang=='en'?en:sw;
 @override Widget build(BuildContext context){final now=DateTime.now(),today=DateTime(now.year,now.month,now.day),tomorrow=today.add(const Duration(days:1)),expected=widget.store.cashReceivedIn(today,tomorrow);return ListView(padding:const EdgeInsets.all(16),children:[
  _box(t('Expected Cash Today','Expected Cash Today'),expected),
  TextField(controller:counted,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:t('Cash iliyohesabiwa','Counted cash'),prefixText:'TZS ')),
  TextField(controller:note,decoration:InputDecoration(labelText:t('Maelezo','Notes'))),
  const SizedBox(height:10),FilledButton.icon(onPressed:()async{final c=double.tryParse(counted.text.replaceAll(',',''));if(c==null)return;widget.store.closings.insert(0,CashClosing(id:DateTime.now().microsecondsSinceEpoch.toString(),date:DateTime.now(),expectedCash:expected,countedCash:c,note:note.text.trim()));await widget.onChanged();counted.clear();note.clear();},icon:const Icon(Icons.lock_clock),label:Text(t('Close Day','Close Day'))),
  const SizedBox(height:14),Text(t('Closing History','Closing History'),style:const TextStyle(fontWeight:FontWeight.w900,fontSize:18)),
  ...widget.store.closings.map((x)=>Card(child:ListTile(title:Text(DateFormat('dd MMM yyyy HH:mm').format(x.date)),subtitle:Text('Expected TZS ${NumberFormat('#,##0').format(x.expectedCash)} • Counted TZS ${NumberFormat('#,##0').format(x.countedCash)}'),trailing:Text('${x.variance>=0?'+':''}${NumberFormat('#,##0').format(x.variance)}',style:TextStyle(fontWeight:FontWeight.w900,color:x.variance==0?Colors.green:Colors.red))))),
 ]);}
 Widget _box(String l,double v)=>Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(children:[Text(l,style:const TextStyle(fontWeight:FontWeight.w800)),Text('TZS ${NumberFormat('#,##0').format(v)}',style:const TextStyle(fontSize:26,fontWeight:FontWeight.w900))])));
}
