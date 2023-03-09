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
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:angles/angles.dart';
import 'dart:math' as math;
//import 'package:fluttertoast/fluttertoast.dart';
final threeQuarterTurn = Angle.halfTurn() + Angle.degrees(180.0);

String theDate = DateFormat.d().format(DateTime.now());
String month = DateFormat.MMMM().format(DateTime.now());
String the_year = DateFormat('yyyy').format(DateTime.now());

String getMonth(int currentMonthIndex) {
  return DateFormat('MMM').format(DateTime(0, currentMonthIndex)).toString();
}

String the_month = month;
String actualDate = theDate + "-" + month + "-" + the_year;
String actualMonthRef = month + "-" + the_year;

Future<void> signOut() async {
  await Auth().signOut();
}
class GuideRoute extends StatelessWidget {
  const GuideRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfPdfViewer.asset(
          'assets/guide.pdf'),
    );
  }
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

class MenuItem {
  final String text;
  final IconData icon;

  const MenuItem({
    required this.text,
    required this.icon,
  });
}

class MenuItems {
  static const List<MenuItem> firstItems = [home,guide,reviseBudget, settings];
  static const List<MenuItem> secondItems = [logout];

  static const home =
      MenuItem(text: 'Profile', icon: Icons.supervised_user_circle_outlined);
  static const guide =
  MenuItem(text: 'User Guide', icon: Icons.verified_user_rounded);
  static const settings = MenuItem(text: 'Reset', icon: Icons.delete_forever);
  static const logout = MenuItem(text: 'Log Out', icon: Icons.logout);
  static const reviseBudget = MenuItem(text: 'Set Budgets', icon: Icons.money_off);
  static Widget buildItem(MenuItem item) {
    return Row(
      children: [
        Icon(item.icon, color: Colors.white, size: 22),
        const SizedBox(
          width: 10,
        ),
        Text(
          item.text,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  static onChanged(BuildContext context, MenuItem item) {
    final User? user = Auth().currentUser;
    String uid = user?.uid ?? 'uid';
    String email = user?.email ?? 'email';
    TextEditingController smeNameController = new TextEditingController();
    TextEditingController userNameController = new TextEditingController();
    TextEditingController mainNumberController = new TextEditingController();
    String mainSme = "", number = "", key = "";
    late DatabaseReference reference;
    update() async {
      print('im inn ' + key);
      reference = FirebaseDatabase.instance.ref('User' + '/' + key);
      Map<String, String> revenue1 = {
        'sme': smeNameController.text,
        'number': mainNumberController.text,
        'fname':userNameController.text
      };
      await reference.update(revenue1);
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignIn()),
      );
    }

    @override
    startState() {
      // TODO: implement initState
      print("Im here");

      FirebaseDatabase.instance
          .ref()
          .child('User/')
          .onChildAdded
          .listen((event) {
        Map revenue = event.snapshot.value as Map;
        revenue['key'] = event.snapshot.key;
        if (email == revenue['email']) {
          key = revenue['key'];
          reference = FirebaseDatabase.instance.ref('Users' + '/' + key);
          //number =revenue['number'];
          mainSme = revenue['sme'];

          smeNameController.text = mainSme;
          userNameController.text= revenue['fname'];
          // Step 2 <- SEE HERE
          mainNumberController.text = revenue['number'].toString();
          print('Key ' + key);
        }
      });
    }

    startState();
    switch (item) {
      case MenuItems.home:
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Update Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextField(
                      controller: userNameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'User Name',
                        hintText: 'Enter User Name',
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: smeNameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'SME Name',
                        hintText: 'Enter SME Name',
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: mainNumberController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Phone Number',
                        hintText: 'Enter Phone Number',
                      ),
                    ),
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
                          onPressed: () {
                            Navigator.pop(context);
                            update();
                            // reference.push().set(revenue);

                            SignIn;
                          },
                          child: const Text('Update'),
                          color: Colors.blue,
                          textColor: Colors.white,
                          minWidth: 300,
                        ),
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
                              backgroundColor: Colors.red,
                              minimumSize: const Size.fromHeight(50),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Close')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        //Do something
        break;
      case MenuItems.guide:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GuideRoute()),
        );

        break;
      case MenuItems.reviseBudget:
        final salesTargetController = TextEditingController();
        final actionPlanController = TextEditingController();
        final revenueBudgetController = TextEditingController();
        final fixedCostsController = TextEditingController();
        final revenueTargetController = TextEditingController();
        final expensesTargetController = TextEditingController();
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Revise Budget',
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: revenueBudgetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Revenue Budget ',
                        hintText: 'Enter Revenue Budget',
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: fixedCostsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Fixed Costs Budget',
                        hintText: 'Enter Fixed Costs Budget',
                      ),
                    ),
                    // const SizedBox(height: 15),
                    // TextField(
                    //   controller: revenueTargetController,
                    //   keyboardType: TextInputType.number,
                    //   decoration: const InputDecoration(
                    //     border: OutlineInputBorder(),
                    //     labelText: 'Revenue Target ',
                    //     hintText: 'Enter Revenue Target',
                    //   ),
                    // ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: expensesTargetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Daily Expenses Budget',
                        hintText: 'Enter Daily Expenses Budget',
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    Map<String, String> revenue = {
                      'salesTarget': '',
                      'actionPlan': '',
                      'revenueBudget': revenueBudgetController.text,
                      'fixedCosts': fixedCostsController.text,
                      'revenueTarget': '',
                      'expensesTarget': expensesTargetController.text
                    };

                    FirebaseDatabase.instance.ref().child('budgets/' + uid).push().set(revenue);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );

        break;
      case MenuItems.settings:
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Erase Company Data'),
            content: const Text(
                'Are you sure you want to erase all your Company Data?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => {Navigator.pop(context, 'No')},
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => {
                  FirebaseDatabase.instance.ref("Revenue/" + uid).remove(),
                  FirebaseDatabase.instance.ref("Expenses/" + uid).remove(),
                  FirebaseDatabase.instance.ref("budgets/" + uid).remove(),
                  FirebaseDatabase.instance
                      .ref("trackExpensesCartegory/" + uid)
                      .remove(),
                  FirebaseDatabase.instance
                      .ref("trackMorningMessage/" + uid)
                      .remove(),
                  FirebaseDatabase.instance.ref("trackRevenue/" + uid).remove(),
                  FirebaseDatabase.instance
                      .ref("trackExpenses/" + uid)
                      .remove(),
                  FirebaseDatabase.instance
                      .ref("balanceSheet/" + uid)
                      .remove(),
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignIn()),
                  ),
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        break;

      case MenuItems.logout:
        //Do something
        Auth().signOut();
        print('baya wabaya');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
        break;
    }
  }
}

class HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  int _selectedIndex = 0;

  // Check if the user is signed in
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // only scroll to top when current index is selected.
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignIn()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RevenuePage()));
        break;
      case 2:
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
            alignment: Alignment.bottomCenter,
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ISPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Text('Income Statement')),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BSPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Text('     Balance Sheet   ')),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AdvisoryPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: Text('     $threeQuarterTurn Business Advisory  ')),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ExpensesPage()));
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FundingPage()));
        break;
    }
  }

  // Check if the user is signed in
  Column _buildInsightColumn(
      Color color, Color color2, String amount, String desc) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 10, // <-- SEE HERE
        ),
        Text(
          amount,
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

  Column _buildInsight2Column(
      Color color, Color color2, String desc2, String amount, String desc) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 10, // <-- SEE HERE
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: Text(desc2),
        ),
        Text(
          amount,
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
  Color? npColor;
  double totalRevenue = 0;
  double totalExpenses = 0;
  double averageRevenue = 0;
  double percentageRevenue = 0;
  int countRevenue = 0;
  double total = 0;
  double rp = 0;
  double cp = 0;
  double np = 0;

  late DatabaseReference dbRef;
  late DatabaseReference reference;
  late DatabaseReference budget_reference;
  String sme = '';
  String UserName = "";
  String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final salesTargetController = TextEditingController();
  final actionPlanController = TextEditingController();
  final revenueBudgetController = TextEditingController();
  final fixedCostsController = TextEditingController();
  final revenueTargetController = TextEditingController();
  final expensesTargetController = TextEditingController();
  double fixedCosts = 0.0;
  double fr = 0.0;
  double dailyExp = 0, dailyRev = 0, dailyCosts = 0;
  String? selectedValue;
  double revs = 0, exps = 0;
  @override
  void initState() {
    super.initState();

    String uid = user?.uid ?? 'uid'; // <-- Their email
    String mail = user?.email ?? 'email';

    dbRef = FirebaseDatabase.instance.ref().child('budgets/');
    budget_reference = FirebaseDatabase.instance.ref().child('budgets/' + uid);

    FirebaseDatabase.instance
        .ref()
        .child('trackExpenses/' + uid + '/' + actualMonthRef + "/")
        .orderByChild('date').limitToLast(30)
        .onChildAdded
        .listen((event) {
      Map rev = event.snapshot.value as Map;
      setState(() {
        exps += double.parse(rev['amount']);

        data.add(_SalesData(
            rev['date'].substring(0, 2), double.parse(rev['amount'])));
      });
    });

    FirebaseDatabase.instance
        .ref()
        .child('trackRevenue/' + uid + '/' + actualMonthRef + "/")
        .orderByChild('date').limitToLast(30)
        .onChildAdded
        .listen((event) {
      Map rev = event.snapshot.value as Map;
      setState(() {
        revs += double.parse(rev['amount']);
        data2.add(_SalesData(
            rev['date'].substring(0, 2), double.parse(rev['amount'])));
      });
    });
    getStudentData();
    FirebaseDatabase.instance.ref().child('User/').onChildAdded.listen((event) {
      Map user = event.snapshot.value as Map;
      if (user['email'] == mail) {
        setState(() {
          sme = user['sme'];
          UserName = user['fname'];
        });

        print(sme);
      }
    });
    FirebaseDatabase.instance
        .ref()
        .child('budgets/' + uid)
        .onChildAdded
        .listen((event) {
      Map revenue = event.snapshot.value as Map;

      setState(() {
        fixedCosts = double.parse(revenue['fixedCosts']);
      });
    });
    FirebaseDatabase.instance
        .ref()
        .child('Revenue/' + uid)
        .onChildAdded
        .listen((event) {
      Map revenue = event.snapshot.value as Map;
      countRevenue++;
      setState(() {
        if (revenue['date'] == actualDate) {
          dailyRev += double.parse(revenue['amount']);
        }
        totalRevenue += double.parse(revenue['amount']);
        averageRevenue = totalRevenue / countRevenue;
        percentageRevenue = (averageRevenue / totalRevenue) * 100;

        total = totalRevenue + totalExpenses;
        rp = (totalRevenue / total) * 100;
        cp = (totalExpenses / total) * 100;

        np = totalRevenue - totalExpenses;
        fr = (fixedCosts / totalRevenue) * 100;
      });
    });

    FirebaseDatabase.instance
        .ref()
        .child('Expenses/' + uid)
        .onChildAdded
        .listen((event) {
      Map revenue = event.snapshot.value as Map;

      setState(() {
        totalExpenses += double.parse(revenue['amount']) + fixedCosts;
        total = totalRevenue + totalExpenses;
        print(totalExpenses);
        rp = (totalRevenue / total) * 100;
        cp = (totalExpenses / total) * 100;
        np = totalRevenue - totalExpenses;
        if (revenue['date'] == actualDate) {
          dailyExp += double.parse(revenue['amount']);
          dailyCosts = dailyExp / dailyExp;
        }

        fr = (fixedCosts / totalRevenue) * 100;
        if (np > 0) {
          npColor = Colors.green;
        } else {
          npColor = Colors.red;
        }
      });
    });

    dbRef = FirebaseDatabase.instance.ref().child('Revenue' + '/' + uid);
    reference = FirebaseDatabase.instance.ref().child('Revenue' + '/' + uid);
  }

  void getStudentData() async {
    String uid = user?.uid ?? 'uid';
    DataSnapshot snapshot = await dbRef.child('$uid').get();
    final _formKey = GlobalKey<FormState>();
    Future<void> _showMyDialog() async {
      await Future.delayed(Duration(seconds: 2));
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Hi, $sme. New month, new opportunities. Set your budgets for the month.',
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(child:Form(
              key: _formKey,
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: revenueBudgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Revenue Budget ',
                      hintText: 'Enter Revenue Budget',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Revenue Budget';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: fixedCostsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Fixed Costs Budget',
                      hintText: 'Enter Fixed Costs Budget',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Fixed Costs Budget';
                      }
                      return null;
                    },
                  ),
                  // const SizedBox(height: 15),
                  // TextField(
                  //   controller: revenueTargetController,
                  //   keyboardType: TextInputType.number,
                  //   decoration: const InputDecoration(
                  //     border: OutlineInputBorder(),
                  //     labelText: 'Revenue Target ',
                  //     hintText: 'Enter Revenue Target',
                  //   ),
                  // ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: expensesTargetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Daily Expenses Budget',
                      hintText: 'Enter Daily Expenses Budget',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Daily Expenses Budget';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),),
            actions: <Widget>[
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.


                    Map<String, String> revenue = {
                      'salesTarget': '',
                      'actionPlan': '',
                      'revenueBudget': revenueBudgetController.text,
                      'fixedCosts': fixedCostsController.text,
                      'revenueTarget': '',
                      'expensesTarget': expensesTargetController.text
                    };

                    budget_reference.push().set(revenue);
                    Navigator.of(context).pop();
                  };
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
          //test dropdown
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              customButton: const Icon(
                Icons.menu_rounded,
                size: 46,
                color: Colors.white,
              ),
              customItemsHeights: [
                ...List<double>.filled(MenuItems.firstItems.length, 48),
                8,
                ...List<double>.filled(MenuItems.secondItems.length, 48),
              ],
              items: [
                ...MenuItems.firstItems.map(
                  (item) => DropdownMenuItem<MenuItem>(
                    value: item,
                    child: MenuItems.buildItem(item),
                  ),
                ),
                const DropdownMenuItem<Divider>(
                    enabled: false, child: Divider()),
                ...MenuItems.secondItems.map(
                  (item) => DropdownMenuItem<MenuItem>(
                    value: item,
                    child: MenuItems.buildItem(item),
                  ),
                ),
              ],
              onChanged: (value) {
                MenuItems.onChanged(context, value as MenuItem);
              },
              itemHeight: 48,
              itemPadding: const EdgeInsets.only(left: 16, right: 16),
              dropdownWidth: 160,
              dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.blue,
              ),
              dropdownElevation: 8,
              offset: const Offset(0, 8),
            ),
          ),
          //test dropdown
        ],
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: Container(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 20, left: 20, right: 20),
              decoration: BoxDecoration(
                  //  border: Border.all(width: 2.0, color: insightColor2),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              alignment: Alignment.center,
              child: SemicircularIndicator(
                radius: 140,
                color: Colors.green,
                backgroundColor: Colors.red,
                strokeWidth: 20,
                strokeCap: StrokeCap.square,
                progress: rp / 100,
                bottomPadding: 5,
                contain: true,
                child: Column(
                  children: [
                    Text(
                      '\n\n$sme',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue),
                    ),
                    Text(
                      'Month To Date\n$date\n',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue),
                    ),
                    Text(
                      '\nNet Position',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green),
                    ),
                    Text(
                      '\$' + np.toStringAsFixed(0) + ' \n',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: npColor),
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Revenue'),
                          Icon(Icons.square, color: Colors.green),
                          Text('Costs'),
                          Icon(Icons.square, color: Colors.red),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Container(
            padding:
                const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
            child: const Text(
              'Insights',
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
                decoration: BoxDecoration(
                    color: insightColor1,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: _buildInsightColumn(insightColor1, insightColor4,
                    dailyRev.toStringAsFixed(0), 'Daily Revenue\n'),
              ),
              Container(
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                    color: insightColor2,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: _buildInsightColumn(insightColor2, insightColor5,
                    dailyExp.toStringAsFixed(0), 'Daily Expenses\n'),
              ),
              Container(
                decoration: BoxDecoration(
                    color: insightColor3,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: _buildInsightColumn(
                    insightColor3,
                    insightColor6,
                    dailyCosts.toStringAsFixed(2) + '%',
                    'Daily Costs/\n   Revenue'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: _buildInsight2Column(Colors.green, Colors.black,
                    '       MTD       ', '\$$revs', 'Revenue\n'),
              ),
              Container(
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: _buildInsight2Column(
                  Colors.red,
                  Colors.black,
                  '       MTD       ',
                  '\$$exps',
                  'Expenses\n',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: _buildInsight2Column(
                    Colors.orange,
                    Colors.black,
                    '       MTD       ',
                    '\$$fixedCosts',
                    '  Fixed Costs    \n'),
              ),
            ],
          ),
          const Text(
            '    Breakeven',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          //Initialize the chart widget
          Container(
            padding: const EdgeInsets.all(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              // decoration: BoxDecoration(
              //   border: Border.all(width: 2.0, color: insightColor2),
              // ),
              child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  // Chart title
                  title: null,
                  // Enable legend
                  legend: Legend(isVisible: false),
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
                  ]),
            ),
          ),

          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Revenue'),
                Icon(Icons.square, color: Colors.blue),
                Text('Expenses'),
                Icon(Icons.square, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 15),
          ////curved graph

          ////curved graph
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Revenue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money_sharp),
            label: 'Funding',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}

class SecondRoute extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  //SecondRoute({Key? key}) : super(key: key);

  SecondRoute(
      {super.key,
        required this.ky,
        required this.amount,
        required this.plan,
        required this.comment,
        required this.date,
        required this.margin});
  final String amount;
  final String plan;
  final String comment;
  final String date;
  final String margin;
  final String ky;
  final User? user = Auth().currentUser;
  @override
  //SecondRouteState createState() => SecondRouteState();
  State<SecondRoute> createState() => SecondRouteState();
}

