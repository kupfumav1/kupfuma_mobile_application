import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_funds_v1/auth.dart';
import 'package:get_funds_v1/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:semicircle_indicator/semicircle_indicator.dart';
import 'package:footer/footer.dart';
import 'package:footer/footer_view.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:textfield_datepicker/textfield_datepicker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
Future<void> signOut() async {
  await Auth().signOut();
}

class HomePage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  HomePage({Key? key}) : super(key: key);
  final User? user = Auth().currentUser;
  @override
  HomePageState createState() => HomePageState();
  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }
}

class HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  // Check if the user is signed in
  Column _buildInsightColumn(Color color,Color color2, String amount,String desc) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 10, // <-- SEE HERE
        ),
        Text(amount,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: color2,
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          child: Text(
            desc,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color2,
            ),
          ),
        ),
        SizedBox(
          height: 10, // <-- SEE HERE
        ),
      ],
    );
  }
  Column _buildInsight2Column(Color color,Color color2,String desc2, String amount,String desc) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 10, // <-- SEE HERE
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child:Text(desc2),
        ),
        Text(amount,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: color2,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: Text(
            desc,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color2,
            ),
          ),
        ),
        SizedBox(
          height: 10, // <-- SEE HERE
        ),
      ],
    );
  }
  List<_SalesData> data = [];
  List<_SalesData> data2 = [];
  Color insightColor1 = Colors.black;
  Color insightColor2 = Colors.blue;
  Color insightColor3 = Colors.grey;
  Color insightColor4 = Colors.green;
  Color insightColor5 = Colors.redAccent;
  Color insightColor6 = Colors.white;
  double totalRevenue=0;
  double totalExpenses=0;
  double averageRevenue=0;
  double percentageRevenue=0;
  int countRevenue=0;
  double total=0;
  double rp=0;
  double cp=0;
  double np=0;



  late DatabaseReference dbRef;
  late DatabaseReference reference;
  late DatabaseReference budget_reference;
  String sme='';
  String UserName="";
  final date=DateTime. now();
  final  salesTargetController = TextEditingController();
  final  actionPlanController= TextEditingController();
  final  revenueBudgetController =TextEditingController();
  final  fixedCostsController =TextEditingController();
  final  revenueTargetController =TextEditingController();
  final  expensesTargetController =TextEditingController();
  double fixedCosts=0.0;
  double fr=0.0;
  @override
  void initState() {
    super.initState();
      String uid = user?.uid ?? 'uid'; // <-- Their email
    String mail = user?.email ?? 'email';
    dbRef = FirebaseDatabase.instance.ref().child('budgets/');
    budget_reference = FirebaseDatabase.instance.ref().child('budgets/'+uid);
    getStudentData();
    FirebaseDatabase.instance.ref().child('User/').onChildAdded.listen((event) {
      Map user = event.snapshot.value as Map;
      if(user['email']==mail){
        setState((){
          sme=user['sme'];
          UserName=user['fname'];
        });

        print(sme);
      }
    });
    FirebaseDatabase.instance.ref().child('budgets/'+uid).onChildAdded.listen((event) {
      Map revenue = event.snapshot.value as Map;

      setState((){
        fixedCosts=double.parse(revenue['fixedCosts']);


      });
    });
    FirebaseDatabase.instance.ref().child('Revenue/'+uid).onChildAdded.listen((event) {
      Map revenue = event.snapshot.value as Map;
      countRevenue++;
      setState((){


        totalRevenue+=double.parse(revenue['amount']);
        averageRevenue=totalRevenue/countRevenue;
        percentageRevenue=(averageRevenue/totalRevenue)*100;

        data2.add(_SalesData(revenue['date'].substring(0,2),double.parse(revenue['amount'])));
        total=totalRevenue+totalExpenses;
       rp=(totalRevenue/total)*100;
        cp=(totalExpenses/total)*100;

        np=totalRevenue-totalExpenses;
        fr=(fixedCosts/totalRevenue)*100;
      });
    });

       FirebaseDatabase.instance.ref().child('Expenses/'+uid).onChildAdded.listen((event) {
      Map revenue = event.snapshot.value as Map;

      setState((){
        totalExpenses+=double.parse(revenue['amount']);
        total=totalRevenue+totalExpenses;
        print(totalExpenses);
        rp=(totalRevenue/total)*100;
        cp=(totalExpenses/total)*100;
        np=totalRevenue-totalExpenses;
        data.add(_SalesData(revenue['date'].substring(0,2),double.parse(revenue['amount'])));
        fr=(fixedCosts/totalRevenue)*100;
      });
    });

     dbRef = FirebaseDatabase.instance.ref().child('Revenue'+'/'+uid);
     reference = FirebaseDatabase.instance.ref().child('Revenue'+'/'+uid);

  }

  void getStudentData() async {
    String uid = user?.uid ?? 'uid';
    DataSnapshot snapshot = await dbRef.child('$uid').get();

    Future<void> _showMyDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hi, $UserName. New month, new opportunities. What’s your sales target for the month, enter key action plan for the month',
            textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: salesTargetController,
                    keyboardType: TextInputType.number,
                    decoration:const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Sales Tartget ',
                      hintText: 'Enter Sales Target',
                    ),),
                  const SizedBox(height: 15),
                  TextField(
                    controller: actionPlanController,
                    keyboardType: TextInputType.number,
                    decoration:const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Action Plan ',
                      hintText: 'Enter Key Action Plan',
                    ),),
                  const SizedBox(height: 15),
                  TextField(
                    controller: revenueBudgetController,
                    keyboardType: TextInputType.number,
                    decoration:const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Revenue Budget ',
                      hintText: 'Enter Revenue Budget',
                    ),),
                  const SizedBox(height: 15),
                  TextField(
                    controller: fixedCostsController,
                    keyboardType: TextInputType.number,
                    decoration:const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Fixed Costs ',
                      hintText: 'Enter Fixed Costs',
                    ),),
                  const SizedBox(height: 15),
                  TextField(
                    controller: revenueTargetController,
                    keyboardType: TextInputType.number,
                    decoration:const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Revenue Target ',
                      hintText: 'Enter Revenue Target',
                    ),),
                  const SizedBox(height: 15),
                  TextField(
                    controller: expensesTargetController,
                    keyboardType: TextInputType.number,
                    decoration:const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Expenses Target ',
                      hintText: 'Enter Expenses Target',
                    ),),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  Map<String, String> revenue = {
                    'salesTarget': salesTargetController.text,
                    'actionPlan': actionPlanController.text,
                    'revenueBudget': revenueBudgetController.text,
                    'fixedCosts': fixedCostsController.text,
                    'revenueTarget': revenueTargetController.text,
                    'expensesTarget':expensesTargetController.text
                  };

                  budget_reference.push().set(revenue);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    if (snapshot.value == null) {
      print("Item doesn't exist in the db");
      _showMyDialog();
    } else {
      print("Item exists in the db snap $snapshot");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color insightColor2 = Colors.blue;
    return Scaffold(
      appBar: AppBar(
        title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*2*/
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  sme,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              const Text(
                'Zimbabwe USD',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        actions: <Widget>[
          TextButton(onPressed: signOut, child: const Icon(Icons.settings
          ,color: Colors.white,
          )

          ),

        ],
          backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),

      body: FooterView(
          children:<Widget> [

            Container(
      padding: const EdgeInsets.only(top:10,left: 20,right: 20),
    child:Container(
    padding: const EdgeInsets.only(top:10,bottom: 20,left: 20,right: 20),
      decoration: BoxDecoration(
        border:Border.all(width: 2.0, color: insightColor2),
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),

      alignment: Alignment.center,
      child: SemicircularIndicator(
        radius: 140,
        color: Colors.green,
        backgroundColor: Colors.red,
        strokeWidth: 20,
        strokeCap: StrokeCap.square,
        progress:rp/100,
        bottomPadding: 5,
        contain: true,
        child: Column(
          children:[
          Text('\n\n$sme\nMonth To Date\n$date\n',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue),),
            Text('Revenue: '+rp.toStringAsFixed(2)+'%',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green),),
            Text('\nDaily Costs: \$'+totalExpenses.toStringAsFixed(2)+' ['+cp.toStringAsFixed(2)+'%]\nFixed Costs \$'+fixedCosts.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.red),),
            Text('Net Position \$'+np.toStringAsFixed(2)+' \n',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue),),
        ],),
      ),
    ),),
          Container(
            padding: const EdgeInsets.only(top:10,bottom: 20,left: 20,right: 20),
            child: const Text('Insights',
            style: TextStyle(
              fontSize: 20,
            ),
            ),
          ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    margin: const EdgeInsets.all(10),
                    color:insightColor1,
                    child: _buildInsightColumn(insightColor1,insightColor4, rp.toStringAsFixed(2), 'Daily Revenue')
                ),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  color:insightColor2,
                  child: _buildInsightColumn(insightColor2,insightColor5, cp.toStringAsFixed(2), 'Daily Expenses'),
                ),
                Container(

                  color:insightColor3,
                  child: _buildInsightColumn(insightColor3,insightColor6, fr.toStringAsFixed(2)+'%', 'Fixed/Revenue'),
                ),
              ],
            ),
    Row(

    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    Container(
    margin: const EdgeInsets.all(10),
    color:Colors.green,
    child: _buildInsight2Column(Colors.green,Colors.black,'Month to Date', '\$$totalRevenue', 'Revenue')
    ),
    Container(
    margin: const EdgeInsets.only(right: 5),
    color:Colors.red,
    child: _buildInsight2Column(Colors.red,Colors.black,'Month to Date', '\$$totalExpenses', 'Expenses'),
    ),
    Container(
    margin: const EdgeInsets.only(right: 5),
    color:Colors.orange,
    child: _buildInsight2Column(Colors.orange,Colors.black,'Month to Date', '\$$fixedCosts', 'Fixed Costs'),
    ),
    ],
    ),
            //Initialize the chart widget
            Container(
              padding: const EdgeInsets.all(10),

            child:Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
            border:Border.all(width: 2.0, color: insightColor2),
    ),
            child:SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                // Chart title
                title: ChartTitle(text: 'Month Revenue - January 2023'),
                // Enable legend
                legend: Legend(isVisible: true),
                // Enable tooltip
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <ChartSeries<_SalesData, String>>[
                  LineSeries<_SalesData, String>(
                      dataSource: data2,
                      xValueMapper: (_SalesData sales, _) => sales.year,
                      yValueMapper: (_SalesData sales, _) => sales.sales,
                      name: 'Revenue',
                      // Enable data label
                      dataLabelSettings: DataLabelSettings(isVisible: false)),
                  LineSeries<_SalesData, String>(
                      dataSource: data,
                      xValueMapper: (_SalesData sales, _) => sales.year,
                      yValueMapper: (_SalesData sales, _) => sales.sales,
                      name: 'Expenses',
                      // Enable data label
                      dataLabelSettings: DataLabelSettings(isVisible: false))

                ]),),),
            ////curved graph


            ////curved graph 
          


          ],
          footer : Footer(           //this takes the Footer Component which has 4 arguments with one being mandatory ie the child
              child:  Row(
                children: [
                  Expanded(child:Column(
                    children: [
                      TextButton(onPressed:() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignIn()),
                        );// Navigate back to first route when tapped.
                      }, child: const Icon(Icons.home)),
                      const Text('Home')
                    ],
                  ),),Expanded(child:
                  Column(
                    children: [
                      TextButton(onPressed:() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RevenuePage()),
                        );// Navigate back to first route when tapped.
                      }, child: const Icon(Icons.wallet)),
                      const Text('Revenue')
                    ],
                  ),),
                  Expanded(child:
                  Column(
                    children: [
                      TextButton(onPressed:()=>showDialog<String>(
    context: context,
    builder: (BuildContext context) => Dialog(
    child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
              style: TextButton.styleFrom(
                onSurface: Colors.white,
                backgroundColor:Colors.blue,

              ),
              onPressed:() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ISPage()),
                );// Navigate back to first route when tapped.
              }, child:const Text('Income Statement')),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
              style: TextButton.styleFrom(
                onSurface: Colors.white,
                backgroundColor:Colors.blue,

              ),
              onPressed:() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BSPage()),
                );// Navigate back to first route when tapped.
              }, child:const Text('Balance Sheet')),
        ],
      ),
      // Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     ElevatedButton(
      //         style: TextButton.styleFrom(
      //           onSurface: Colors.white,
      //           backgroundColor:Colors.blue,
      //
      //         ),
      //         onPressed:() {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => CFPage()),
      //           );// Navigate back to first route when tapped.
      //         }, child:const Text('Cash Flow')),
      //   ],
      // ),
    const SizedBox(height: 15),
    // TextButton(
    // onPressed: () {
    // Navigator.pop(context);
    // },
    // child: const Text('Close'),
    // ),
    ],
    ),
    ),
    ),
    ), child: const Icon(Icons.add_circle)),
                    ],
                  ),),
                  Expanded(child:
                  Column(
                    children: [
                      TextButton(onPressed:() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ExpensesPage()),
                        );// Navigate back to first route when tapped.
                      }, child: const Icon(Icons.pie_chart)),
                      const Text('Expenses')
                    ],
                  ),),
                  Column(
                    children: [
                      TextButton(onPressed:() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FundingPage()),
                        );// Navigate back to first route when tapped.
                      }, child: const Icon(Icons.attach_money_sharp)),
                      const Text('Funding')
                    ],
                  ),
                ],
              ),                 //See Description Below for the other arguments of the Footer Component
          ),
          flex: 6
      ),

    );
  }
}


