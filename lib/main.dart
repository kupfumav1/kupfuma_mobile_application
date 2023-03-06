import 'package:get_funds_v1/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';

final List<List<String>> imgList = [
  ['assets/images/Tatenda.jpg','We offer data driven\n funding for your small\n to medium business,\n no collateral, 0% interest'],
  ['assets/images/p2.jpg','We offer data driven funding\n for your small to\n medium business, no collateral'],
  ['assets/images/p3.jpg','Our data analytics will\n help you double your sales.\n Take action plans\n and double your sales'],
  ['assets/images/p4.jpg','We are transforming\n small to medium businesses\n into High Growth Businesses'],
  ];
final int imgNum=Random().nextInt(4);
final int contentNum=Random().nextInt(4);
@override
void initState() {

}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomeScreen(),
      //const WidgetTree()
    );
  }
}
class SignIn extends StatelessWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
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
class Expenses extends StatelessWidget {
  const Expenses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container()
      //
    );
  }
}
class WelcomeScreen extends StatelessWidget{
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Widget hrLine = const Padding(
      padding: EdgeInsets.all(32),
      child: Text(
        'Welcome',
        softWrap: true,
      ),
    );


    return Scaffold(
      body: Center(
        child:Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration:  BoxDecoration(
          image: DecorationImage(
              image: AssetImage(imgList[imgNum][0]),
              fit: BoxFit.cover),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 170, // <-- SEE HERE
            ),
            Text(
              imgList[imgNum][1],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                backgroundColor: Color.fromRGBO(0,0, 0, 0.5)
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 20),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignIn()),
                );// Navigate back to first route when tapped.
              },
              child: Text('Welcome',
                style: new TextStyle(
                  fontSize: 20.0,
                ),
              ),


            ),
            SizedBox(
              height: 150, // <-- SEE HERE
            ),
            const Divider(
              height: 20,
              thickness: 5,
              indent: 70,
              endIndent: 70,
              color: Colors.white,

            ),
            const Text(
              'Africa',
              style: TextStyle(
                color: Colors.white,
                  fontWeight: FontWeight.bold,
                fontSize: 18,
                  backgroundColor: Color.fromRGBO(0,0, 0, 0.5)
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 20),

            ),
            Image.asset(
              'assets/images/lg.png',
              width: 150,
              height: 100,
              fit: BoxFit.cover,

            ),

          ],
      ),
      ),
    ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignIn()),
            );// Navigate back to first route when tapped.
          },
          child: const Text('Welcome'),
        ),
      ),
    );
  }
}