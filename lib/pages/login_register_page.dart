import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../auth.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:currency_picker/currency_picker.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;
  bool _isVisible = false;

  void showToast() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerSME = TextEditingController();
  final TextEditingController _controllerFname = TextEditingController();
  final TextEditingController _controllerSname = TextEditingController();
  final TextEditingController _controllerNumber = TextEditingController();
  final countryController = TextEditingController();
  String currency_value = '';

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }
  Future<void> createUserWithEmailAndPassword() async {
    Map<String, String> user = {
      'sme': _controllerSME.text,
      'number': _controllerNumber.text,
      'fname': _controllerFname.text,
      'sname': _controllerSname.text,
      'email': _controllerEmail.text,
      'currency':currency_value,

    };
    try {
      await FirebaseDatabase.instance.ref().child('User'+'/').push().set(user);
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return const Text('Kupfuma');
  }

  Widget _entryField(
      String title,
      TextEditingController controller,
      ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
        filled: true, //<-- SEE HERE
        fillColor: Colors.white,
      ),
      style: const TextStyle(color: Colors.black),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Error ? $errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed:
      isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      child: Text(isLogin ? 'Login' : 'Register'),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
          _isVisible = !_isVisible;
        });
      },
      child: Text(
          isLogin ? 'Need an account? Register' : 'Already have an account? Login',
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      // AppBar(
      //   title: _title(),
      // ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        // decoration: const BoxDecoration(
        //   image: DecorationImage(
        //       image: AssetImage("assets/images/p0.jpg"),
        //       fit: BoxFit.cover),
        // ),
        child:
        SingleChildScrollView(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 40,),
            Image.asset('assets/images/lg.png',
            width: 230,
              height:230,
            ),
            const SizedBox(height: 30,),
            _entryField('Email', _controllerEmail),
            TextField(
              controller: _controllerPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true, //<-- SEE HERE
                fillColor: Colors.white,
              ),
              style: const TextStyle(color: Colors.black),
              obscureText: true,
            ),
            _errorMessage(),
            Visibility(
              visible: _isVisible,
              child: Column(
                children:[
                _entryField('SME Name',_controllerSME),
                  _entryField('First Name',_controllerFname),
                  _entryField('Surname',_controllerSname),
                  _entryField('Phone Number',_controllerNumber),
                  ElevatedButton(
                    onPressed: () {
                      showCurrencyPicker(
                        context: context,
                        showFlag: true,
                        showSearchField: true,
                        showCurrencyName: true,
                        showCurrencyCode: true,
                        onSelect: (Currency currency) {
                          print('Select Currency: ${currency.name}');
                          currency_value=currency.name;
                        },
                        favorite: ['USD'],
                      );
                    },
                    child: const Text('Select Currency'),
                  ),
                ],),
            ),
            _submitButton(),
            _loginOrRegisterButton(),
            Center(
              child: Text('Our support to the African SMEs is geared towards funding SMEs to enable value addition for import substitution, the phase which will unlock Africa\'s growth potential to catch up with the rest of the world.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),),
      ),
    );
  }
}