class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
class SecondRoute extends StatelessWidget {
  final User? user = Auth().currentUser;
  final String amount;
  final String plan;
  final String comment;
  final String date;
  final String margin;
  final String ky;
  late DatabaseReference reference;
  String sme='';
  String uid='';

    // <-- Their email


  //const SecondRoute({super.key});
  SecondRoute({super.key,required this.ky,required this.amount,required this.plan,required this.comment,required this.date,required this.margin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue'),
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child:Column(
        children:[
          Row(
              children:[
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        'Daily Sales',
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        comment,
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ]
                ),Expanded(
                  child:Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children:[
                        Text(
                          '\$'+amount,
                          style: TextStyle(
                            fontSize: 38,
                          ),
                        ),

                      ]
                  ),),
              ]
          ),
          SizedBox(height:50),
          Text(
            'Margin',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(margin+"%"),
        SizedBox(height:50),
        Text(
        'Daily Comment',
        style: TextStyle(
        fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        ),
        Text(comment),
        SizedBox(height:50),
        Text(
        'Key Action Plan',
        style: TextStyle(
        fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        ),
        Text(plan),
          SizedBox(height:80),
          ElevatedButton(
            onPressed: () {
              uid= user?.uid ?? 'uid';
              reference=FirebaseDatabase.instance.ref("Revenue/"+uid+"/"+ky);

              reference.remove();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.red, // Background color
            ),
            child: const Text('Delete'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Go back!'),
          ),

        ],
      ),),
    );
  }
}
class ThirdRoute extends StatelessWidget {
  final User? user = Auth().currentUser;
  final String amount;
  final String plan;
  final String comment;
  final String date;
  final String margin;
  final String ky;
  String uid='';
  late DatabaseReference reference;
  //const SecondRoute({super.key});
  ThirdRoute({super.key,required this.ky,required this.amount,required this.plan,required this.comment,required this.date,required this.margin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense'),
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child:Column(
          children:[
            Row(
                children:[
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          plan,
                          style: TextStyle(

                          ),
                        ),
                        Text(
                          comment,
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ]
                  ),Expanded(
                    child:Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children:[
                          Text(
                            '\$'+amount,
                            style: TextStyle(
                              fontSize: 38,
                            ),
                          ),

                        ]
                    ),),
                ]
            ),
            SizedBox(height:50),
            Text(
              'Expense Title',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(margin),
            SizedBox(height:50),
            Text(
              'Expense Description',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(comment),
            SizedBox(height:50),
            Text(
              'Cartegory',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(plan),
            SizedBox(height:80),

            ElevatedButton(
              onPressed: () {
                uid= user?.uid ?? 'uid';
                reference=FirebaseDatabase.instance.ref("Expenses/"+uid+"/"+ky);

                reference.remove();
                Navigator.pop(context);
              },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // Background color
                ),
              child: const Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back!'),
            ),
          ],
        ),),
    );
  }
}

class RevenuePage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  RevenuePage({Key? key}) : super(key: key);
  final User? user = Auth().currentUser;
  @override
  RevenuePageState createState() => RevenuePageState();
}

class RevenuePageState extends State<RevenuePage> {
  final User? user = Auth().currentUser;
  // Check if the user is signed in

  List<_SalesData> data = [];
  List<_SalesData> data2 = [];

  double totalRevenue=0;
  double averageRevenue=0;
  double percentageRevenue=0;
  int countRevenue=0;
double budget=0;

  final  amountController = TextEditingController();
  final  marginController= TextEditingController();
  final  dateController =TextEditingController();
  final  commentController =TextEditingController();
  final  planController =TextEditingController();

