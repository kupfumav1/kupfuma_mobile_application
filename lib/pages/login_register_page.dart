import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../auth.dart';

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
    return const Text('GetFunds');
  }

  Widget _entryField(
      String title,
      TextEditingController controller,
      ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,

      ),
      style: const TextStyle(color: Colors.white),
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
          color: Colors.white,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/backgr.png"),
              fit: BoxFit.cover),
        ),
        child:
        SingleChildScrollView(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _entryField('email', _controllerEmail),
            _entryField('password', _controllerPassword),
            _errorMessage(),
            Visibility(
              visible: _isVisible,
              child: Column(
                children:[
                _entryField('SME Name',_controllerSME),
                  _entryField('First Name',_controllerFname),
                  _entryField('Surname',_controllerSname),
                  _entryField('Number',_controllerNumber),
                ],),
            ),
            _submitButton(),
            _loginOrRegisterButton(),
          ],
        ),),
      ),
    );
  }
}