class SecondRouteState extends State<SecondRoute> {
  int _selectedIndex = 1;

  // Check if the user is signed in
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
      // only scroll to top when current index is selected.
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignIn()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RevenuePage()));
        break;
      case 2:
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
            alignment: Alignment.bottomCenter,
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ISPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Text('Income Statement')),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BSPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Text('     Balance Sheet   ')),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AdvisoryPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: Text('     $threeQuarterTurn Business Advisory  ')),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ExpensesPage()));
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FundingPage()));
        break;
    }
  }
  final User? user = Auth().currentUser;




  late DatabaseReference reference;
  String sme = '';
  String uid = '';

  // <-- Their email

  //const SecondRoute({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue'),
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  widget.date,
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
                  widget.comment,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ]),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$' + widget.amount,
                        style: TextStyle(
                          fontSize: 38,
                        ),
                      ),
                    ]),
              ),
            ]),
            SizedBox(height: 50),
            Text(
              'Margin',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(widget.margin + "%"),
            SizedBox(height: 50),
            Text(
              'Daily Comment',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(widget.comment),
            SizedBox(height: 50),
            Text(
              'Key Action Plan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(widget.plan),
            SizedBox(height: 80),
            ElevatedButton(
              onPressed: () {
                uid = user?.uid ?? 'uid';
                reference =
                    FirebaseDatabase.instance.ref("Revenue/" + uid + "/" + widget.ky);

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
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Revenue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money_sharp),
            label: 'Funding',
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ThirdRoute extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  //SecondRoute({Key? key}) : super(key: key);

  ThirdRoute(
      {super.key,
        required this.ky,
        required this.amount,
        required this.plan,
        required this.comment,
        required this.date,
        required this.margin});
  final String amount;
  final String plan;
  final String comment;
  final String date;
  final String margin;
  final String ky;
  final User? user = Auth().currentUser;
  @override
  //SecondRouteState createState() => SecondRouteState();
  State<ThirdRoute> createState() => ThirdRouteState();
}

class ThirdRouteState extends State<ThirdRoute> {
  int _selectedIndex = 3;

  // Check if the user is signed in
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
      // only scroll to top when current index is selected.
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignIn()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RevenuePage()));
        break;
      case 2:
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
            alignment: Alignment.bottomCenter,
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ISPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Text('Income Statement')),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BSPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Text('     Balance Sheet   ')),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AdvisoryPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: Text('     $threeQuarterTurn Business Advisory  ')),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ExpensesPage()));
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FundingPage()));
        break;
    }
  }


  final User? user = Auth().currentUser;
  String uid = '';
  late DatabaseReference reference;
  //const SecondRoute({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense'),
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  widget.date,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  widget.plan,
                  style: TextStyle(),
                ),
                Text(
                  widget.comment,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ]),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$' + widget.amount,
                        style: TextStyle(
                          fontSize: 38,
                        ),
                      ),
                    ]),
              ),
            ]),
            SizedBox(height: 50),
            Text(
              'Expense Title',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(widget.margin),
            SizedBox(height: 50),
            Text(
              'Expense Description',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(widget.comment),
            SizedBox(height: 50),
            Text(
              'Cartegory',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(widget.plan),
            SizedBox(height: 80),
            ElevatedButton(
              onPressed: () {
                uid = user?.uid ?? 'uid';
                reference =
                    FirebaseDatabase.instance.ref("Expenses/" + uid + "/" + widget.ky);

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
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Revenue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money_sharp),
            label: 'Funding',
          ),
        ],
        currentIndex: 3,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
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

  int _selectedIndex = 1;

  // Check if the user is signed in
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // only scroll to top when current index is selected.
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignIn()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RevenuePage()));
        break;
      case 2:
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
            alignment: Alignment.bottomCenter,
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ISPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Text('Income Statement')),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BSPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Text('     Balance Sheet   ')),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AdvisoryPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: Text('     $threeQuarterTurn Business Advisory   ')),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ExpensesPage()));
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FundingPage()));
        break;
    }
  }

  List<_SalesData> data = [];
  List<_SalesData> data2 = [];

  double totalRevenue = 0;
  double averageRevenue = 0;
  double percentageRevenue = 0;
  int countRevenue = 0;
  double budget = 0, dailyRev = 0;

  final amountController = TextEditingController();
  final marginController = TextEditingController();
  final dateController = TextEditingController();
  final commentController = TextEditingController();
  final planController = TextEditingController();
  final Color unselectedItemColor = Colors.blue;
  late Query dbRef;
  late DatabaseReference reference, reference1;
  String currentValue = '0';
  String sme = '';

  getDateValue(date) {
    String uid = user?.uid ?? 'uid';
    FirebaseDatabase.instance
        .ref()
        .child('trackRevenue/' + uid + '/' + actualMonthRef + "/")
        .onChildAdded
        .listen((event) {
      Map rev = event.snapshot.value as Map;
      currentValue = rev['amount'];
      // rev['key'] = event.snapshot.key;
      print(currentValue.toString() + " IS THE AMOUNT CURRENT");
    });

    print(currentValue.toString() + " IS THE AMOUNT CURRENT21");
  }

  Future<void> updateMonthlyRevenue(amount, date,cogs) async {
    double currentValue = 0, newValue = 0;
    double currentCOGS = 0, newCOGS = 0;
    DatabaseReference refe,refe2,refe3;
    String uid = user?.uid ?? 'uid';
    print("Zvakadzora naTocky");
    refe3 = FirebaseDatabase.instance
        .ref()
        .child('Expenses/' + uid + '/'+date);
    refe2 = FirebaseDatabase.instance
        .ref()
        .child('trackExpenses/' + uid + '/' + actualMonthRef + "/" + date);
    refe = FirebaseDatabase.instance
        .ref()
        .child('trackRevenue' + '/' + uid + '/' + actualMonthRef + "/" + date);

    FirebaseDatabase.instance
        .ref()
        .child('trackRevenue/' + uid + '/' + actualMonthRef + "/")
        .onChildAdded
        .listen((event) {
      Map rev = event.snapshot.value as Map;
      setState(() {
        if (rev['date'] == date) {
          currentValue = double.parse(rev['amount']);
          currentCOGS=double.parse(rev['cogs']);
        }
        // rev['key'] = event.snapshot.key;
        print("date is  " + rev['date']);
      });
    });

    await Future.delayed(Duration(seconds: 1));
    print("Zvakadzora naTocky2");
    newValue = currentValue + double.parse(amount);
    newCOGS = currentCOGS + cogs;
    print(currentValue.toString() +
        " IS THE AMOUNT CURRENT new Value is " +
        newValue.toString());

    Map<String, String> trackRevenue = {
      'amount': newValue.toString(),
      'date': date,
      'cogs':newCOGS.toString(),
    };
    Map<String, String> trackExp = {

      'cogs':newCOGS.toString(),
    };
    Map<String, String> addToExpense = {
      'amount': newCOGS.toString(),
      'margin': 'COGS',
      'date': date,
      'comment': 'COGS',
      'plan': 'COGS',
    };
    refe.set(trackRevenue);
   refe2.update(trackExp);
    refe3.update(addToExpense);
  }

  Future<void> morningMessage() async {
    String uid = user?.uid ?? 'uid';
    double budget = 0;
    FirebaseDatabase.instance
        .ref()
        .child('budgets/' + uid)
        .onChildAdded
        .listen((event) {
      Map revenue = event.snapshot.value as Map;

      setState(() {
        budget = double.parse(revenue['revenueBudget']) / 30;
      });
    });
    await Future.delayed(Duration(seconds: 1));
    DatabaseReference dbRefe = FirebaseDatabase.instance.ref().child(
        'trackMorningMessage/' + uid + '/' + actualMonthRef + '/' + actualDate);
    DataSnapshot snapshot = await dbRefe.get();



    if (snapshot.value == null) {
      print("Item doesn't exist in the db");
      Map<String, String> cartegories = {
        'Advertising': '0',
      };

      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Rise and shine.'),
          content: Text(
              'New day! New opportunities! Your revenue target for today is \$' +
                  budget.toStringAsFixed(2)),
          actions: <Widget>[
            // TextButton(
            //   onPressed: () =>{ Navigator.pop(context, 'No')},
            //   child: const Text('No'),
            // ),
            TextButton(
              onPressed: () => {
                dbRefe.set(cartegories),
                Navigator.pop(context, 'No'),
              },
              child: const Text('Noted. Thank You.'),
            ),
          ],
        ),
      );
    } else {
      print("Item exists in the db snap $snapshot");
    }

    Timer mytimer = Timer.periodic(Duration(seconds: 1800), (timer) {
      if (snapshot.value == null) {
        print("Item doesn't exist in the db");
        Map<String, String> cartegories = {
          'Advertising': '0',
        };

        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Rise and shine.'),
            content: Text(
                'New day! New opportunities! Your revenue target for today is \$' +
                    budget.toStringAsFixed(2)),
            actions: <Widget>[
              // TextButton(
              //   onPressed: () =>{ Navigator.pop(context, 'No')},
              //   child: const Text('No'),
              // ),
              TextButton(
                onPressed: () => {
                  dbRefe.set(cartegories),
                  Navigator.pop(context, 'No'),
                },
                child: const Text('Noted. Thank You.'),
              ),
            ],
          ),
        );
      } else {
        print("Item exists in the db snap $snapshot");
      }
    });
  }

  @override
  void initState() {
    super.initState();

    String uid = user?.uid ?? 'uid'; // <-- Their email
    String mail = user?.email ?? 'email';

    morningMessage();

    FirebaseDatabase.instance
        .ref()
        .child('budgets/' + uid)
        .onChildAdded
        .listen((event) {
      Map revenue = event.snapshot.value as Map;

      setState(() {
        budget = double.parse(revenue['revenueBudget']);
      });
    });
    FirebaseDatabase.instance
        .ref()
        .child('trackRevenue/' + uid + '/' + actualMonthRef + "/")
        .orderByChild('date').limitToLast(30)
        .onChildAdded
        .listen((event) {
      Map rev = event.snapshot.value as Map;
      setState(() {
        if (rev['date'] == actualDate) {
          dailyRev += double.parse(rev['amount']);
        }

        data2.add(_SalesData(
            rev['date'].substring(0, 2), double.parse(rev['amount'])));
        data.add(_SalesData(rev['date'].substring(0, 2), budget));
      });
    });

    FirebaseDatabase.instance.ref().child('User/').onChildAdded.listen((event) {
      Map user = event.snapshot.value as Map;
      if (user['email'] == mail) {
        setState(() {
          sme = user['sme'];
        });

        print(sme);
      }
    });
    Map? revenueTrack;
    FirebaseDatabase.instance
        .ref()
        .child('trackRevenue/' + uid + '/' + actualMonthRef + "/")
        .onChildAdded
        .listen((event) {
      revenueTrack = event.snapshot.value as Map;
    });

    String getDate = "";
    double dateAmount = 0.0;

    FirebaseDatabase.instance
        .ref()
        .child('Revenue/' + uid)
        .orderByChild("date").limitToLast(30)
        .onChildAdded
        .listen((event) {
      Map revenue = event.snapshot.value as Map;
      countRevenue++;

      setState(() {
        totalRevenue += double.parse(revenue['amount']);
        averageRevenue = totalRevenue / countRevenue;
        percentageRevenue = (averageRevenue / totalRevenue) * 100;

        if (getDate == revenue['date'].substring(0, 2)) {
          getDate = "";
          dateAmount += double.parse(revenue['amount']);
        } else {
          getDate = revenue['date'].substring(0, 2);
          dateAmount += double.parse(revenue['amount']);
        }
      });
      if (getDate != "") {
        // data2.add(_SalesData(getDate, dateAmount));
        // data.add(_SalesData(getDate, budget));
        dateAmount = 0;
      }
    });
    dbRef = FirebaseDatabase.instance.ref().child('Revenue' + '/' + uid);

    reference = FirebaseDatabase.instance.ref().child('Revenue' + '/' + uid);
    reference1 = FirebaseDatabase.instance
        .ref()
        .child('trackRevenue/' + uid + '/' + actualMonthRef + "/");
  }

  Widget listRevenue({required Map revenue}) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SecondRoute(
                    ky: revenue['key'],
                    amount: revenue['amount'],
                    plan: revenue['plan'],
                    comment: revenue['comment'],
                    margin: revenue['margin'],
                    date: revenue['date'])),
          );
          // Add what you want to do on tap
        },
        child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              ]),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$' + revenue['amount'],
                        style: TextStyle(
                          fontSize: 38,
                        ),
                      ),
                    ]),
              ),
            ])));
  }
  final _formKey = GlobalKey<FormState>();
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
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              customButton: const Icon(
                Icons.menu_rounded,
                size: 46,
                color: Colors.white,
              ),
              customItemsHeights: [
                ...List<double>.filled(MenuItems.firstItems.length, 48),
                8,
                ...List<double>.filled(MenuItems.secondItems.length, 48),
              ],
              items: [
                ...MenuItems.firstItems.map(
                  (item) => DropdownMenuItem<MenuItem>(
                    value: item,
                    child: MenuItems.buildItem(item),
                  ),
                ),
                const DropdownMenuItem<Divider>(
                    enabled: false, child: Divider()),
                ...MenuItems.secondItems.map(
                  (item) => DropdownMenuItem<MenuItem>(
                    value: item,
                    child: MenuItems.buildItem(item),
                  ),
                ),
              ],
              onChanged: (value) {
                MenuItems.onChanged(context, value as MenuItem);
              },
              itemHeight: 48,
              itemPadding: const EdgeInsets.only(left: 16, right: 16),
              dropdownWidth: 160,
              dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.blue,
              ),
              dropdownElevation: 8,
              offset: const Offset(0, 8),
            ),
          ),
        ],
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          //Initialize the chart widget
          Container(
            padding: const EdgeInsets.all(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  //border: Border.all(width: 2.0, color: insightColor2),
                  ),
              child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  // Chart title
                  title:
                      ChartTitle(text: 'Month Revenue - $the_month $the_year'),
                  // Enable legend
                  legend: Legend(isVisible: false),
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
                  ]),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Revenue'),
                Icon(Icons.square, color: Colors.blue),
                Text('Budget'),
                Icon(Icons.square, color: Colors.grey),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey,
                    child: Column(
                      children: [
                        Text("\$" + dailyRev.toStringAsFixed(0)),
                        const Text(''),
                        const Text('Daily Revenue'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.blueGrey,
                    child: Column(
                      children: [
                        const Text('Average'),
                        Text("\$" + averageRevenue.toStringAsFixed(0)),
                        const Text('Daily Revenue'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.grey,
                    child: Column(
                      children: [
                        const Text('MTD'),
                        Text("\$" + totalRevenue.toStringAsFixed(0)),
                        const Text('Revenue'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => Dialog(
                child:Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(8.0),
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            'Daily Revenue',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Missing Required Field';
                              }
                              return null;
                            },
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Amount \$',
                              hintText: 'Enter Amount',
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Missing Required Field';
                              }
                              return null;
                            },
                            controller: marginController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Margin',
                              hintText: 'Enter Gross Margin %',
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextfieldDatePicker(
                            cupertinoDatePickerBackgroundColor: Colors.white,
                            cupertinoDatePickerMaximumDate: DateTime.now(),
                            cupertinoDatePickerMaximumYear: 2023,
                            cupertinoDatePickerMinimumYear: 1990,
                            cupertinoDatePickerMinimumDate: DateTime(1990),
                            cupertinoDateInitialDateTime: DateTime.now(),
                            materialDatePickerFirstDate: DateTime(2021),
                            materialDatePickerInitialDate: DateTime.now(),
                            materialDatePickerLastDate: DateTime.now(),
                            preferredDateFormat: DateFormat('dd-MMMM-' 'yyyy'),
                            onSaved: getDateValue(dateController.text),
                            textfieldDatePickerController: dateController,
                            style: TextStyle(
                              fontSize: 1000 * 0.040,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              //errorText: errorTextValue,onSaved
                              helperStyle: TextStyle(
                                  fontSize: 1000 * 0.031,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.white, width: 0),
                                  borderRadius: BorderRadius.circular(2)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    color: Colors.white,
                                  )),
                              hintText: 'Select Date Received',
                              hintStyle: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              filled: true,
                              fillColor: Colors.blue,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Missing Required Field';
                              }
                              return null;
                            },
                            controller: commentController,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Daily Comment',
                              hintText: 'Enter Daily Comment',
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Missing Required Field';
                              }
                              return null;
                            },
                            controller: planController,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Key Action Plan',
                              hintText: 'Enter Key Action Plan',
                            ),
                          ),
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
                                onPressed: () {
                                  if (_formKey.currentState!.validate()){
                                    Map<String, String> revenue = {
                                      'amount': amountController.text,
                                      'margin': marginController.text,
                                      'date': dateController.text,
                                      'comment': commentController.text,
                                      'plan': planController.text
                                    };

                                    Map<String, String> trackRevenue = {
                                      dateController.text: amountController.text,
                                    };
                                    double amo=double.parse(amountController.text);
                                    double margi=(100-double.parse(marginController.text))/100;
                                    double cogs=amo*margi;
                                    updateMonthlyRevenue(
                                        amountController.text, dateController.text,cogs);

                                    reference.push().set(revenue);
                                    //reference1.set(trackRevenue);

                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text('Save'),
                                color: Colors.blue,
                                textColor: Colors.white,
                                minWidth: 300,
                              ),
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
                                    backgroundColor: Colors.red,
                                    minimumSize: const Size.fromHeight(50),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Close')),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),),
              ),
            ),
            child: const Text('Add Daily Revenue'),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              backgroundColor: Colors.blue,
              minimumSize: const Size.fromHeight(50), // NEW
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                FirebaseAnimatedList(
                  shrinkWrap: true,
                  query: dbRef,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    Map revenue = snapshot.value as Map;
                    revenue['key'] = snapshot.key;

                    return listRevenue(revenue: revenue);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30, // <-- SEE HERE
          ),

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Revenue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money_sharp),
            label: 'Funding',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
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
  int _selectedIndex = 4;
  // Check if the user is signed in
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // only scroll to top when current index is selected.
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignIn()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RevenuePage()));
        break;
      case 2:
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
            alignment: Alignment.bottomCenter,
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ISPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Text('Income Statement')),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BSPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Text('     Balance Sheet   ')),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AdvisoryPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: Text('     $threeQuarterTurn Business Advisory   ')),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ExpensesPage()));
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FundingPage()));
        break;
    }
  }

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
    },
    {
      'value':
          'Our funding is highly prioritised towards value adding equipment in order to build manufactoring capacity for small business in Africa, such businesses take priority on our funding initiatives.',
      'label': '',
      'icon': null,
    }
  ];
  PlatformFile? pickedFile;
  PlatformFile? pickedFile2;
  PlatformFile? pickedFile3;
  UploadTask? uploadTask;
  Future selectFile1() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future selectFile2() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile2 = result.files.first;
    });
  }

  Future selectFile3() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile3 = result.files.first;
    });
  }

  String uploaded = '';
  Future uploadFiles() async {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => Dialog(
        alignment: Alignment.bottomCenter,
        backgroundColor: Colors.red,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "To start accessing our flexible, no collateral, data driven and low to no interest funding you need to have been on our platform for 3months minimum.",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
    // Fluttertoast.showToast(
    //     msg: "To start accessing our flexible, no collateral, data driven and low to no interest funding you need to have been on our platform for 3months minimum.",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.red,
    //     textColor: Colors.white,
    //     fontSize: 16.0
    // );
    // setState(() {
    //   uploaded = "Uploading Please Wait....";
    // });
    // String uid = user?.uid ?? 'uid';
    // final path = 'funding/' + uid + '/analysis.pdf';
    // final path2 = 'funding/' + uid + '/istatement.pdf';
    // final path3 = 'funding/' + uid + '/bsheet.pdf';
    //
    // final file = File(pickedFile!.path!);
    // final file2 = File(pickedFile2!.path!);
    // final file3 = File(pickedFile3!.path!);
    //
    // final ref = FirebaseStorage.instance.ref().child(path);
    // uploadTask = ref.putFile(file);
    //
    // final snapshot = await uploadTask!.whenComplete(() => {});
    // final urlDownload = await snapshot.ref.getDownloadURL();
    // print('Dowload link: $urlDownload');
    //
    // final ref2 = FirebaseStorage.instance.ref().child(path2);
    // uploadTask = ref2.putFile(file2);
    //
    // final ref3 = FirebaseStorage.instance.ref().child(path3);
    // uploadTask = ref3.putFile(file3);
    // setState(() {
    //   uploaded = "Funding Request Sent Thank You";
    // });
  }

  double totalRevenue = 0;
  double averageRevenue = 0;
  double percentageRevenue = 0;
  int countRevenue = 0;
  double funding = 0.0;
  double fundingp = 0.0;
  double pol = 0.0;
  String minus = " ";
  String pos = " ";
  String eq = " ";

  double totalExpenses = 0.0;

  final amountController = TextEditingController();
  final marginController = TextEditingController();
  final dateController = TextEditingController();
  final commentController = TextEditingController();
  final planController = TextEditingController();

  late Query dbRef;
  late DatabaseReference reference;
  String sme = "";
  @override
  void initState() {
    super.initState();
    String uid = user?.uid ?? 'uid'; // <-- Their email
    String mail = user?.email ?? 'email';
    FirebaseDatabase.instance.ref().child('User/').onChildAdded.listen((event) {
      Map user = event.snapshot.value as Map;
      if (user['email'] == mail) {
        setState(() {
          sme = user['sme'];
        });

        print(sme);
      }
    });

    dbRef = FirebaseDatabase.instance.ref().child('Revenue' + '/' + uid);
    reference = FirebaseDatabase.instance.ref().child('Revenue' + '/' + uid);
    FirebaseDatabase.instance
        .ref()
        .child('Revenue/' + uid)
        .onChildAdded
        .listen((event) {
      Map revenue = event.snapshot.value as Map;
      setState(() {
        totalRevenue += double.parse(revenue['amount']);
        funding = pol * 2.5;
        fundingp = funding / 100000;
        pol = totalRevenue - totalExpenses;
        if (pol < 0) {
          minus = "$pol";
          pos = " ";
          eq = " ";
        }
        if (pol > 0) {
          minus = "$pol";
          pos = "$pol";
          eq = " ";
        }
        if (pol == 0) {
          minus = " ";
          pos = " ";
          eq = "$pol";
        }
      });
    });
    FirebaseDatabase.instance
        .ref()
        .child('Expenses/' + uid)
        .onChildAdded
        .listen((event) {
      Map revenue = event.snapshot.value as Map;
      setState(() {
        totalExpenses += double.parse(revenue['amount']);
        pol = totalRevenue - totalExpenses;
        print("pol is $pol");
        if (pol < 0) {
          minus = "\$$pol";
          pos = " ";
          eq = " ";
        }
        if (pol > 0) {
          minus = " ";
          pos = "\$$pol";
          eq = " ";
        }
        if (pol == 0) {
          minus = " ";
          pos = " ";
          eq = "\$$pol";
        }
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
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              customButton: const Icon(
                Icons.menu_rounded,
                size: 46,
                color: Colors.white,
              ),
              customItemsHeights: [
                ...List<double>.filled(MenuItems.firstItems.length, 48),
                8,
                ...List<double>.filled(MenuItems.secondItems.length, 48),
              ],
              items: [
                ...MenuItems.firstItems.map(
                  (item) => DropdownMenuItem<MenuItem>(
                    value: item,
                    child: MenuItems.buildItem(item),
                  ),
                ),
                const DropdownMenuItem<Divider>(
                    enabled: false, child: Divider()),
                ...MenuItems.secondItems.map(
                  (item) => DropdownMenuItem<MenuItem>(
                    value: item,
                    child: MenuItems.buildItem(item),
                  ),
                ),
              ],
              onChanged: (value) {
                MenuItems.onChanged(context, value as MenuItem);
              },
              itemHeight: 48,
              itemPadding: const EdgeInsets.only(left: 16, right: 16),
              dropdownWidth: 160,
              dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.blue,
              ),
              dropdownElevation: 8,
              offset: const Offset(0, 8),
            ),
          ),
        ],
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: <Widget>[
          //Initialize the chart widget

          Column(
            children: <Widget>[
              Text(
                '$uploaded',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Text(
                'Average Profit 3 Months',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Text(""),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "$minus",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "$eq",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "$pos",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Text(""),
                    ],
                  ))
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: LinearPercentIndicator(
                  width: 180.0,
                  lineHeight: 23.0,
                  percent: 0.5,
                  center: Text(
                    " ",
                    style: new TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                    ),
                  ),
                  leading: const Text(
                    "      -",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Colors.red),
                  ),
                  trailing: const Text(
                    "+",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Colors.green),
                  ),
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  backgroundColor: Colors.green,
                  progressColor: Colors.red,
                ),
              ),
              const Text('Your Potential Funding'),
              const SizedBox(
                height: 15,
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(width: 6.0, color: insightColor2),
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: Text("\$" + funding.toString()),
              ),
              Container(
                padding: const EdgeInsets.all(17),
                child: SelectFormField(
                  type: SelectFormFieldType.dialog,
                  controller: planController,
                  //initialValue: _initialValue,
                  icon: Icon(Icons.format_shapes),
                  labelText: 'What do you need funding for',
                  changeIcon: true,
                  dialogTitle: '',
                  dialogCancelBtn: 'Close',
                  enableSearch: false,
                  dialogSearchHint: 'Search',
                  items: _items,
                  onChanged: (val) => setState(() => _valueChanged = val),
                  validator: (val) {
                    setState(() => _valueToValidate = val ?? '');
                    return null;
                  },
                  onSaved: (val) => setState(() => _valueSaved = val ?? ''),
                ),
              ),
              ElevatedButton(
                  onPressed: selectFile1,
                  child: const Text('[Attach] Cost Benefit Analysis')),
              ElevatedButton(
                  onPressed: selectFile2,
                  child: const Text('[Attach] Income Statement')),
              ElevatedButton(
                  onPressed: selectFile3,
                  child: const Text('[Attach] Balance Sheet')),
              const SizedBox(height: 18),
              ElevatedButton(
                  onPressed: uploadFiles, child: const Text('Submit')),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.only(top: 17, left: 17, right: 17),
                child: Column(
                  children: [
                    const Text(
                      'Our analytics help small businesses become profitable whilst our flexible funding rewards profitability by giving you more capital',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Revenue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money_sharp),
            label: 'Funding',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
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
  int _selectedIndex = 3;
  // Check if the user is signed in
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // only scroll to top when current index is selected.
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignIn()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RevenuePage()));
        break;
      case 2:
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
            alignment: Alignment.bottomCenter,
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ISPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Text('Income Statement')),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BSPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Text('     Balance Sheet   ')),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AdvisoryPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: Text('     $threeQuarterTurn Business Advisory   ')),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ExpensesPage()));
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FundingPage()));
        break;
    }
  }

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
  final amountController = TextEditingController();
  final marginController = TextEditingController();
  final dateController = TextEditingController();
  final commentController = TextEditingController();
  final planController = TextEditingController();
  double totalExpenses = 0;
  double averageExpenses = 0;
  double percentageExpenses = 0;
  double fixedCosts = 0, dailyExp = 0;
  int countExpenses = 0;
  String sme = '';

  Future<void> updateMonthlyExpenses(amount, date, cart) async {
    double currentValue = 0, newValue = 0, cartValue = 0, cartNewValue = 0;
    String uid = user?.uid ?? 'uid';
    String? cartKey;
    DatabaseReference refe;
    refe = FirebaseDatabase.instance
        .ref()
        .child('trackExpenses/' + uid + '/' + actualMonthRef + "/" + date);
    DatabaseReference dbRefe = FirebaseDatabase.instance
        .ref()
        .child('trackExpensesCartegory/' + uid + '/' + actualMonthRef);
    DataSnapshot snapshot = await dbRefe.get();
    if (snapshot.value == null) {
      print("Item doesn't exist in the db");
      Map<String, String> cartegories = {
        'Advertising': '0',
        'Business Vehicle(s) Repairs': '0',
        'Employee Commissions': '0',
        'Variable Employee Benefits': '0',
        'Meals & Entertainment': '0',
        'Office': '0',
        'Professional Services': '0',
        'Phone': '0',
        'Travel': '0',
        'Training and Education': '0',
        'Deliveries': '0',
        'Loan & Interest Payments': '0',
        'Other': '0',
        'month': actualMonthRef,
      };

      dbRefe.set(cartegories);
    } else {
      print("Item exists in the db snap $snapshot");
    }
    await Future.delayed(Duration(seconds: 1));
    FirebaseDatabase.instance
        .ref()
        .child('trackExpensesCartegory/' + uid)
        .onChildAdded
        .listen((event) {
      Map rev = event.snapshot.value as Map;
      setState(() {
        cartValue = double.parse(rev[cart]);
      });
    });

    await Future.delayed(Duration(seconds: 1));
    FirebaseDatabase.instance
        .ref()
        .child('trackExpenses/' + uid + '/' + actualMonthRef + "/")
        .onChildAdded
        .listen((event) {
      Map rev = event.snapshot.value as Map;
      setState(() {
        if (rev['date'] == date) {
          currentValue = double.parse(rev['amount']);

          // rev['key'] = event.snapshot.key;
        }

        print("date is  " + rev['date']);
      });
    });

    await Future.delayed(Duration(seconds: 1));
    newValue = currentValue + double.parse(amount);
    cartNewValue = cartValue + double.parse(amount);
    print(currentValue.toString() +
        " IS THE AMOUNT CURRENT new Value is " +
        newValue.toString());

    Map<String, String> trackExpenses = {
      'amount': newValue.toString(),
      'date': date,
      cart: cartNewValue.toString(),
    };

    refe.update(trackExpenses);
    Map<String, String> trackCart = {
      cart: cartNewValue.toString(),
      'month': actualMonthRef,
    };

    dbRefe.update(trackCart);
  }

  @override
  void initState() {
    super.initState();
    String uid = user?.uid ?? 'uid';
    String mail = user?.email ?? 'email';

    FirebaseDatabase.instance
        .ref()
        .child('budgets/' + uid)
        .onChildAdded
        .listen((event) {
      Map revenue = event.snapshot.value as Map;

      setState(() {
        fixedCosts = double.parse(revenue['fixedCosts']);
      });
    });
    FirebaseDatabase.instance
        .ref()
        .child('trackExpenses/' + uid + '/' + actualMonthRef + "/")
        .orderByChild('date').limitToLast(30)
        .onChildAdded
        .listen((event) {
      Map rev = event.snapshot.value as Map;
      setState(() {
        if (rev['date'] == actualDate) {
          dailyExp += double.parse(rev['amount'])+double.parse(rev['cogs']);
        }

        data2.add(_SalesData(
            rev['date'].substring(0, 2), double.parse(rev['amount'])+double.parse(rev['cogs'])));
        data.add(_SalesData(rev['date'].substring(0, 2), fixedCosts));
      });
    });
    FirebaseDatabase.instance.ref().child('User/').onChildAdded.listen((event) {
      Map user = event.snapshot.value as Map;
      if (user['email'] == mail) {
        setState(() {
          sme = user['sme'];
        });

        print(sme);
      }
    });
    FirebaseDatabase.instance
        .ref()
        .child('Expenses/' + uid)
        .onChildAdded
        .listen((event) {
      Map revenue = event.snapshot.value as Map;
      countExpenses++;
      setState(() {
        totalExpenses += double.parse(revenue['amount']);
        averageExpenses = totalExpenses / countExpenses;
        percentageExpenses = (averageExpenses / totalExpenses) * 100;
      });
    });
    strings.add("Nepal");
    // <-- Their email

    dbRef = FirebaseDatabase.instance.ref().child('Expenses' + '/' + uid);
    reference = FirebaseDatabase.instance.ref().child('Expenses' + '/' + uid);
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

  Widget listExpenses({required Map revenue}) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ThirdRoute(
                    ky: revenue['key'],
                    amount: revenue['amount'],
                    plan: revenue['plan'],
                    comment: revenue['comment'],
                    margin: revenue['margin'],
                    date: revenue['date'])),
          );
          // Add what you want to do on tap
        },
        child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              ]),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$' + revenue['amount'],
                        style: TextStyle(
                          fontSize: 38,
                        ),
                      ),
                    ]),
              ),
            ])));
  }
  final _formKey = GlobalKey<FormState>();
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
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              customButton: const Icon(
                Icons.menu_rounded,
                size: 46,
                color: Colors.white,
              ),
              customItemsHeights: [
                ...List<double>.filled(MenuItems.firstItems.length, 48),
                8,
                ...List<double>.filled(MenuItems.secondItems.length, 48),
              ],
              items: [
                ...MenuItems.firstItems.map(
                  (item) => DropdownMenuItem<MenuItem>(
                    value: item,
                    child: MenuItems.buildItem(item),
                  ),
                ),
                const DropdownMenuItem<Divider>(
                    enabled: false, child: Divider()),
                ...MenuItems.secondItems.map(
                  (item) => DropdownMenuItem<MenuItem>(
                    value: item,
                    child: MenuItems.buildItem(item),
                  ),
                ),
              ],
              onChanged: (value) {
                MenuItems.onChanged(context, value as MenuItem);
              },
              itemHeight: 48,
              itemPadding: const EdgeInsets.only(left: 16, right: 16),
              dropdownWidth: 160,
              dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.blue,
              ),
              dropdownElevation: 8,
              offset: const Offset(0, 8),
            ),
          ),
        ],
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          //Initialize the chart widget
          Container(
            padding: const EdgeInsets.all(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  // border: Border.all(width: 2.0, color: insightColor2),
                  ),
              child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  // Chart title
                  title:
                      ChartTitle(text: 'Month Expenses - $the_month $the_year'),
                  // Enable legend
                  legend: Legend(isVisible: false),
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
                  ]),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Expenses'),
                Icon(Icons.square, color: Colors.blue),
                Text('Fixed Costs'),
                Icon(Icons.square, color: Colors.grey),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey,
                    child: Column(
                      children: [
                        Text("\$" + dailyExp.toStringAsFixed(0)),
                        const Text(''),
                        const Text('Daily Expenses'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.blueGrey,
                    child: Column(
                      children: [
                        const Text('Average'),
                        Text("\$" + percentageExpenses.toStringAsFixed(0)),
                        const Text('Daily Expenses'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.grey,
                    child: Column(
                      children: [
                        const Text('MTD'),
                        Text("\$" + totalExpenses.toString()),
                        const Text('Expenses'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => Dialog(
                child:Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(8.0),
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            'Daily Expenses',
                            style: TextStyle(
                              fontSize: 22,
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
                            labelText: 'Category',
                            changeIcon: true,
                            dialogTitle: 'Expense Category',
                            dialogCancelBtn: 'CANCEL',
                            enableSearch: true,
                            dialogSearchHint: 'Search',
                            items: _items,
                            onChanged: (val) =>
                                setState(() => _valueChanged = val),
                            validator: (val) {
                              setState(() => _valueToValidate = val ?? '');
                              return null;
                            },
                            onSaved: (val) =>
                                setState(() => _valueSaved = val ?? ''),
                          ),

                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Field Required';
                              }
                              return null;
                            },
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Amount \$',
                              hintText: 'Enter Amount',
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Field Required';
                              }
                              return null;
                            },
                            controller: marginController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Expense Title',
                              hintText: 'Enter Expense Title',
                            ),
                          ),
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
                            materialDatePickerFirstDate: DateTime(2022),
                            materialDatePickerInitialDate: DateTime.now(),
                            materialDatePickerLastDate: DateTime.now(),
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
                                  borderSide: const BorderSide(
                                      color: Colors.white, width: 0),
                                  borderRadius: BorderRadius.circular(2)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    color: Colors.white,
                                  )),
                              hintText: 'Select Paid Date',
                              hintStyle: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              filled: true,
                              fillColor: Colors.grey[300],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Field Required';
                              }
                              return null;
                            },
                            controller: commentController,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Expense Description',
                              hintText: 'Enter Expense Description',
                            ),
                          ),
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
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    Map<String, String> revenue = {
                                      'amount': amountController.text,
                                      'margin': marginController.text,
                                      'date': dateController.text,
                                      'comment': commentController.text,
                                      'plan': planController.text
                                    };

                                    updateMonthlyExpenses(amountController.text,
                                        dateController.text, planController.text);
                                    reference.push().set(revenue);

                                    Navigator.pop(context);
                                  };
                                },
                                child: const Text('Save'),
                                color: Colors.blue,
                                textColor: Colors.white,
                                minWidth: 300,
                              ),
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
                                    backgroundColor: Colors.red,
                                    minimumSize: const Size.fromHeight(50),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Close')),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),),
              ),
            ),
            child: const Text('Add Daily Expenses'),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              backgroundColor: Colors.blue,
              minimumSize: const Size.fromHeight(50), // NEW
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                FirebaseAnimatedList(
                  shrinkWrap: true,
                  query: dbRef,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    Map revenue = snapshot.value as Map;
                    revenue['key'] = snapshot.key;

                    return listExpenses(revenue: revenue);
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 110, // <-- SEE HERE
          ),

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Revenue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money_sharp),
            label: 'Funding',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
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

  int _selectedIndex = 2;
  // Check if the user is signed in
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // only scroll to top when current index is selected.
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignIn()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RevenuePage()));
        break;
      case 2:
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
            alignment: Alignment.bottomCenter,
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ISPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Text('Income Statement')),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BSPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Text('     Balance Sheet   ')),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AdvisoryPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: Text('     $threeQuarterTurn Business Advisory   ')),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ExpensesPage()));
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FundingPage()));
        break;
    }
  }

  List<Employee> employees = <Employee>[];
  late EmployeeDataSource employeeDataSource;
  double totalRevenue = 0;
  double averageRevenue = 0;
  double percentageRevenue = 0;
  int countRevenue = 0;

  double totalExpense = 0;
  double averageExpense = 0;
  double percentageExpense = 0;
  int countExpense = 0;
  double profit = 0;
  late Query dbRefRevenue;
  late Query dbRefExpense;
  late DatabaseReference reference;
  double cogs = 0, gp = 0, fixedCosts = 0;
  String a = '0',
      a1 = '0',
      a2 = '0',
      a3 = '0',
      a4 = '0',
      a5 = '0',
      a6 = '0',
      a7 = '0',
      a8 = '0',
      a9 = '0',
      a10 = '0',
      a11 = '0',
      a12 = '0';

  String sme = '';

  String UserName = "";
  @override
  void initState() {
    super.initState();
    String uid = user?.uid ?? 'uid';
    // <-- Their email
    String mail = user?.email ?? 'email';
    FirebaseDatabase.instance.ref().child('User/').onChildAdded.listen((event) {
      Map user = event.snapshot.value as Map;
      if (user['email'] == mail) {
        setState(() {
          sme = user['sme'];
        });

        print(sme);
      }
    });
    FirebaseDatabase.instance
        .ref()
        .child('budgets/' + uid)
        .onChildAdded
        .listen((event) {
      Map revenue = event.snapshot.value as Map;

      setState(() {
        fixedCosts = double.parse(revenue['fixedCosts']);
        totalExpense += fixedCosts;
      });
    });

    FirebaseDatabase.instance
        .ref()
        .child('trackExpensesCartegory/' + uid)
        .onChildAdded
        .listen((event) {
      Map exp = event.snapshot.value as Map;
      print("advertising is " + exp['Advertising']);
      setState(() {
        a = exp['Advertising'];
        a1 = exp['Business Vehicle(s) Repairs'];
        a2 = exp['Employee Commissions'];
        a3 = exp['Variable Employee Benefits'];
        a4 = exp['Meals & Entertainment'];
        a5 = exp['Office'];
        a6 = exp['Professional Services'];
        a7 = exp['Phone'];
        a8 = exp['Travel'];
        a9 = exp['Training and Education'];
        a10 = exp['Deliveries'];
        a11 = exp['Loan & Interest Payments'];
        a12 = exp['Other'];
        totalExpense = fixedCosts +
            double.parse(a) +
            double.parse(a1) +
            double.parse(a2) +
            double.parse(a3) +
            double.parse(a4) +
            double.parse(a5) +
            double.parse(a6) +
            double.parse(a7) +
            double.parse(a8) +
            double.parse(a9) +
            double.parse(a10) +
            double.parse(a11) +
            double.parse(a12);

        profit = totalRevenue - totalExpense - cogs;
        print(profit);
      });
    });
    FirebaseDatabase.instance.ref().child('User/').onChildAdded.listen((event) {
      Map revenue = event.snapshot.value as Map;
      setState(() {
        countExpense++;

        // totalExpense += double.parse(revenue['amount']);
        averageExpense = totalRevenue / countRevenue;
        percentageExpense = (averageRevenue / totalRevenue) * 100;
      });
    });
    FirebaseDatabase.instance.ref().child('User/').onChildAdded.listen((event) {
      Map revenue = event.snapshot.value as Map;
      setState(() {
        countExpense++;

        // totalExpense += double.parse(revenue['amount']);
        averageExpense = totalRevenue / countRevenue;
        percentageExpense = (averageRevenue / totalRevenue) * 100;
      });
    });
    dbRefRevenue = FirebaseDatabase.instance.ref().child('Revenue' + '/' + uid);
    dbRefRevenue.onChildAdded.listen((event) {
      Map revenue = event.snapshot.value as Map;
      setState(() {
        cogs += (double.parse(revenue['amount']) *
                (100 - double.parse(revenue['margin']))) /
            100;
        totalRevenue += double.parse(revenue['amount']);
        print(totalRevenue);
        profit = totalRevenue - totalExpense - cogs;
        gp = totalRevenue - cogs;
      });
    });

    employees = getEmployeeData();
    employeeDataSource = EmployeeDataSource(employeeData: employees);
  }

  Widget listExpenses({required Map revenue}) {
    return Container(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
                child: Column(
              children: [
                Text(
                  revenue['comment'],
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
            )),
            Expanded(
                child: Column(
              children: [
                Text(
                  revenue['amount'],
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
            )),
            Expanded(
                child: Column(
              children: [
                const Text(''),
              ],
            ))
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
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              customButton: const Icon(
                Icons.menu_rounded,
                size: 46,
                color: Colors.white,
              ),
              customItemsHeights: [
                ...List<double>.filled(MenuItems.firstItems.length, 48),
                8,
                ...List<double>.filled(MenuItems.secondItems.length, 48),
              ],
              items: [
                ...MenuItems.firstItems.map(
                  (item) => DropdownMenuItem<MenuItem>(
                    value: item,
                    child: MenuItems.buildItem(item),
                  ),
                ),
                const DropdownMenuItem<Divider>(
                    enabled: false, child: Divider()),
                ...MenuItems.secondItems.map(
                  (item) => DropdownMenuItem<MenuItem>(
                    value: item,
                    child: MenuItems.buildItem(item),
                  ),
                ),
              ],
              onChanged: (value) {
                MenuItems.onChanged(context, value as MenuItem);
              },
              itemHeight: 48,
              itemPadding: const EdgeInsets.only(left: 16, right: 16),
              dropdownWidth: 160,
              dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.blue,
              ),
              dropdownElevation: 8,
              offset: const Offset(0, 8),
            ),
          ),
        ],
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey,
                    child: Column(
                      children: [
                        const Text("Total Revenue"),
                        Text('\$' + totalRevenue.toString()),
                        const Text(''),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.blueGrey,
                    child: Column(
                      children: [
                        const Text(
                          'Total Expenses',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        Text("\$" + totalExpense.toString()),
                        const Text(''),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.grey,
                    child: Column(
                      children: [
                        const Text('Net Position'),
                        Text("\$" + profit.toStringAsFixed(2)),
                        const Text(''),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            color: Colors.blue,
            child: Column(
              children: [
                Text(""),
                Text('$sme: Income Statement - $the_month $the_year'),
                Text(""),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Column(
                children: [
                  const Text(
                    'Revenue',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '    Less: COGS',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '    Gross Profit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(''),
                    const SizedBox(height: 5),
                    const Text(''),
                    const SizedBox(height: 5),
                    const Text(''),
                  ],
                ),
              ),
              Expanded(
                  child: Column(
                children: [
                  Text(
                    totalRevenue.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "( " + cogs.toStringAsFixed(2) + " )",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    gp.toStringAsFixed(2),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '    Expenses:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "Advertising",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "$a",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      const Text(''),
                    ],
                  ))
                ],
              )),
          Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "Business Vehicle(s) Repairs",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "$a1",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      const Text(''),
                    ],
                  ))
                ],
              )),
          Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "Employee Commissions",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "$a2",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      const Text(''),
                    ],
                  ))
                ],
              )),
          Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "Variable Employee Benefits",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "$a3",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      const Text(''),
                    ],
                  ))
                ],
              )),
          Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "Meals & Entertainment",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "$a4",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      const Text(''),
                    ],
                  ))
                ],
              )),
          Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "Office",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "$a5",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      const Text(''),
                    ],
                  ))
                ],
              )),
          Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "Professional Services",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "$a6",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      const Text(''),
                    ],
                  ))
                ],
              )),
          Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "Phone",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "$a7",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      const Text(''),
                    ],
                  ))
                ],
              )),
          Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "Travel",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "$a8",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      const Text(''),
                    ],
                  ))
                ],
              )),
          Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "Training and Education",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "$a9",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      const Text(''),
                    ],
                  ))
                ],
              )),
          Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "Deliveries",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "$a10",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      const Text(''),
                    ],
                  ))
                ],
              )),
          Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "Loan & Interest Payments",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "$a11",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      const Text(''),
                    ],
                  ))
                ],
              )),
          Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "Other",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "$a12",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      const Text(''),
                    ],
                  ))
                ],
              )),
          Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "Fixed Costs",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        "$fixedCosts",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      const Text(''),
                    ],
                  ))
                ],
              )),
          Row(children: [
            Expanded(
                child: Column(
              children: [
                const Text(
                  'Total Expenses',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
            )),
            Expanded(
                child: Column(
              children: [
                const Text(''),
              ],
            )),
            Expanded(
                child: Column(
              children: [
                Text(
                  '( \$' + totalExpense.toStringAsFixed(2) + ' )',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            )),
          ]),
          Row(children: [
            Expanded(
                child: Column(
              children: [
                const Text(
                  'Net Profit / Loss',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )),
            Expanded(
                child: Column(
              children: [
                const Text(''),
              ],
            )),
            Expanded(
                child: Column(
              children: [
                Text(
                  '\$' + profit.toStringAsFixed(2),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )),
          ]),
          SizedBox(
            height: 85,
          ),

          //Initialize the chart widget
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Revenue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money_sharp),
            label: 'Funding',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
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
  late DatabaseReference dbRef;
  String sme = '';
  String UserName = "";
  //String _initialValue;
  String _valueChangedfixedAssets = '',
      _valueChangedcurrentAssets = '',
      _valueChangedlongTermLiabilities = '',
      _valueChangedcurrentLiabilities = '';
  String _valueToValidatefixedAssets = '',
      _valueToValidatecurrentAssets = '',
      _valueToValidatelongTermLiabilities = '',
      _valueToValidatecurrentLiabilities = '';
  String _valueSavedfixedAssets = '',
      _valueSavedcurrentAssets = '',
      _valueSavedlongTermLiabilities = '',
      _valueSavedcurrentLiabilities = '';
  int _selectedIndexfixedAssets = 3,
      _selectedIndexcurrentAssets = 3,
      _selectedIndexlongTermLiabilities = 3,
      _selectedIndexcurrentLiabilities = 3;
  final List<Map<String, dynamic>> _currentAssets = [
    {
      'value': 'Cash',
      'label': 'Cash',
      'icon': Icon(Icons.money),
    },
    {
      'value': 'Cash equivalents',
      'label': 'Cash equivalents',
      'icon': Icon(Icons.attach_money_sharp),
    },
    {
      'value': 'Short-term deposits',
      'label': 'Short-term deposits',
      'icon': Icon(Icons.comment_bank_rounded),
    },
    {
      'value': 'Accounts receivables',
      'label': 'Accounts receivables',
      'icon': Icon(Icons.account_balance),
    },
    {
      'value': 'Inventory',
      'label': 'Inventory',
      'icon': Icon(Icons.inventory_2_outlined),
    },
    {
      'value': 'Marketable securities',
      'label': 'Marketable securities',
      'icon': Icon(Icons.security),
    },
    {
      'value': 'Office supplies',
      'label': 'Office supplies',
      'icon': Icon(Icons.local_post_office),
    },
  ];
  final List<Map<String, dynamic>> _longTermLiabilities = [
    {
      'value': 'GetFunds Revenue Funding',
      'label': 'GetFunds Revenue Funding',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Bank loan',
      'label': 'Bank loan',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Bank Overdraft',
      'label': 'Bank Overdraft',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Notes Payable',
      'label': 'Notes Payable',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Bond Payable',
      'label': 'Bond Payable',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Deferred Income Taxes',
      'label': 'Deferred Income Taxes',
      'icon': Icon(Icons.monetization_on_outlined),
    },
  ];
  final List<Map<String, dynamic>> _fixedAssets = [
    {
      'value': 'Land',
      'label': 'Land',
      'icon': Icon(Icons.landscape),
    },
    {
      'value': 'Building',
      'label': 'Building',
      'icon': Icon(Icons.house),
    },
    {
      'value': 'Equipment',
      'label': 'Equipment ie Computer',
      'icon': Icon(Icons.computer),
    },
    {
      'value': 'Patents',
      'label': 'Patents',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Trademarks',
      'label': 'Trademarks',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Investments',
      'label': 'Investments',
      'icon': Icon(Icons.monetization_on_outlined),
    },
  ];
  final List<Map<String, dynamic>> _currentLiabilities = [
    {
      'value': 'Accounts payable',
      'label': 'Accounts payable',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Accrued liabilities',
      'label': 'Accrued liabilities',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Accrued wages',
      'label': 'Accrued wages',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Customer deposits',
      'label': 'Customer deposits',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Current portion of debt payable',
      'label': 'Current portion of debt payable',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Deferred revenue',
      'label': 'Deferred revenue',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Income taxes payable',
      'label': 'Income taxes payable',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Interest payable',
      'label': 'Interest payable',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Payroll taxes payable',
      'label': 'Payroll taxes payable',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Salaries payable',
      'label': 'Salaries payable',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Sales taxes payable',
      'label': 'Sales taxes payable',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Use taxes payable',
      'label': 'Use taxes payable',
      'icon': Icon(Icons.monetization_on_outlined),
    },
    {
      'value': 'Warranty liability',
      'label': 'Warranty liability',
      'icon': Icon(Icons.monetization_on_outlined),
    },
  ];
  final amountFixedAssetController = TextEditingController(),
      titleFixedAssetController = TextEditingController(),
      descFixedAssetController = TextEditingController(),
      cartFixedAssetController = TextEditingController();

      final amountCurrentAssetController = TextEditingController(),
      titleCurrentAssetController = TextEditingController(),
      descCurrentAssetController = TextEditingController(),
      cartCurrentAssetController = TextEditingController();

      final amountLongtermLiabilityController = TextEditingController(),
      titleLongtermLiabilityController = TextEditingController(),
      descLongtermLiabilityController = TextEditingController(),
      cartLongtermLiabilityController = TextEditingController();

      final amountCurrentLiabilityController = TextEditingController(),
      titleCurrentLiabilityController = TextEditingController(),
      descCurrentLiabilityController = TextEditingController(),
      cartCurrentLiabilityController = TextEditingController();
  final marginController = TextEditingController();
  final dateController = TextEditingController();
  final commentController = TextEditingController();
  final planController = TextEditingController();
  Future<void> drawBalanceSheet() async{
    String uid = user?.uid ?? 'uid';
    FirebaseDatabase.instance
        .ref()
        .child('balanceSheet/' + uid + "/fixedAssets")
        .onChildAdded
        .listen((event) {
      Map rev = event.snapshot.value as Map;
      setState(() {
        fixedAssets += double.parse(rev['amount']);
        print("Vagara Varamba");
      });
    });
    FirebaseDatabase.instance
        .ref()
        .child('balanceSheet/' + uid + "/currentLiability")
        .onChildAdded
        .listen((event) {
      Map rev = event.snapshot.value as Map;
      setState(() {
        currentLiabilities += double.parse(rev['amount']);
      });
    });
    FirebaseDatabase.instance
        .ref()
        .child('balanceSheet/' + uid + "/currentAssets")
        .onChildAdded
        .listen((event) {
      Map rev = event.snapshot.value as Map;
      setState(() {
        currentAssets += double.parse(rev['amount']);
        totalAssets=fixedAssets+currentAssets;
        totalLiabilities=longTermLiabilities+currentLiabilities;
      });
    });
    FirebaseDatabase.instance
        .ref()
        .child('balanceSheet/' + uid + "/longtermLiability")
        .onChildAdded
        .listen((event) {
      Map rev = event.snapshot.value as Map;
      setState(() {
        longTermLiabilities += double.parse(rev['amount']);
        totalAssets=fixedAssets+currentAssets;
        totalLiabilities=longTermLiabilities+currentLiabilities;
      });
    });

   // await Future.delayed(Duration(seconds: 1));

  }
  @override
  void initState() {
    super.initState();
      drawBalanceSheet();
    String uid = user?.uid ?? 'uid'; // <-- Their email
    dbRef = FirebaseDatabase.instance.ref().child('balanceSheet' + '/' + uid);

    String mail = user?.email ?? 'email';
    FirebaseDatabase.instance.ref().child('User/').onChildAdded.listen((event) {
      Map user = event.snapshot.value as Map;
      if (user['email'] == mail) {
        setState(() {
          sme = user['sme'];
          UserName = user['fname'];
        });

        print(sme);
      }
    });
    employees = getEmployeeData2();
    employeeDataSource = EmployeeDataSource(employeeData: employees);
  }
  int _selectedIndex = 2;
  // Check if the user is signed in
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
      // only scroll to top when current index is selected.
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignIn()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RevenuePage()));
        break;
      case 2:
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
            alignment: Alignment.bottomCenter,
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ISPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Text('Income Statement')),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BSPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Text('     Balance Sheet   ')),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AdvisoryPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: Text('     $threeQuarterTurn Business Advisory   ')),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ExpensesPage()));
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FundingPage()));
        break;
    }
  }
  double fixedAssets=0,currentAssets=0,currentLiabilities=0,longTermLiabilities=0,totalAssets=0,totalLiabilities=0;

  void getFixedAssetsData() async {
    String uid = user?.uid ?? 'uid';

    Future<void> _showMyDialog() async {
      await Future.delayed(Duration(seconds: 2));
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Add Fixed Asset',
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  SelectFormField(
                    type: SelectFormFieldType.dialog,
                    controller: cartFixedAssetController,
                    //initialValue: _initialValue,
                    icon: Icon(Icons.format_shapes),
                    labelText: 'Select Category',
                    changeIcon: true,
                    dialogTitle: 'Fixed Asset Category',
                    dialogCancelBtn: 'CANCEL',
                    enableSearch: true,
                    dialogSearchHint: 'Search',
                    items: _fixedAssets,
                    onChanged: (val) =>
                        setState(() => _valueChangedfixedAssets = val),
                    validator: (val) {
                      setState(() => _valueToValidatefixedAssets = val ?? '');
                      return null;
                    },
                    onSaved: (val) =>
                        setState(() => _valueSavedfixedAssets = val ?? ''),
                  ),
                  TextField(
                    controller: titleFixedAssetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Title',
                      hintText: 'Enter Title',
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: descFixedAssetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Description',
                      hintText: 'Enter Description',
                    ),
                  ),
                  // const SizedBox(height: 15),
                  // TextField(
                  //   controller: revenueTargetController,
                  //   keyboardType: TextInputType.number,
                  //   decoration: const InputDecoration(
                  //     border: OutlineInputBorder(),
                  //     labelText: 'Revenue Target ',
                  //     hintText: 'Enter Revenue Target',
                  //   ),
                  // ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: amountFixedAssetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Value',
                      hintText: 'Enter Value',
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  Map<String, String> revenue = {
                    'amount': amountFixedAssetController.text,
                    'description': descFixedAssetController.text,
                    'cartegory': cartFixedAssetController.text,
                    'title': titleFixedAssetController.text
                  };

                  dbRef.child('fixedAssets').push().set(revenue);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }


      _showMyDialog();
  }
  void getCurrentAssetsData() async {
    String uid = user?.uid ?? 'uid';

    Future<void> _showMyDialog() async {
      await Future.delayed(Duration(seconds: 2));
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Add Current Asset',
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  SelectFormField(
                    type: SelectFormFieldType.dialog,
                    controller: cartCurrentAssetController,
                    //initialValue: _initialValue,
                    icon: Icon(Icons.format_shapes),
                    labelText: 'Select Category',
                    changeIcon: true,
                    dialogTitle: 'Current Asset Category',
                    dialogCancelBtn: 'CANCEL',
                    enableSearch: true,
                    dialogSearchHint: 'Search',
                    items: _currentAssets,
                    onChanged: (val) =>
                        setState(() => _valueChangedcurrentAssets = val),
                    validator: (val) {
                      setState(() => _valueToValidatecurrentAssets = val ?? '');
                      return null;
                    },
                    onSaved: (val) =>
                        setState(() => _valueSavedcurrentAssets = val ?? ''),
                  ),
                  TextField(
                    controller: titleCurrentAssetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Title',
                      hintText: 'Enter Title',
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: descCurrentAssetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Description',
                      hintText: 'Enter Description',
                    ),
                  ),
                  // const SizedBox(height: 15),
                  // TextField(
                  //   controller: revenueTargetController,
                  //   keyboardType: TextInputType.number,
                  //   decoration: const InputDecoration(
                  //     border: OutlineInputBorder(),
                  //     labelText: 'Revenue Target ',
                  //     hintText: 'Enter Revenue Target',
                  //   ),
                  // ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: amountCurrentAssetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Value',
                      hintText: 'Enter Value',
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  Map<String, String> revenue = {
                    'amount': amountCurrentAssetController.text,
                    'description': descCurrentAssetController.text,
                    'cartegory': cartCurrentAssetController.text,
                    'title': titleCurrentAssetController.text
                  };

                  dbRef.child('currentAssets').push().set(revenue);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }


    _showMyDialog();
  }
  void getCurrentLiabilitiesData() async {
    String uid = user?.uid ?? 'uid';

    Future<void> _showMyDialog() async {
      await Future.delayed(Duration(seconds: 2));
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Add Current Liability',
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  SelectFormField(
                    type: SelectFormFieldType.dialog,
                    controller: cartCurrentLiabilityController,
                    //initialValue: _initialValue,
                    icon: Icon(Icons.format_shapes),
                    labelText: 'Select Category',
                    changeIcon: true,
                    dialogTitle: 'Current Liability Category',
                    dialogCancelBtn: 'CANCEL',
                    enableSearch: true,
                    dialogSearchHint: 'Search',
                    items: _currentLiabilities,
                    onChanged: (val) =>
                        setState(() => _valueChangedcurrentLiabilities = val),
                    validator: (val) {
                      setState(() => _valueToValidatecurrentLiabilities = val ?? '');
                      return null;
                    },
                    onSaved: (val) =>
                        setState(() => _valueSavedcurrentLiabilities = val ?? ''),
                  ),
                  TextField(
                    controller: titleCurrentLiabilityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Title',
                      hintText: 'Enter Title',
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: descCurrentLiabilityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Description',
                      hintText: 'Enter Description',
                    ),
                  ),
                  // const SizedBox(height: 15),
                  // TextField(
                  //   controller: revenueTargetController,
                  //   keyboardType: TextInputType.number,
                  //   decoration: const InputDecoration(
                  //     border: OutlineInputBorder(),
                  //     labelText: 'Revenue Target ',
                  //     hintText: 'Enter Revenue Target',
                  //   ),
                  // ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: amountCurrentLiabilityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Value',
                      hintText: 'Enter Value',
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  Map<String, String> revenue = {
                    'amount': amountCurrentLiabilityController.text,
                    'description': descCurrentLiabilityController.text,
                    'cartegory': cartCurrentLiabilityController.text,
                    'title': titleCurrentLiabilityController.text
                  };

                  dbRef.child('currentLiability').push().set(revenue);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }


    _showMyDialog();
  }
  void getLongtermLiabilitiesData() async {
    String uid = user?.uid ?? 'uid';

    Future<void> _showMyDialog() async {
      await Future.delayed(Duration(seconds: 2));
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Add Longterm Liability',
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  SelectFormField(
                    type: SelectFormFieldType.dialog,
                    controller: cartLongtermLiabilityController,
                    //initialValue: _initialValue,
                    icon: Icon(Icons.format_shapes),
                    labelText: 'Select Category',
                    changeIcon: true,
                    dialogTitle: 'Longterm Liability Category',
                    dialogCancelBtn: 'CANCEL',
                    enableSearch: true,
                    dialogSearchHint: 'Search',
                    items: _longTermLiabilities,
                    onChanged: (val) =>
                        setState(() => _valueChangedlongTermLiabilities = val),
                    validator: (val) {
                      setState(() => _valueToValidatelongTermLiabilities = val ?? '');
                      return null;
                    },
                    onSaved: (val) =>
                        setState(() => _valueSavedlongTermLiabilities = val ?? ''),
                  ),
                  TextField(
                    controller: titleLongtermLiabilityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Title',
                      hintText: 'Enter Title',
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: descLongtermLiabilityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Description',
                      hintText: 'Enter Description',
                    ),
                  ),
                  // const SizedBox(height: 15),
                  // TextField(
                  //   controller: revenueTargetController,
                  //   keyboardType: TextInputType.number,
                  //   decoration: const InputDecoration(
                  //     border: OutlineInputBorder(),
                  //     labelText: 'Revenue Target ',
                  //     hintText: 'Enter Revenue Target',
                  //   ),
                  // ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: amountLongtermLiabilityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Value',
                      hintText: 'Enter Value',
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  Map<String, String> revenue = {
                    'amount': amountLongtermLiabilityController.text,
                    'description': descLongtermLiabilityController.text,
                    'cartegory': cartLongtermLiabilityController.text,
                    'title': titleLongtermLiabilityController.text
                  };

                  dbRef.child('longtermLiability').push().set(revenue);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }


    _showMyDialog();
  }

  Widget balanceSheetRow(desc,desc2,value3,font1,font2,bcl){
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(width: 1.0, color: Colors.white),
     color: bcl),
      child: Row(
        children: [
          Expanded(

            child: Text(desc,
              textAlign: TextAlign.start,
              style:TextStyle(
                fontWeight: font1,

              )
            )
          ),
           Text(desc2,
              textAlign: TextAlign.center,
                style:TextStyle(
                  fontWeight: FontWeight.normal,
                )
            ),
          Expanded(
            child: Text(value3,
              textAlign: TextAlign.end,
                style:TextStyle(
                  fontWeight: font2,
                )
            ),
          ),
        ],
      ),
    );
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
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              customButton: const Icon(
                Icons.menu_rounded,
                size: 46,
                color: Colors.white,
              ),
              customItemsHeights: [
                ...List<double>.filled(MenuItems.firstItems.length, 48),
                8,
                ...List<double>.filled(MenuItems.secondItems.length, 48),
              ],
              items: [
                ...MenuItems.firstItems.map(
                  (item) => DropdownMenuItem<MenuItem>(
                    value: item,
                    child: MenuItems.buildItem(item),
                  ),
                ),
                const DropdownMenuItem<Divider>(
                    enabled: false, child: Divider()),
                ...MenuItems.secondItems.map(
                  (item) => DropdownMenuItem<MenuItem>(
                    value: item,
                    child: MenuItems.buildItem(item),
                  ),
                ),
              ],
              onChanged: (value) {
                MenuItems.onChanged(context, value as MenuItem);
              },
              itemHeight: 48,
              itemPadding: const EdgeInsets.only(left: 16, right: 16),
              dropdownWidth: 160,
              dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.blue,
              ),
              dropdownElevation: 8,
              offset: const Offset(0, 8),
            ),
          ),
        ],
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
          children: <Widget> [
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.blueGrey,
                      child: Column(
                        children: [
                          const Text('Total Assets'),
                           Text("\$$totalAssets"),
                          const Text('0%'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.blueGrey,
                      child: Column(
                        children: [
                          const Text('Total Liabilities'),
                           Text("\$$totalLiabilities"),
                          const Text('0%'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.grey,
                      child: Column(
                        children: [
                          const Text(' Equity'),
                          const Text("\$0.00"),
                          const Text('0%'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        style: TextButton.styleFrom(
                          onSurface: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () {
                          getFixedAssetsData(); // Navigate back to first route when tapped.
                        },
                        child: const Text(
                          '\n+\n\nFixed Asset\n',
                          textAlign: TextAlign.center,
                        )),
                  ),
                  Expanded(
                    child: ElevatedButton(
                        style: TextButton.styleFrom(
                          onSurface: Colors.white,
                          backgroundColor: Colors.lightBlue,
                        ),
                        onPressed: () {
                          getCurrentAssetsData(); // Navigate back to first route when tapped.
                        },
                        child: const Text(
                          '\n+\n\nCurrent Asset\n',
                          textAlign: TextAlign.center,
                        )),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        style: TextButton.styleFrom(
                          onSurface: Colors.white,
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: () {

                          getLongtermLiabilitiesData(); // Navigate back to first route when tapped.
                        },
                        child: const Text(
                          '\n+\n\nLong Term Liability\n',
                          textAlign: TextAlign.center,
                        )),
                  ),
                  Expanded(
                    child: ElevatedButton(
                        style: TextButton.styleFrom(
                          onSurface: Colors.white,
                          backgroundColor: Colors.orangeAccent,
                        ),
                        onPressed: () {

                          getCurrentLiabilitiesData(); // Navigate back to first route when tapped.
                        },
                        child: const Text(
                          '\n+\n\nCurrent Liability\n',
                          textAlign: TextAlign.center,
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height:20),
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              color: Colors.blue,
              child: Column(
                children: [
                  Text(""),
                  Text('$sme: Balance Sheet'),
                  Text(""),
                ],
              ),
            ),
            const SizedBox(height:10),
            //balancesheet rows start
            balanceSheetRow("Assets","","",FontWeight.bold,FontWeight.bold,Colors.grey),
            balanceSheetRow("Fixed Assets","",fixedAssets.toStringAsFixed(2),FontWeight.normal,FontWeight.normal,Colors.lightBlueAccent),
            balanceSheetRow("Current Assets","",currentAssets.toStringAsFixed(2),FontWeight.normal,FontWeight.normal,Colors.grey),
            balanceSheetRow("Total Assets","",totalAssets.toStringAsFixed(2),FontWeight.bold,FontWeight.bold,Colors.lightBlueAccent),
            balanceSheetRow("","","",FontWeight.normal,FontWeight.normal,Colors.grey),
            balanceSheetRow("Liabilities","","",FontWeight.bold,FontWeight.bold,Colors.lightBlueAccent),
            balanceSheetRow("Current Liabilities","",currentLiabilities.toStringAsFixed(2),FontWeight.normal,FontWeight.normal,Colors.grey),
            balanceSheetRow("Long Term Liabilities","",longTermLiabilities.toStringAsFixed(2),FontWeight.normal,FontWeight.normal,Colors.lightBlueAccent),
            balanceSheetRow("Total Liabilities","",totalLiabilities.toStringAsFixed(2),FontWeight.bold,FontWeight.bold,Colors.grey),
            balanceSheetRow("","","",FontWeight.normal,FontWeight.normal,Colors.lightBlueAccent),
            balanceSheetRow("Owners Equity","","",FontWeight.bold,FontWeight.normal,Colors.grey),
            balanceSheetRow("Contributed Capital","","0.00",FontWeight.normal,FontWeight.normal,Colors.lightBlueAccent),
            balanceSheetRow("Retained Profits - YTD","","0.00",FontWeight.normal,FontWeight.normal,Colors.grey),
            balanceSheetRow("Retained Profits - MTD","","0.00",FontWeight.normal,FontWeight.normal,Colors.lightBlueAccent),
            balanceSheetRow("Shareholder Equity","","0.00",FontWeight.bold,FontWeight.bold,Colors.grey),
            balanceSheetRow("","","",FontWeight.normal,FontWeight.normal,Colors.lightBlueAccent),

            ///balncesheet rows end


          // Container(
          //     child: SfDataGrid(
          //       source: employeeDataSource,
          //       columnWidthMode: ColumnWidthMode.fill,
          //       columns: <GridColumn>[
          //         GridColumn(
          //             columnName: 'id',
          //             label: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Text(
          //                   '',
          //                 )
          //               ],
          //             )),
          //         GridColumn(
          //             columnName: 'name',
          //             label: Container(
          //                 padding: EdgeInsets.all(8.0),
          //                 alignment: Alignment.center,
          //                 child: Text(''))),
          //         GridColumn(
          //             columnName: 'designation',
          //             label: Container(
          //                 padding: EdgeInsets.all(8.0),
          //                 alignment: Alignment.center,
          //                 child: Text(
          //                   '',
          //                   overflow: TextOverflow.ellipsis,
          //                 ))),
          //       ],
          //     ),
          //   ),


            //Initialize the chart widget
          ],),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet),
              label: 'Revenue',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money_sharp),
              label: 'Funding',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          unselectedItemColor: Colors.blue,
          onTap: _onItemTapped,
        ),

    );
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
          footer: Footer(
            //this takes the Footer Component which has 4 arguments with one being mandatory ie the child
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignIn()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Icon(Icons.home)),
                      const Text('Home')
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RevenuePage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Icon(Icons.wallet)),
                      const Text('Revenue')
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () => showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => Dialog(
                                  alignment: Alignment.bottomCenter,
                                  backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ElevatedButton(
                                                style: TextButton.styleFrom(
                                                  onSurface: Colors.white,
                                                  backgroundColor: Colors.blue,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ISPage()),
                                                  ); // Navigate back to first route when tapped.
                                                },
                                                child: const Text(
                                                    'Income Statement')),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ElevatedButton(
                                                style: TextButton.styleFrom(
                                                  onSurface: Colors.white,
                                                  backgroundColor: Colors.blue,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            BSPage()),
                                                  ); // Navigate back to first route when tapped.
                                                },
                                                child: const Text(
                                                    'Balance Sheet')),
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
                              ),
                          child: const Icon(Icons.add_circle)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ExpensesPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Icon(Icons.pie_chart)),
                      const Text('Expenses')
                    ],
                  ),
                ),
                Column(
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FundingPage()),
                          ); // Navigate back to first route when tapped.
                        },
                        child: const Icon(Icons.attach_money_sharp)),
                    const Text('Funding')
                  ],
                ),
              ],
            ), //See Description Below for the other arguments of the Footer Component
          ),
          flex: 8),
    );
  }
}

class AdvisoryPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  AdvisoryPage({Key? key}) : super(key: key);
  final User? user = Auth().currentUser;

  @override
  AdvisoryPageState createState() => AdvisoryPageState();
}

class AdvisoryPageState extends State<AdvisoryPage> {
  final User? user = Auth().currentUser;

  int _selectedIndex = 2;
  TextEditingController areaController = new TextEditingController();
  TextEditingController agendaController = new TextEditingController();
  TextEditingController descController = new TextEditingController();
  TextEditingController attendingController = new TextEditingController();



  late DatabaseReference advisory_reference;
  Future<void> _showMyDialog() async {
    String uid = user?.uid ?? 'uid';
    advisory_reference= FirebaseDatabase.instance.ref().child('advisory/' + uid);
    //await Future.delayed(Duration(seconds: 2));
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '  360° Advisory      ',
            textAlign: TextAlign.center,
            style: TextStyle(
                backgroundColor: Colors.blue,
                color:Colors.white,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: areaController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Key Area',
                    hintText: 'Enter Key Area You Need Help',
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: agendaController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Agenda',
                    hintText: 'What is the Agenda',
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: descController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Briefly describe the Agenda.. ',
                    hintText: 'Agenda Description',
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: attendingController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Attending',
                    hintText: 'Who is attending??',
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Select Date & Time'),
              onPressed: () {
                Map<String, String> revenue = {
                  'attending': attendingController.text,
                  'description': descController.text,
                  'agenda': agendaController.text,
                  'area': areaController.text
                };

                advisory_reference.push().set(revenue);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  // Check if the user is signed in
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
      // only scroll to top when current index is selected.
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignIn()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RevenuePage()));
        break;
      case 2:
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
            alignment: Alignment.bottomCenter,
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ISPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Text('Income Statement')),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BSPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: const Text('     Balance Sheet   ')),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            onSurface: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AdvisoryPage()),
                            ); // Navigate back to first route when tapped.
                          },
                          child: Text('     $threeQuarterTurn Business Advisory   ')),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ExpensesPage()));
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FundingPage()));
        break;
    }
  }

  List<_SalesData> data = [];
  List<_SalesData> data2 = [];

  double totalRevenue = 0;
  double averageRevenue = 0;
  double percentageRevenue = 0;
  int countRevenue = 0;
  double budget = 0, dailyRev = 0;

  final amountController = TextEditingController();
  final marginController = TextEditingController();
  final dateController = TextEditingController();
  final commentController = TextEditingController();
  final planController = TextEditingController();
  final Color unselectedItemColor = Colors.blue;
  late Query dbRef;
  late DatabaseReference reference, reference1;
  String currentValue = '0';
  String sme = '';

  getDateValue(date) {
    String uid = user?.uid ?? 'uid';
    FirebaseDatabase.instance
        .ref()
        .child('trackRevenue/' + uid + '/' + actualMonthRef + "/")
        .onChildAdded
        .listen((event) {
      Map rev = event.snapshot.value as Map;
      currentValue = rev['amount'];
      // rev['key'] = event.snapshot.key;
      print(currentValue.toString() + " IS THE AMOUNT CURRENT");
    });

    print(currentValue.toString() + " IS THE AMOUNT CURRENT21");
  }



  Future<void> morningMessage() async {
    String uid = user?.uid ?? 'uid';
    double budget = 0;
    FirebaseDatabase.instance
        .ref()
        .child('budgets/' + uid)
        .onChildAdded
        .listen((event) {
      Map revenue = event.snapshot.value as Map;

      setState(() {
        budget = double.parse(revenue['revenueBudget']) / 30;
      });
    });
    await Future.delayed(Duration(seconds: 1));
    DatabaseReference dbRefe = FirebaseDatabase.instance.ref().child(
        'trackMorningMessage/' + uid + '/' + actualMonthRef + '/' + actualDate);
    DataSnapshot snapshot = await dbRefe.get();

    if (snapshot.value == null) {
      print("Item doesn't exist in the db");
      Map<String, String> cartegories = {
        'Advertising': '0',
      };

      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Rise and shine.'),
          content: Text(
              'New day! New opportunities! Your revenue target for today is \$' +
                  budget.toStringAsFixed(2)),
          actions: <Widget>[
            // TextButton(
            //   onPressed: () =>{ Navigator.pop(context, 'No')},
            //   child: const Text('No'),
            // ),
            TextButton(
              onPressed: () => {
                dbRefe.set(cartegories),
                Navigator.pop(context, 'No'),
              },
              child: const Text('Noted. Thank You.'),
            ),
          ],
        ),
      );
    } else {
      print("Item exists in the db snap $snapshot");
    }

    Timer mytimer = Timer.periodic(Duration(seconds: 1800), (timer) {
      if (snapshot.value == null) {
        print("Item doesn't exist in the db");
        Map<String, String> cartegories = {
          'Advertising': '0',
        };

        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Rise and shine.'),
            content: Text(
                'New day! New opportunities! Your revenue target for today is \$' +
                    budget.toStringAsFixed(2)),
            actions: <Widget>[
              // TextButton(
              //   onPressed: () =>{ Navigator.pop(context, 'No')},
              //   child: const Text('No'),
              // ),
              TextButton(
                onPressed: () => {
                  dbRefe.set(cartegories),
                  Navigator.pop(context, 'No'),
                },
                child: const Text('Noted. Thank You.'),
              ),
            ],
          ),
        );
      } else {
        print("Item exists in the db snap $snapshot");
      }
    });
  }

  @override
  void initState() {
    super.initState();

    String uid = user?.uid ?? 'uid'; // <-- Their email
    String mail = user?.email ?? 'email';

    morningMessage();

    FirebaseDatabase.instance
        .ref()
        .child('budgets/' + uid)
        .onChildAdded
        .listen((event) {
      Map revenue = event.snapshot.value as Map;

      setState(() {
        budget = double.parse(revenue['revenueBudget']);
      });
    });
    FirebaseDatabase.instance
        .ref()
        .child('trackRevenue/' + uid + '/' + actualMonthRef + "/")
        .orderByChild('date').limitToLast(30)
        .onChildAdded
        .listen((event) {
      Map rev = event.snapshot.value as Map;
      setState(() {
        if (rev['date'] == actualDate) {
          dailyRev += double.parse(rev['amount']);
        }

        data2.add(_SalesData(
            rev['date'].substring(0, 2), double.parse(rev['amount'])));
        data.add(_SalesData(rev['date'].substring(0, 2), budget));
      });
    });

    FirebaseDatabase.instance.ref().child('User/').onChildAdded.listen((event) {
      Map user = event.snapshot.value as Map;
      if (user['email'] == mail) {
        setState(() {
          sme = user['sme'];
        });

        print(sme);
      }
    });
    Map? revenueTrack;
    FirebaseDatabase.instance
        .ref()
        .child('trackRevenue/' + uid + '/' + actualMonthRef + "/")
        .onChildAdded
        .listen((event) {
      revenueTrack = event.snapshot.value as Map;
    });

    String getDate = "";
    double dateAmount = 0.0;

    FirebaseDatabase.instance
        .ref()
        .child('Revenue/' + uid)
        .orderByChild("date").limitToLast(30)
        .onChildAdded
        .listen((event) {
      Map revenue = event.snapshot.value as Map;
      countRevenue++;

      setState(() {
        totalRevenue += double.parse(revenue['amount']);
        averageRevenue = totalRevenue / countRevenue;
        percentageRevenue = (averageRevenue / totalRevenue) * 100;

        if (getDate == revenue['date'].substring(0, 2)) {
          getDate = "";
          dateAmount += double.parse(revenue['amount']);
        } else {
          getDate = revenue['date'].substring(0, 2);
          dateAmount += double.parse(revenue['amount']);
        }
      });
      if (getDate != "") {
        // data2.add(_SalesData(getDate, dateAmount));
        // data.add(_SalesData(getDate, budget));
        dateAmount = 0;
      }
    });
    dbRef = FirebaseDatabase.instance.ref().child('Revenue' + '/' + uid);

    reference = FirebaseDatabase.instance.ref().child('Revenue' + '/' + uid);
    reference1 = FirebaseDatabase.instance
        .ref()
        .child('trackRevenue/' + uid + '/' + actualMonthRef + "/");
  }

  Widget listRevenue({required Map revenue}) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SecondRoute(
                    ky: revenue['key'],
                    amount: revenue['amount'],
                    plan: revenue['plan'],
                    comment: revenue['comment'],
                    margin: revenue['margin'],
                    date: revenue['date'])),
          );
          // Add what you want to do on tap
        },
        child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              ]),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$' + revenue['amount'],
                        style: TextStyle(
                          fontSize: 38,
                        ),
                      ),
                    ]),
              ),
            ])));
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
              'United States Dollar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              customButton: const Icon(
                Icons.menu_rounded,
                size: 46,
                color: Colors.white,
              ),
              customItemsHeights: [
                ...List<double>.filled(MenuItems.firstItems.length, 48),
                8,
                ...List<double>.filled(MenuItems.secondItems.length, 48),
              ],
              items: [
                ...MenuItems.firstItems.map(
                      (item) => DropdownMenuItem<MenuItem>(
                    value: item,
                    child: MenuItems.buildItem(item),
                  ),
                ),
                const DropdownMenuItem<Divider>(
                    enabled: false, child: Divider()),
                ...MenuItems.secondItems.map(
                      (item) => DropdownMenuItem<MenuItem>(
                    value: item,
                    child: MenuItems.buildItem(item),
                  ),
                ),
              ],
              onChanged: (value) {
                MenuItems.onChanged(context, value as MenuItem);
              },
              itemHeight: 48,
              itemPadding: const EdgeInsets.only(left: 16, right: 16),
              dropdownWidth: 160,
              dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.blue,
              ),
              dropdownElevation: 8,
              offset: const Offset(0, 8),
            ),
          ),
        ],
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          //Initialize the chart widget
          Container(
            padding: const EdgeInsets.all(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                //border: Border.all(width: 2.0, color: insightColor2),
              ),
              child: Text("Sometimes it’s exhausting growing your small business to become a big business of tomorrow, you need to bounce of key strategic with sharp minds, our pool of small business experts will be there for you to bounce off ideas through our 360° Advisory.\n\n Simply Set A Board Meeting with our team, to get third opinion on our strategic action plan and we will assign our best advisor with deep expertise in the area.",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    style: TextButton.styleFrom(
                      onSurface: Colors.black,
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      _showMyDialog(); // Navigate back to first route when tapped.
                    },
                    child: Row(children:[
                      Icon(Icons.arrow_circle_right_outlined),
                      Text( 'Set A Board Meeting')
                    ])),
              ],
            ),
          ),
          const SizedBox(height:10),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Agenda',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Attachments',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '   Date',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Image.asset('assets/model.png',
            width: 230,
            height:430,
          ),
          const SizedBox(
            height: 30, // <-- SEE HERE
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(

        items: const <BottomNavigationBarItem>[

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Revenue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money_sharp),
            label: 'Funding',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