  late Query dbRef;
  late DatabaseReference reference;
  String sme='';
  @override
  void initState() {
    super.initState();
      String uid = user?.uid ?? 'uid'; // <-- Their email
    String mail = user?.email ?? 'email';
    FirebaseDatabase.instance.ref().child('budgets/'+uid).onChildAdded.listen((event) {
      Map revenue = event.snapshot.value as Map;

      setState((){
        budget=double.parse(revenue['revenueBudget']);


      });
    });
    FirebaseDatabase.instance.ref().child('User/').onChildAdded.listen((event) {
      Map user = event.snapshot.value as Map;
      if(user['email']==mail){
        setState((){
          sme=user['sme'];
        });

        print(sme);
      }
    });
    FirebaseDatabase.instance.ref().child('Revenue/'+uid).onChildAdded.listen((event) {
      Map revenue = event.snapshot.value as Map;
      countRevenue++;
      setState((){


        totalRevenue+=double.parse(revenue['amount']);
        averageRevenue=totalRevenue/countRevenue;
        percentageRevenue=(averageRevenue/totalRevenue)*100;
        data2.add(_SalesData(revenue['date'].substring(0,2),double.parse(revenue['amount'])));
        data.add(_SalesData(revenue['date'].substring(0,2),budget));
      });
    });
     dbRef = FirebaseDatabase.instance.ref().child('Revenue'+'/'+uid);
     reference = FirebaseDatabase.instance.ref().child('Revenue'+'/'+uid);

  }

  Widget listRevenue({required Map revenue}){

    return GestureDetector(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SecondRoute(ky:revenue['key'],amount:revenue['amount'],plan:revenue['plan'],comment:revenue['comment'],margin:revenue['margin'],date:revenue['date'])),
          );
          // Add what you want to do on tap
        },
      child:SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child:Row(
      children:[
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Text(
              revenue['date'],
    style: TextStyle(
    color: Colors.grey[500],
    ),
            ),
            Text(
                'Daily Sales',
            style: TextStyle(
              fontSize: 22,
    ),
            ),
            Text(
                revenue['comment'],
    style: TextStyle(
    color: Colors.grey[500],
    ),
            ),
          ]
        ),Expanded(
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children:[
              Text(
                  '\$'+revenue['amount'],
    style: TextStyle(
    fontSize: 38,
    ),
              ),

            ]
        ),),
      ]
    )));
  }


  @override
  Widget build(BuildContext context) {
    Color insightColor2 = Colors.blue;
    return Scaffold(
      appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*2*/
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  sme,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              const Text(
                'Zimbabwe USD',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(onPressed: signOut, child: const Icon(Icons.settings
              ,color: Colors.white,
            )

            ),

          ],
          backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),

      body: FooterView(
          children:<Widget> [

            //Initialize the chart widget
            Container(
              padding: const EdgeInsets.all(10),

            child:Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
            border:Border.all(width: 2.0, color: insightColor2),
    ),
            child:SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                // Chart title
                title: ChartTitle(text: 'Month Revenue - January 2023'),
                // Enable legend
                legend: Legend(isVisible: true),
                // Enable tooltip
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <ChartSeries<_SalesData, String>>[
                  LineSeries<_SalesData, String>(
                      dataSource: data2,
                      xValueMapper: (_SalesData sales, _) => sales.year,
                      yValueMapper: (_SalesData sales, _) => sales.sales,
                      name: 'Revenue',
                      // Enable data label
                      dataLabelSettings: DataLabelSettings(isVisible: false)),
                  LineSeries<_SalesData, String>(
                      dataSource: data,
                      xValueMapper: (_SalesData sales, _) => sales.year,
                      yValueMapper: (_SalesData sales, _) => sales.sales,
                      name: 'Budget',
                      // Enable data label
                      dataLabelSettings: DataLabelSettings(isVisible: false))

                ]),),),
            Container(padding: const EdgeInsets.all(10),

            child:Row(
              children: [
                Expanded(
                child:Container(
                  color:Colors.grey,
                  child:Column(
                  children: [
                    Text(percentageRevenue.toString()+"%"),
                    const Text(''),
                    const Text('Daily Revenue'),

                  ],
                ),),),
                Expanded(
    child:Container(
    color:Colors.blueGrey,
                  child:Column(
                  children: [
                    const Text('Average'),
                     Text("\$"+averageRevenue.toString()),
                    const Text('Daily Revenue'),
                  ],
                ),),),

                Expanded(
                  child:Container(
                    color:Colors.grey,
                  child:
                Column(
                  children: [
                    const Text('Month to Date'),
                    Text("\$"+ totalRevenue.toString()),
                    const Text('Revenue'),
                  ],
                ),),),
              ],
            ),),
            SingleChildScrollView(child:
            Column(
              children:[ FirebaseAnimatedList(
                shrinkWrap: true,
                query: dbRef,
                itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {

                  Map revenue = snapshot.value as Map;
                  revenue['key'] = snapshot.key;

                  return listRevenue(revenue: revenue);

                },
              ),],
            ),),
            const SizedBox(
              height: 30, // <-- SEE HERE
            ),
            ElevatedButton(onPressed:()=> showDialog<String>(
              context: context,
              builder: (BuildContext context) => Dialog(
                child: ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: [Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Daily Revenue',
                      style:TextStyle(
                        fontSize:22,
    fontWeight: FontWeight.bold,
    ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Amount \$',
                      hintText: 'Enter Amount',
                      ),),
                      const SizedBox(height: 15),
                      TextField(
                        controller: marginController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Margin',
                          hintText: 'Enter Gross Margin %',
                        ),),
                      const SizedBox(height: 15),
                      TextfieldDatePicker(
                        cupertinoDatePickerBackgroundColor: Colors.white,
                        cupertinoDatePickerMaximumDate: DateTime(2099),
                        cupertinoDatePickerMaximumYear: 2099,
                        cupertinoDatePickerMinimumYear: 1990,
                        cupertinoDatePickerMinimumDate: DateTime(1990),
                        cupertinoDateInitialDateTime: DateTime.now(),
                        materialDatePickerFirstDate: DateTime.now(),
                        materialDatePickerInitialDate: DateTime.now(),
                        materialDatePickerLastDate: DateTime(2099),
                        preferredDateFormat: DateFormat('dd-MMMM-' 'yyyy'),
                        textfieldDatePickerController: dateController,
                        style: TextStyle(
                          fontSize: 1000 * 0.040,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          //errorText: errorTextValue,
                          helperStyle: TextStyle(
                              fontSize: 1000 * 0.031,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white, width: 0),
                              borderRadius: BorderRadius.circular(2)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2),
                              borderSide: const BorderSide(
                                width: 0,
                                color: Colors.white,
                              )),
                          hintText: 'Select Date Received',
                          hintStyle: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                          filled: true,
                          fillColor: Colors.blue,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: commentController,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Daily Comment',
                          hintText: 'Enter Daily Comment',
                        ),),
                      const SizedBox(height: 15),
                      TextField(
                        controller: planController,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Key Action Plan',
                          hintText: 'Enter Key Action Plan',
                        ),),
                      const SizedBox(height: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MaterialButton(

                              // style: TextButton.styleFrom(
                              //   onSurface: Colors.white,
                              //   backgroundColor:Colors.blue,
                              //     minimumSize: const Size.fromHeight(50),
                              //
                              // ),
                              onPressed:() {
                                Map<String, String> revenue = {
                                  'amount': amountController.text,
                                  'margin': marginController.text,
                                  'date': dateController.text,
                                  'comment': commentController.text,
                                  'plan': planController.text
                                };

                                reference.push().set(revenue);

                                Navigator.pop(context);
                              }, child:const Text('Save'),
                              color: Colors.blue,
                              textColor: Colors.white,
                              minWidth: 300,),

                        ],
                      ),

                      const SizedBox(height: 15),
                      const SizedBox(height: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                              style: TextButton.styleFrom(
                                onSurface: Colors.white,
                                backgroundColor:Colors.red,
                                minimumSize: const Size.fromHeight(50),

                              ),
                              onPressed: () {
            Navigator.pop(context);
            }, child:const Text('Close')),
                        ],
                      ),
                    ],
                  ),],
                ),
              ),
            ), child:
            const Text('Add Daily Revenue'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                backgroundColor: Colors.blue,
                minimumSize: const Size.fromHeight(50), // NEW
              ),
            ),


          ],
          footer : Footer(           //this takes the Footer Component which has 4 arguments with one being mandatory ie the child
              child:  Row(
                children: [
                  Expanded(child:Column(
                    children: [
                      TextButton(onPressed:() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignIn()),
                        );// Navigate back to first route when tapped.
                      }, child: const Icon(Icons.home)),
                      const Text('Home')
                    ],
                  ),),Expanded(child:
                  Column(
                    children: [
                      TextButton(onPressed:() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RevenuePage()),
                        );// Navigate back to first route when tapped.
                      }, child: const Icon(Icons.wallet)),
                      const Text('Revenue')
                    ],
                  ),),
                  Expanded(child:
                  Column(
                    children: [
                      TextButton(onPressed:()=>showDialog<String>(
    context: context,
    builder: (BuildContext context) => Dialog(
    child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
              style: TextButton.styleFrom(
                onSurface: Colors.white,
                backgroundColor:Colors.blue,

              ),
              onPressed:() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ISPage()),
                );// Navigate back to first route when tapped.
              }, child:const Text('Income Statement')),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
              style: TextButton.styleFrom(
                onSurface: Colors.white,
                backgroundColor:Colors.blue,

              ),
              onPressed:() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BSPage()),
                );// Navigate back to first route when tapped.
              }, child:const Text('Balance Sheet')),
        ],
      ),
      // Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     ElevatedButton(
      //         style: TextButton.styleFrom(
      //           onSurface: Colors.white,
      //           backgroundColor:Colors.blue,
      //
      //         ),
      //         onPressed:() {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => CFPage()),
      //           );// Navigate back to first route when tapped.
      //         }, child:const Text('Cash Flow')),
      //   ],
      // ),
    const SizedBox(height: 15),
    // TextButton(
    // onPressed: () {
    // Navigator.pop(context);
    // },
    // child: const Text('Close'),
    // ),
    ],
    ),
    ),
    ),
    ), child: const Icon(Icons.add_circle)),
                    ],
                  ),),
                  Expanded(child:
                  Column(
                    children: [
                      TextButton(onPressed:() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ExpensesPage()),
                        );// Navigate back to first route when tapped.
                      }, child: const Icon(Icons.pie_chart)),
                      const Text('Expenses')
                    ],
                  ),),
                  Column(
                    children: [
                      TextButton(onPressed:() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FundingPage()),
                        );// Navigate back to first route when tapped.
                      }, child: const Icon(Icons.attach_money_sharp)),
                      const Text('Funding')
                    ],
                  ),
                ],
              ),                  //See Description Below for the other arguments of the Footer Component
          ),
          flex: 6
      ),);
  }
}

class FundingPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  FundingPage({Key? key}) : super(key: key);
  final User? user = Auth().currentUser;
  @override
  FundingPageState createState() => FundingPageState();
}

class FundingPageState extends State<FundingPage> {


  final User? user = Auth().currentUser;

  // Check if the user is signed in
  String _valueChanged = '';
  String _valueToValidate = '';
  String _valueSaved = '';
  final List<Map<String, dynamic>> _items = [
    {
      'value': 'Equipment',
      'label': 'Equipment',
      'icon': Icon(Icons.smart_toy_outlined),
    },
    {
      'value': 'Stock',
      'label': 'Stock',
      'icon': Icon(Icons.storefront),
    },
    {
      'value': 'Marketing',
      'label': 'Marketing',
      'icon': Icon(Icons.people_rounded),
    }

  ];
  PlatformFile? pickedFile;
  PlatformFile? pickedFile2;
  PlatformFile? pickedFile3;
  UploadTask? uploadTask;
  Future selectFile1() async{
    final result= await FilePicker.platform.pickFiles();
    if(result==null) return;

    setState((){
      pickedFile=result.files.first;
    });
  }
  Future selectFile2() async{
    final result= await FilePicker.platform.pickFiles();
    if(result==null) return;

    setState((){
      pickedFile2=result.files.first;
    });
  }
  Future selectFile3() async{
    final result= await FilePicker.platform.pickFiles();
    if(result==null) return;

    setState((){
      pickedFile3=result.files.first;
    });
  }
String uploaded='';
  Future uploadFiles() async{
    setState((){
      uploaded="Uploading Please Wait....";
    });
    String uid = user?.uid ?? 'uid';
    final path='funding/'+uid+'/analysis.pdf';
    final path2='funding/'+uid+'/istatement.pdf';
    final path3='funding/'+uid+'/bsheet.pdf';

    final file= File(pickedFile!.path!);
    final file2= File(pickedFile2!.path!);
    final file3= File(pickedFile3!.path!);

    final ref=FirebaseStorage.instance.ref().child(path);
    uploadTask=ref.putFile(file);

    final snapshot=await uploadTask!.whenComplete(() => {});
    final urlDownload=await snapshot.ref.getDownloadURL();
    print('Dowload link: $urlDownload');

    final ref2=FirebaseStorage.instance.ref().child(path2);
    uploadTask=ref2.putFile(file2);

    final ref3=FirebaseStorage.instance.ref().child(path3);
    uploadTask=ref3.putFile(file3);
    setState((){
      uploaded="Funding Request Sent Thank You";
    });
  }
  double totalRevenue=0;
  double averageRevenue=0;
  double percentageRevenue=0;
  int countRevenue=0;
  double funding=0.0;
  double fundingp=0.0;
  double pol=0.0;

  double totalExpenses=0.0;

  final  amountController = TextEditingController();
  final  marginController= TextEditingController();
  final  dateController =TextEditingController();
  final  commentController =TextEditingController();
  final  planController =TextEditingController();

  late Query dbRef;
  late DatabaseReference reference;
 String sme="";
  @override
  void initState() {
    super.initState();
    String uid = user?.uid ?? 'uid'; // <-- Their email
    String mail = user?.email ?? 'email';
     FirebaseDatabase.instance.ref().child('User/').onChildAdded.listen((event) {
      Map user = event.snapshot.value as Map;
      if(user['email']==mail){
        setState((){
          sme=user['sme'];
        });

        print(sme);
      }



    });

    dbRef = FirebaseDatabase.instance.ref().child('Revenue'+'/'+uid);
    reference = FirebaseDatabase.instance.ref().child('Revenue'+'/'+uid);
     FirebaseDatabase.instance.ref().child('Revenue/'+uid).onChildAdded.listen((event) {
      Map revenue = event.snapshot.value as Map;
      setState((){
        totalRevenue+=double.parse(revenue['amount']);
        funding = totalRevenue * 2.5;
        fundingp = funding / 100000;
        pol=totalRevenue-totalExpenses;

      });



    });
    FirebaseDatabase.instance.ref().child('Expenses/'+uid).onChildAdded.listen((event) {
      Map revenue = event.snapshot.value as Map;
      setState((){
        totalExpenses+=double.parse(revenue['amount']);
        pol=totalRevenue-totalExpenses;

      });



    });


  }




  @override
  Widget build(BuildContext context) {
    Color insightColor2 = Colors.blue;
    return Scaffold(
      appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*2*/
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  sme,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              const Text(
                'Zimbabwe USD',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(onPressed: signOut, child: const Icon(Icons.settings
              ,color: Colors.white,
            )

            ),

          ],
          backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),

      body: FooterView(
          children:<Widget> [

            //Initialize the chart widget


                  Column(
                    children:
                    <Widget>[
                      Text('$uploaded',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text('Average Profit 3 Months',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),

                        child: LinearPercentIndicator(
                          width: 180.0,
                          lineHeight: 23.0,
                          percent: 0.5,
                          center: Text(
                            "\$$pol",
                            style: new TextStyle(fontSize: 12.0,
                            color:Colors.white,
                            ),
                          ),
                          leading: const Text("      -",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                              color:Colors.red
                            ),
                          ),
                          trailing: const Text("+",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 40,
                                color:Colors.green
                            ),),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          backgroundColor: Colors.green,
                          progressColor: Colors.red,
                        ),
                      ),
                      const Text('Your Potential Funding'),
                      const SizedBox(height: 15,),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                        border:Border.all(width: 6.0, color: insightColor2),
                          borderRadius: BorderRadius.all(Radius.circular(15),),
                          ),
                        child:
                        Text("\$"+funding.toString()),
                        ),
                      Container(
                        padding: const EdgeInsets.all(17),
                        child:

                      SelectFormField(
                        type: SelectFormFieldType.dialog,
                        controller: planController,
                        //initialValue: _initialValue,
                        icon: Icon(Icons.format_shapes),
                        labelText: 'What do you need funding for',
                        changeIcon: true,
                        dialogTitle: 'Funding for',
                        dialogCancelBtn: 'CANCEL',
                        enableSearch: true,
                        dialogSearchHint: 'Search',
                        items: _items,
                        onChanged: (val) => setState(() => _valueChanged = val),
                        validator: (val) {
                          setState(() => _valueToValidate = val ?? '');
                          return null;
                        },
                        onSaved: (val) => setState(() => _valueSaved = val ?? ''),
                      ),),

                      ElevatedButton(onPressed: selectFile1, child:
                      const Text('[Attach] Cost Benefit Analysis')
                      ),
                      ElevatedButton(onPressed: selectFile2, child:
                      const Text('[Attach] Income Statement')
                      ),
                      ElevatedButton(onPressed: selectFile3, child:
                      const Text('[Attach] Balance Sheet')
                      ),

                      const SizedBox(height:18),
                      ElevatedButton(onPressed: uploadFiles, child:
                      const Text('Submit')
                      ),
                      const SizedBox(height:5),
                      Container(
                      padding: const EdgeInsets.only(top:17,left:17,right:17),
                      child:
                      Column(
                      children:[
                      const Text('Our funding, rewards those who are efficient at business by being profitable'
                          'whilst our analytics help you become profitable with your current resources.',
                        textAlign: TextAlign.center,
                      ),],),
                  )
                    ],

                  ),



          ],
          footer : Footer(           //this takes the Footer Component which has 4 arguments with one being mandatory ie the child
            child:  Row(
              children: [
                Expanded(child:Column(
                  children: [
                    TextButton(onPressed:() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignIn()),
                      );// Navigate back to first route when tapped.
                    }, child: const Icon(Icons.home)),
                    const Text('Home')
                  ],
                ),),Expanded(child:
                Column(
                  children: [
                    TextButton(onPressed:() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RevenuePage()),
                      );// Navigate back to first route when tapped.
                    }, child: const Icon(Icons.wallet)),
                    const Text('Revenue')
                  ],
                ),),
                Expanded(child:
                Column(
                  children: [
                    TextButton(onPressed:()=>showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                      style: TextButton.styleFrom(
                                        onSurface: Colors.white,
                                        backgroundColor:Colors.blue,

                                      ),
                                      onPressed:() {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ISPage()),
                                        );// Navigate back to first route when tapped.
                                      }, child:const Text('Income Statement')),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                      style: TextButton.styleFrom(
                                        onSurface: Colors.white,
                                        backgroundColor:Colors.blue,

                                      ),
                                      onPressed:() {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => BSPage()),
                                        );// Navigate back to first route when tapped.
                                      }, child:const Text('Balance Sheet')),
                                ],
                              ),
                              // Column(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   children: [
                              //     ElevatedButton(
                              //         style: TextButton.styleFrom(
                              //           onSurface: Colors.white,
                              //           backgroundColor:Colors.blue,
                              //
                              //         ),
                              //         onPressed:() {
                              //           Navigator.push(
                              //             context,
                              //             MaterialPageRoute(builder: (context) => CFPage()),
                              //           );// Navigate back to first route when tapped.
                              //         }, child:const Text('Cash Flow')),
                              //   ],
                              // ),
                              const SizedBox(height: 15),
                              // TextButton(
                              // onPressed: () {
                              // Navigator.pop(context);
                              // },
                              // child: const Text('Close'),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ), child: const Icon(Icons.add_circle)),
                  ],
                ),),
                Expanded(child:
                Column(
                  children: [
                    TextButton(onPressed:() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ExpensesPage()),
                      );// Navigate back to first route when tapped.
                    }, child: const Icon(Icons.pie_chart)),
                    const Text('Expenses')
                  ],
                ),),
                Column(
                  children: [
                    TextButton(onPressed:() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FundingPage()),
                      );// Navigate back to first route when tapped.
                    }, child: const Icon(Icons.attach_money_sharp)),
                    const Text('Funding')
                  ],
                ),
              ],
            ),                  //See Description Below for the other arguments of the Footer Component
          ),
          flex: 6
      ),);
  }
}


class ExpensesPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  ExpensesPage({Key? key}) : super(key: key);
  final User? user = Auth().currentUser;
  @override
  ExpensesPageState createState() => ExpensesPageState();
}

class ExpensesPageState extends State<ExpensesPage> {
  final User? user = Auth().currentUser;
  GlobalKey<FormState> _oFormKey = GlobalKey<FormState>();
  TextEditingController? _controller;
  //String _initialValue;
  String _valueChanged = '';
  String _valueToValidate = '';
  String _valueSaved = '';


  final List<Map<String, dynamic>> _items = [
    {
      'value': 'Advertising',
      'label': 'Advertising',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Business Vehicle(s) Repairs',
      'label': 'Business Vehicle(s) Repairs',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Employee Commissions',
      'label': 'Employee Commissions',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Variable Employee Benefits',
      'label': 'Variable Employee Benefits',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Meals & Entertainment',
      'label': 'Meals & Entertainment',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Office',
      'label': 'Office',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Professional Services',
      'label': 'Proffesional Services',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Phone',
      'label': 'Phone',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Travel',
      'label': 'Travel',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Training and Education',
      'label': 'Training and Education',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Deliveries',
      'label': 'Deliveries',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Loan & Interest Payments',
      'label': 'Loan & Interest Payments',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Other',
      'label': 'Other',
      'icon': Icon(Icons.monetization_on_outlined),
    },
  ];
  List<_SalesData> data = [];
  List<String> strings = [];

  List<_SalesData> data2 = [];
  late Query dbRef;
  late DatabaseReference reference;
  final  amountController = TextEditingController();
  final  marginController= TextEditingController();
  final  dateController =TextEditingController();
  final  commentController =TextEditingController();
  final  planController =TextEditingController();
  double totalExpenses=0;
  double averageExpenses=0;
  double percentageExpenses=0;
  double fixedCosts=0;
  int countExpenses=0;
  String sme='';
  @override
  void initState() {
    super.initState();
    String uid = user?.uid ?? 'uid';
    String mail = user?.email ?? 'email';
    FirebaseDatabase.instance.ref().child('budgets/'+uid).onChildAdded.listen((event) {
      Map revenue = event.snapshot.value as Map;

      setState((){
        fixedCosts=double.parse(revenue['fixedCosts']);


      });
    });
    FirebaseDatabase.instance.ref().child('User/').onChildAdded.listen((event) {
      Map user = event.snapshot.value as Map;
      if(user['email']==mail){
        setState((){
          sme=user['sme'];
        });

        print(sme);
      }
    });
    FirebaseDatabase.instance.ref().child('Expenses/'+uid).onChildAdded.listen((event) {
      Map revenue = event.snapshot.value as Map;
      countExpenses++;
      setState(() {
        totalExpenses += double.parse(revenue['amount']);
        averageExpenses = totalExpenses / countExpenses;
        percentageExpenses = (averageExpenses / totalExpenses) * 100;

        data2.add(_SalesData(
            revenue['date'].substring(0, 2), double.parse(revenue['amount'])));
        data.add(_SalesData(revenue['date'].substring(0, 2), fixedCosts));
      });
    });
    strings.add("Nepal");
    // <-- Their email

    dbRef = FirebaseDatabase.instance.ref().child('Expenses'+'/'+uid);
    reference = FirebaseDatabase.instance.ref().child('Expenses'+'/'+uid);
    _controller = TextEditingController(text: '2');

    _getValue();
  }
  Future<void> _getValue() async {
    await Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        //_initialValue = 'circleValue';
        _controller?.text = 'circleValue';
      });
    });
  }
  Widget listExpenses({required Map revenue}){

    return GestureDetector(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ThirdRoute(ky:revenue['key'],amount:revenue['amount'],plan:revenue['plan'],comment:revenue['comment'],margin:revenue['margin'],date:revenue['date'])),
          );
          // Add what you want to do on tap
        },
        child:SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child:Row(
            children:[
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Text(
                      revenue['date'],
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      revenue['plan'],
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      revenue['comment'],
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ]
              ),Expanded(
                child:Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:[
                      Text(
                        '\$'+revenue['amount'],
                        style: TextStyle(
                          fontSize: 38,
                        ),
                      ),

                    ]
                ),),
            ]
        )));
  }
  @override
  Widget build(BuildContext context) {
    Color insightColor2 = Colors.blue;
    return Scaffold(
      appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*2*/
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  sme,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              const Text(
                'Zimbabwe USD',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(onPressed: signOut, child: const Icon(Icons.settings
              ,color: Colors.white,
            )

            ),

          ],
          backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),

      body: FooterView(
          children: [

            //Initialize the chart widget
            Container(
              padding: const EdgeInsets.all(10),

              child:Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border:Border.all(width: 2.0, color: insightColor2),
                ),
                child:SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    // Chart title
                    title: ChartTitle(text: 'Month Expenses - January 2023'),
                    // Enable legend
                    legend: Legend(isVisible: true),
                    // Enable tooltip
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <ChartSeries<_SalesData, String>>[
                      LineSeries<_SalesData, String>(
                          dataSource: data2,
                          xValueMapper: (_SalesData sales, _) => sales.year,
                          yValueMapper: (_SalesData sales, _) => sales.sales,
                          name: 'Expenses',
                          // Enable data label
                          dataLabelSettings: DataLabelSettings(isVisible: false)),
                      LineSeries<_SalesData, String>(
                          dataSource: data,
                          xValueMapper: (_SalesData sales, _) => sales.year,
                          yValueMapper: (_SalesData sales, _) => sales.sales,
                          name: 'Fixed Costs',
                          // Enable data label
                          dataLabelSettings: DataLabelSettings(isVisible: false))

                    ]),),),
            Container(padding: const EdgeInsets.all(10),

              child:Row(
                children: [
                  Expanded(
                    child:Container(
                      color:Colors.grey,
                      child:Column(
                        children: [
                           Text(percentageExpenses.toString()+"%"),
                          const Text(''),
                          const Text('Daily Expenses'),

                        ],
                      ),),),
                  Expanded(
                    child:Container(
                      color:Colors.blueGrey,
                      child:Column(
                        children: [
                          const Text('Average'),
                          Text("\$"+percentageExpenses.toString()),
                          const Text('Daily Expenses'),
                        ],
                      ),),),

                  Expanded(
                    child:Container(
                      color:Colors.grey,
                      child:
                      Column(
                        children: [
                          const Text('Month to Date'),
                          Text("\$"+totalExpenses.toString()),
                          const Text('Expenses'),
                        ],
                      ),),),
                ],
              ),),SingleChildScrollView(child:
            Column(
              children:[
                FirebaseAnimatedList(
                shrinkWrap: true,
                query: dbRef,
                itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {

                  Map revenue = snapshot.value as Map;
                  revenue['key'] = snapshot.key;

                  return listExpenses(revenue: revenue);

                },
              ),],
            ),),
            SizedBox(
              height: 110, // <-- SEE HERE
            ),
            ElevatedButton(onPressed:()=> showDialog<String>(
              context: context,
              builder: (BuildContext context) => Dialog(
                child: ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: [Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Daily Expenses',
                        style:TextStyle(
                          fontSize:22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      SelectFormField(
                        type: SelectFormFieldType.dialog,
                        controller: planController,
                        //initialValue: _initialValue,
                        icon: Icon(Icons.format_shapes),
                        labelText: 'Cartegory',
                        changeIcon: true,
                        dialogTitle: 'Expense Cartegory',
                        dialogCancelBtn: 'CANCEL',
                        enableSearch: true,
                        dialogSearchHint: 'Search',
                        items: _items,
                        onChanged: (val) => setState(() => _valueChanged = val),
                        validator: (val) {
                          setState(() => _valueToValidate = val ?? '');
                          return null;
                        },
                        onSaved: (val) => setState(() => _valueSaved = val ?? ''),
                      ),

                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Amount \$',
                          hintText: 'Enter Amount',
                        ),),
                      const SizedBox(height: 15),
                      TextField(
                        controller: marginController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Expense Title',
                          hintText: 'Enter Expense Title',
                        ),),
                      const SizedBox(height: 15),
                      // TextField(
                      //   controller: dateController,
                      //   keyboardType: TextInputType.datetime,
                      //   decoration: const InputDecoration(
                      //     border: OutlineInputBorder(),
                      //     labelText: 'Date Paid dd-mm-yyyy',
                      //     hintText: 'Select Date Paid dd-mm-yyyy',
                      //   ),),
                      TextfieldDatePicker(
                        cupertinoDatePickerBackgroundColor: Colors.white,
                        cupertinoDatePickerMaximumDate: DateTime(2099),
                        cupertinoDatePickerMaximumYear: 2099,
                        cupertinoDatePickerMinimumYear: 1990,
                        cupertinoDatePickerMinimumDate: DateTime(1990),
                        cupertinoDateInitialDateTime: DateTime.now(),
                        materialDatePickerFirstDate: DateTime.now(),
                        materialDatePickerInitialDate: DateTime.now(),
                        materialDatePickerLastDate: DateTime(2099),
                        preferredDateFormat: DateFormat('dd-MMMM-' 'yyyy'),
                        textfieldDatePickerController: dateController,
                        style: TextStyle(
                          fontSize: 1000 * 0.040,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          //errorText: errorTextValue,
                          helperStyle: TextStyle(
                              fontSize: 1000 * 0.031,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white, width: 0),
                              borderRadius: BorderRadius.circular(2)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2),
                              borderSide: const BorderSide(
                                width: 0,
                                color: Colors.white,
                              )),
                          hintText: 'Select Paid Date',
                          hintStyle: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                          filled: true,
                          fillColor: Colors.grey[300],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: commentController,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Expense Description',
                          hintText: 'Enter Expense Description',
                        ),),
                      const SizedBox(height: 15),

                      const SizedBox(height: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MaterialButton(

                            // style: TextButton.styleFrom(
                            //   onSurface: Colors.white,
                            //   backgroundColor:Colors.blue,
                            //     minimumSize: const Size.fromHeight(50),
                            //
                            // ),
                            onPressed:() {
                              Map<String, String> revenue = {
                                'amount': amountController.text,
                                'margin': marginController.text,
                                'date': dateController.text,
                                'comment': commentController.text,
                                'plan': planController.text
                              };

                              reference.push().set(revenue);

                              Navigator.pop(context);
                            }, child:const Text('Save'),
                            color: Colors.blue,
                            textColor: Colors.white,
                            minWidth: 300,),

                        ],
                      ),

                      const SizedBox(height: 15),
                      const SizedBox(height: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                              style: TextButton.styleFrom(
                                onSurface: Colors.white,
                                backgroundColor:Colors.red,
                                minimumSize: const Size.fromHeight(50),

                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              }, child:const Text('Close')),
                        ],
                      ),
                    ],
                  ),],
                ),
              ),
            ), child:
            const Text('Add Daily Expenses'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                backgroundColor: Colors.blue,
                minimumSize: const Size.fromHeight(50), // NEW
              ),
            ),
          ]
          ,
          footer : Footer(           //this takes the Footer Component which has 4 arguments with one being mandatory ie the child
            child:  Row(
              children: [
                Expanded(child:Column(
                  children: [
                    TextButton(onPressed:() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignIn()),
                      );// Navigate back to first route when tapped.
                    }, child: const Icon(Icons.home)),
                    const Text('Home')
                  ],
                ),),Expanded(child:
                Column(
                  children: [
                    TextButton(onPressed:() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RevenuePage()),
                      );// Navigate back to first route when tapped.
                    }, child: const Icon(Icons.wallet)),
                    const Text('Revenue')
                  ],
                ),),
                Expanded(child:
                Column(
                  children: [
                    TextButton(onPressed:()=>showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                      style: TextButton.styleFrom(
                                        onSurface: Colors.white,
                                        backgroundColor:Colors.blue,

                                      ),
                                      onPressed:() {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ISPage()),
                                        );// Navigate back to first route when tapped.
                                      }, child:const Text('Income Statement')),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                      style: TextButton.styleFrom(
                                        onSurface: Colors.white,
                                        backgroundColor:Colors.blue,

                                      ),
                                      onPressed:() {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => BSPage()),
                                        );// Navigate back to first route when tapped.
                                      }, child:const Text('Balance Sheet')),
                                ],
                              ),
                              // Column(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   children: [
                              //     ElevatedButton(
                              //         style: TextButton.styleFrom(
                              //           onSurface: Colors.white,
                              //           backgroundColor:Colors.blue,
                              //
                              //         ),
                              //         onPressed:() {
                              //           Navigator.push(
                              //             context,
                              //             MaterialPageRoute(builder: (context) => CFPage()),
                              //           );// Navigate back to first route when tapped.
                              //         }, child:const Text('Cash Flow')),
                              //   ],
                              // ),
                              const SizedBox(height: 15),
                              // TextButton(
                              // onPressed: () {
                              // Navigator.pop(context);
                              // },
                              // child: const Text('Close'),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ), child: const Icon(Icons.add_circle)),
                  ],
                ),),
                Expanded(child:
                Column(
                  children: [
                    TextButton(onPressed:() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ExpensesPage()),
                      );// Navigate back to first route when tapped.
                    }, child: const Icon(Icons.pie_chart)),
                    const Text('Expenses')
                  ],
                ),),
                Column(
                  children: [
                    TextButton(onPressed:() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FundingPage()),
                      );// Navigate back to first route when tapped.
                    }, child: const Icon(Icons.attach_money_sharp)),
                    const Text('Funding')
                  ],
                ),
              ],
            ),                  //See Description Below for the other arguments of the Footer Component
          ),
          flex: 8
      ),);
  }
}
class SignIn extends StatelessWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WidgetTree(),
      //
    );
  }
}

class ISPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  ISPage({Key? key}) : super(key: key);
  final User? user = Auth().currentUser;
  @override
  ISPageState createState() => ISPageState();
}

class ISPageState extends State<ISPage> {
  
  final User? user = Auth().currentUser;
  List<Employee> employees = <Employee>[];
  late EmployeeDataSource employeeDataSource;
  double totalRevenue=0;
  double averageRevenue=0;
  double percentageRevenue=0;
  int countRevenue=0;

  double totalExpense=0;
  double averageExpense=0;
  double percentageExpense=0;
  int countExpense=0;
  double profit=0;
  late Query dbRefRevenue;
  late Query dbRefExpense;
  late DatabaseReference reference;
  String sme='';

  String UserName="";
  @override
  void initState() {
    super.initState();
    String uid = user?.uid ?? 'uid';
     // <-- Their email
    String mail = user?.email ?? 'email';
    FirebaseDatabase.instance.ref().child('User/').onChildAdded.listen((event) {
      Map user = event.snapshot.value as Map;
      if(user['email']==mail){
        setState((){
          sme=user['sme'];
          UserName=user['fname'];
        });

        print(sme);
      }
    });
    FirebaseDatabase.instance.ref().child('User/').onChildAdded.listen((event) {
      Map revenue = event.snapshot.value as Map;
      setState(() {
        countExpense++;
        totalExpense += double.parse(revenue['amount']);
        averageExpense = totalRevenue / countRevenue;
        percentageExpense = (averageRevenue / totalRevenue) * 100;
      });
    });
    dbRefRevenue = FirebaseDatabase.instance.ref().child('Revenue'+'/'+uid);
    dbRefRevenue.onChildAdded.listen((event) {
      Map revenue = event.snapshot.value as Map;
      setState((){
        totalRevenue+=double.parse(revenue['amount']);
        print(totalRevenue);
        profit=totalRevenue-totalExpense;
      });

    });
    dbRefExpense = FirebaseDatabase.instance.ref().child('Expenses'+'/'+uid);
    employees = getEmployeeData();
    employeeDataSource = EmployeeDataSource(employeeData: employees);
  }

  Widget listExpenses({required Map revenue}){

    return Container(
        padding: EdgeInsets.all(20),
        child:Row(
            children: [
              Expanded(child:
              Column(
                children: [
                  Text(revenue['plan']),
                ],
              )
              ),
              Expanded(child:
              Column(
                children: [
                  Text(revenue['amount']),
                ],
              )
              ),
              Expanded(child:
              Column(
                children: [
                  const Text(''),
                ],
              )
              )
            ],
        ));
  }
  @override
  Widget build(BuildContext context) {

    Color insightColor2 = Colors.blue;
    return Scaffold(
      appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*2*/
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  sme,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              const Text(
                'Zimbabwe USD',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(onPressed: signOut, child: const Icon(Icons.settings
              ,color: Colors.white,
            )

            ),

          ],
          backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),

      body: FooterView(
          children: [

            Container(padding: const EdgeInsets.all(10),

              child:Row(
                children: [
                  Expanded(
                    child:Container(
                      color:Colors.grey,
                      child:Column(
                        children: [
                          const Text("Total Revenue"),
                          Text('\$'+totalRevenue.toString()),
                          const Text('0%'),

                        ],
                      ),),),
                  Expanded(
                    child:Container(
                      color:Colors.blueGrey,
                      child:Column(
                        children: [
                          const Text('Total Expenses'),
                          Text("\$"+totalExpense.toString()),
                          const Text('0%'),
                        ],
                      ),),),

                  Expanded(
                    child:Container(
                      color:Colors.grey,
                      child:
                      Column(
                        children: [
                          const Text('Net Position'),
                          Text("\$"+profit.toString()),
                          const Text(''),
                        ],
                      ),),),
                ],
              ),),
            Container(padding: const EdgeInsets.only(left:10,right: 10),
              color:Colors.blue,
              child:Column(
                children: [
                  Text(""),
                  Text('Company: Income Statement'),
                  Text(""),

                ],
              ),
            ),
            Row(
              children: [
                Expanded(child:
                Column(
                  children: [
                    const Text('Revenue'),
                    const Text('Less: COGS'),
                    const Text('Gross Profit'),
                  ],
                ),),
                Expanded(child:
                Column(
                  children: [
                    const Text(''),
                    const Text(''),
                    const Text(''),
                  ],
                ),),
                Expanded(child:
                Column(
                  children: [
                   Text(totalRevenue.toString()),
                    const Text("0.00"),
                    const Text("0.00"),
                  ],
                )
                ),
              ],
            ),
            const Text('Expenses'),
            Expanded(
              child: FirebaseAnimatedList(
                shrinkWrap: true,
                query: dbRefExpense,
                itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {

                  Map revenue = snapshot.value as Map;
                  revenue['key'] = snapshot.key;

                  return listExpenses(revenue: revenue);

                },
              ),
            ),
            Row(
                children:[
                  Expanded(child: Column(children: [
                    const Text('Total Expenses'),
                  ],)),
                  Expanded(child: Column(children: [
                    const Text(''),
                  ],)),
                  Expanded(child: Column(children: [
                    Text('( \$'+totalExpense.toString()+' )'),
                  ],)),
                ]
            ),
            Row(
              children:[
                Expanded(child: Column(children: [
                  const Text('Net Profit / Loss'),
                ],)),
                Expanded(child: Column(children: [
                  const Text(''),
                ],)),
                Expanded(child: Column(children: [
                  Text('\$'+profit.toString()),
                ],)),
              ]
            ),
            SizedBox(
              height: 85,
            ),


            //Initialize the chart widget


          ],
          footer : Footer(           //this takes the Footer Component which has 4 arguments with one being mandatory ie the child
          child:  Row(
          children: [
      Expanded(child:Column(
      children: [
          TextButton(onPressed:() {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SignIn()),
    );// Navigate back to first route when tapped.
    }, child: const Icon(Icons.home)),
    const Text('Home')
    ],
    ),),Expanded(child:
    Column(
    children: [
    TextButton(onPressed:() {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => RevenuePage()),
    );// Navigate back to first route when tapped.
    }, child: const Icon(Icons.wallet)),
    const Text('Revenue')
    ],
    ),),
    Expanded(child:
    Column(
    children: [
    TextButton(onPressed:()=>showDialog<String>(
    context: context,
    builder: (BuildContext context) => Dialog(
    child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    ElevatedButton(
    style: TextButton.styleFrom(
    onSurface: Colors.white,
    backgroundColor:Colors.blue,

    ),
    onPressed:() {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ISPage()),
    );// Navigate back to first route when tapped.
    }, child:const Text('Income Statement')),
    ],
    ),
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    ElevatedButton(
    style: TextButton.styleFrom(
    onSurface: Colors.white,
    backgroundColor:Colors.blue,

    ),
    onPressed:() {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => BSPage()),
    );// Navigate back to first route when tapped.
    }, child:const Text('Balance Sheet')),
    ],
    ),
    // Column(
    // crossAxisAlignment: CrossAxisAlignment.start,
    // children: [
    // ElevatedButton(
    // style: TextButton.styleFrom(
    // onSurface: Colors.white,
    // backgroundColor:Colors.blue,
    //
    // ),
    // onPressed:() {
    // Navigator.push(
    // context,
    // MaterialPageRoute(builder: (context) => CFPage()),
    // );// Navigate back to first route when tapped.
    // }, child:const Text('Cash Flow')),
    // ],
    // ),
    const SizedBox(height: 15),
    // TextButton(
    // onPressed: () {
    // Navigator.pop(context);
    // },
    // child: const Text('Close'),
    // ),
    ],
    ),
    ),
    ),
    ), child: const Icon(Icons.add_circle)),
    ],
    ),),
    Expanded(child:
    Column(
    children: [
    TextButton(onPressed:() {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ExpensesPage()),
    );// Navigate back to first route when tapped.
    }, child: const Icon(Icons.pie_chart)),
    const Text('Expenses')
    ],
    ),),
    Column(
    children: [
    TextButton(onPressed:() {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => FundingPage()),
    );// Navigate back to first route when tapped.
    }, child: const Icon(Icons.attach_money_sharp)),
    const Text('Funding')
    ],
    ),
    ],
    ),                  //See Description Below for the other arguments of the Footer Component
    ),
          flex: 8
      ),);
  }

  List<Employee> getEmployeeData() {
    return [
      Employee('Revenue', '', '0.00'),
      Employee('Less: COGS', '', '0.00'),
      Employee('Gross Profit', '', '0.00'),
      Employee('', '', ''),
      Employee('Expenses', '', ''),
      Employee('Advertising', '0.00', ''),
      Employee('Rent', '0.00', '0.00'),
      Employee('Less:Tax', '', '0.00'),
      Employee('Net Profit or Loss', '', '0.00'),
    ];
  }

}
// Custom business object class which contains properties to hold the detailed
/// information about the employee which will be rendered in datagrid.
class Employee {
  /// Creates the employee class with required details.
  Employee(this.id, this.name, this.designation);

  /// Id of an employee.
  final String id;

  /// Name of an employee.
  final String name;

  /// Designation of an employee.
  final String designation;


}

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class EmployeeDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  EmployeeDataSource({required List<Employee> employeeData}) {
    _employeeData = employeeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'id', value: e.id),
      DataGridCell<String>(columnName: 'name', value: e.name),
      DataGridCell<String>(
          columnName: 'designation', value: e.designation),
    ]))
        .toList();
  }

  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            child: Text(e.value.toString()),
          );
        }).toList());
  }
}
class BSPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  BSPage({Key? key}) : super(key: key);
  final User? user = Auth().currentUser;
  @override
  BSPageState createState() => BSPageState();
}

class BSPageState extends State<BSPage> {
  final User? user = Auth().currentUser;
  List<Employee> employees = <Employee>[];
  late EmployeeDataSource employeeDataSource;
  String sme='';
  String UserName="";
  @override
  void initState() {
    super.initState();

    String uid = user?.uid ?? 'uid'; // <-- Their email
    String mail = user?.email ?? 'email';
    FirebaseDatabase.instance.ref().child('User/').onChildAdded.listen((event) {
      Map user = event.snapshot.value as Map;
      if(user['email']==mail){
        setState((){
          sme=user['sme'];
          UserName=user['fname'];
        });

        print(sme);
      }
    });
    employees = getEmployeeData2();
    employeeDataSource = EmployeeDataSource(employeeData: employees);
  }
  @override
  Widget build(BuildContext context) {
    Color insightColor2 = Colors.blue;
    return Scaffold(
      appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*2*/
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  sme,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              const Text(
                'Zimbabwe USD',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(onPressed: signOut, child: const Icon(Icons.settings
              ,color: Colors.white,
            )

            ),

          ],
          backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),

      body: FooterView(
          children: [

            Container(padding: const EdgeInsets.all(10),

              child:Row(
                children: [
                  Expanded(
                    child:Container(
                      color:Colors.blueGrey,
                      child:Column(
                        children: [
                          const Text('Total Assets'),
                          const Text("\$0.00"),
                          const Text('0%'),
                        ],
                      ),),),
                  Expanded(
                    child:Container(
                      color:Colors.blueGrey,
                      child:Column(
                        children: [
                          const Text('Total Liabilities'),
                          const Text("\$0.00"),
                          const Text('0%'),
                        ],
                      ),),),

                  Expanded(
                    child:Container(
                      color:Colors.grey,
                      child:
                      Column(
                        children: [
                          const Text(' Equity'),
                          const Text("\$0.00"),
                          const Text('0%'),
                        ],
                      ),),),
                ],
              ),),
            Container(padding: const EdgeInsets.only(left:10,right: 10),
              color:Colors.blue,
              child:Column(
                children: [
                  Text(""),
                  Text('Company: Balance Sheet'),
                  Text(""),

                ],
              ),
            ),
            Container(

              child:SfDataGrid(
                source: employeeDataSource,
                columnWidthMode: ColumnWidthMode.fill,
                columns: <GridColumn>[
                  GridColumn(
                      columnName: 'id',
                      label: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            Text(
                              '',
                            )
                          ],)),
                  GridColumn(
                      columnName: 'name',
                      label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: Text(''))),
                  GridColumn(
                      columnName: 'designation',
                      label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: Text(
                            '',
                            overflow: TextOverflow.ellipsis,
                          ))),
                ],
              ),
            ),
            SizedBox(
              height: 85,
            ),

            //Initialize the chart widget


          ],
          footer : Footer(           //this takes the Footer Component which has 4 arguments with one being mandatory ie the child
          child:  Row(
          children: [
      Expanded(child:Column(
      children: [
          TextButton(onPressed:() {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SignIn()),
    );// Navigate back to first route when tapped.
    }, child: const Icon(Icons.home)),
    const Text('Home')
    ],
    ),),Expanded(child:
    Column(
    children: [
    TextButton(onPressed:() {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => RevenuePage()),
    );// Navigate back to first route when tapped.
    }, child: const Icon(Icons.wallet)),
    const Text('Revenue')
    ],
    ),),
    Expanded(child:
    Column(
    children: [
    TextButton(onPressed:()=>showDialog<String>(
    context: context,
    builder: (BuildContext context) => Dialog(
    child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    ElevatedButton(
    style: TextButton.styleFrom(
    onSurface: Colors.white,
    backgroundColor:Colors.blue,

    ),
    onPressed:() {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ISPage()),
    );// Navigate back to first route when tapped.
    }, child:const Text('Income Statement')),
    ],
    ),
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    ElevatedButton(
    style: TextButton.styleFrom(
    onSurface: Colors.white,
    backgroundColor:Colors.blue,

    ),
    onPressed:() {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => BSPage()),
    );// Navigate back to first route when tapped.
    }, child:const Text('Balance Sheet')),
    ],
    ),
    // Column(
    // crossAxisAlignment: CrossAxisAlignment.start,
    // children: [
    // ElevatedButton(
    // style: TextButton.styleFrom(
    // onSurface: Colors.white,
    // backgroundColor:Colors.blue,
    //
    // ),
    // onPressed:() {
    // Navigator.push(
    // context,
    // MaterialPageRoute(builder: (context) => CFPage()),
    // );// Navigate back to first route when tapped.
    // }, child:const Text('Cash Flow')),
    // ],
    // ),
    const SizedBox(height: 15),
    // TextButton(
    // onPressed: () {
    // Navigator.pop(context);
    // },
    // child: const Text('Close'),
    // ),
    ],
    ),
    ),
    ),
    ), child: const Icon(Icons.add_circle)),
    ],
    ),),
    Expanded(child:
    Column(
    children: [
    TextButton(onPressed:() {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ExpensesPage()),
    );// Navigate back to first route when tapped.
    }, child: const Icon(Icons.pie_chart)),
    const Text('Expenses')
    ],
    ),),
    Column(
    children: [
    TextButton(onPressed:() {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => FundingPage()),
    );// Navigate back to first route when tapped.
    }, child: const Icon(Icons.attach_money_sharp)),
    const Text('Funding')
    ],
    ),
    ],
    ),                  //See Description Below for the other arguments of the Footer Component
    ),
    flex: 8
      ),);
  }
  List<Employee> getEmployeeData2() {
    return [
      Employee('Assets', '', ''),
      Employee('Fixed Assets', '', '0.00'),
      Employee('Current Assets', '', '0.00'),
      Employee('', '', ''),
      Employee('Liabilities', '', ''),
      Employee('Current Liabilities', '', '0.00'),
      Employee('Long Term Liabilities', '', '0.00'),
      Employee('', '', ''),
      Employee('Owners Equity', '', '0.00'),
      Employee('Total Liabilities and Equity', '', '0.00'),
    ];
  }
}

class CFPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  CFPage({Key? key}) : super(key: key);
  final User? user = Auth().currentUser;
  @override
  CFPageState createState() => CFPageState();
}

class CFPageState extends State<CFPage> {
  final User? user = Auth().currentUser;

  @override
  Widget build(BuildContext context) {
    Color insightColor2 = Colors.blue;
    return Scaffold(
      appBar: null,

      body: FooterView(
          children: [
            //Initialize the chart widget


          ],
          footer : Footer(           //this takes the Footer Component which has 4 arguments with one being mandatory ie the child
            child:  Row(
              children: [
                Expanded(child:Column(
                  children: [
                    TextButton(onPressed:() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignIn()),
                      );// Navigate back to first route when tapped.
                    }, child: const Icon(Icons.home)),
                    const Text('Home')
                  ],
                ),),Expanded(child:
                Column(
                  children: [
                    TextButton(onPressed:() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RevenuePage()),
                      );// Navigate back to first route when tapped.
                    }, child: const Icon(Icons.wallet)),
                    const Text('Revenue')
                  ],
                ),),
                Expanded(child:
                Column(
                  children: [
                    TextButton(onPressed:()=>showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                      style: TextButton.styleFrom(
                                        onSurface: Colors.white,
                                        backgroundColor:Colors.blue,

                                      ),
                                      onPressed:() {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ISPage()),
                                        );// Navigate back to first route when tapped.
                                      }, child:const Text('Income Statement')),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                      style: TextButton.styleFrom(
                                        onSurface: Colors.white,
                                        backgroundColor:Colors.blue,

                                      ),
                                      onPressed:() {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => BSPage()),
                                        );// Navigate back to first route when tapped.
                                      }, child:const Text('Balance Sheet')),
                                ],
                              ),
                              // Column(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   children: [
                              //     ElevatedButton(
                              //         style: TextButton.styleFrom(
                              //           onSurface: Colors.white,
                              //           backgroundColor:Colors.blue,
                              //
                              //         ),
                              //         onPressed:() {
                              //           Navigator.push(
                              //             context,
                              //             MaterialPageRoute(builder: (context) => CFPage()),
                              //           );// Navigate back to first route when tapped.
                              //         }, child:const Text('Cash Flow')),
                              //   ],
                              // ),
                              const SizedBox(height: 15),
                              // TextButton(
                              // onPressed: () {
                              // Navigator.pop(context);
                              // },
                              // child: const Text('Close'),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ), child: const Icon(Icons.add_circle)),
                  ],
                ),),
                Expanded(child:
                Column(
                  children: [
                    TextButton(onPressed:() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ExpensesPage()),
                      );// Navigate back to first route when tapped.
                    }, child: const Icon(Icons.pie_chart)),
                    const Text('Expenses')
                  ],
                ),),
                Column(
                  children: [
                    TextButton(onPressed:() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FundingPage()),
                      );// Navigate back to first route when tapped.
                    }, child: const Icon(Icons.attach_money_sharp)),
                    const Text('Funding')
                  ],
                ),
              ],
            ),                  //See Description Below for the other arguments of the Footer Component
          ),
          flex: 8
      ),);
  }
}