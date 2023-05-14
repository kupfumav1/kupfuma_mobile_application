import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../auth.dart';


import 'package:select_form_field/select_form_field.dart';
import 'package:currency_picker/currency_picker.dart';
//import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
class AuthenticationService {
  final _auth = FirebaseAuth.instance;
//...
}
enum AuthStatus {
  successful,
  wrongPassword,
  emailAlreadyExists,
  invalidEmail,
  weakPassword,
  unknown,
}

class AuthExceptionHandler {
  static handleAuthException(FirebaseAuthException e) {
    AuthStatus status;
    switch (e.code) {
      case "invalid-email":
        status = AuthStatus.invalidEmail;
        break;
      case "wrong-password":
        status = AuthStatus.wrongPassword;
        break;
      case "weak-password":
        status = AuthStatus.weakPassword;
        break;
      case "email-already-in-use":
        status = AuthStatus.emailAlreadyExists;
        break;
      default:
        status = AuthStatus.unknown;
    }
    return status;
  }
  static String generateErrorMessage(error) {
    String errorMessage;
    switch (error) {
      case AuthStatus.invalidEmail:
        errorMessage = "Your email address appears to be malformed.";
        break;
      case AuthStatus.weakPassword:
        errorMessage = "Your password should be at least 6 characters.";
        break;
      case AuthStatus.wrongPassword:
        errorMessage = "Your email or password is wrong.";
        break;
      case AuthStatus.emailAlreadyExists:
        errorMessage =
        "The email address is already in use by another account.";
        break;
      default:
        errorMessage = "An error occured. Please try again later.";
    }
    return errorMessage;
  }
}
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
  final TextEditingController sectorController = TextEditingController();
  final TextEditingController _controllerDesc= TextEditingController();
  final countryController = TextEditingController();
  final List<Map<String, dynamic>> _items = [
    {
      'value': 'Administrative Services',
      'label': 'Administrative Services',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Advertising and Marketing',
      'label': 'Advertising and Marketing',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Aerospace',
      'label': 'Aerospace',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Agriculture',
      'label': 'Agriculture',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Airlines',
      'label': 'Airlines',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Amusement and Recreation',
      'label': 'Amusement and Recreation',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Art and Creatives',
      'label': 'Art and Creatives',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Automobile',
      'label': 'Automobile',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Aquaculture and Fisheries',
      'label': 'Aquaculture and Fisheries',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Beverages and Tobacco',
      'label': 'Beverages and Tobacco',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Business Services',
      'label': 'Business Services',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Clothing and Fashion',
      'label': 'Clothing and Fashion',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Chemicals and Materials',
      'label': 'Chemicals and Materials',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Construction and Infrastructure ',
      'label': 'Construction and Infrastructure ',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Consumer Discretionary',
      'label': 'Consumer Discretionary',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Consumer Services',
      'label': 'Consumer Services',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Consumer Staples',
      'label': 'Consumer Staples',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Cultural Industries',
      'label': 'Cultural Industries',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Education',
      'label': 'Education',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Energy',
      'label': 'Energy',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Entertainment',
      'label': 'Entertainment',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Finance and Banking',
      'label': 'Finance and Banking',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Food',
      'label': 'Food',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Forestry and Timber',
      'label': 'Forestry and Timber',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Funeral Services',
      'label': 'Funeral Services',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Healthcare',
      'label': 'Healthcare',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Heavy Industry',
      'label': 'Heavy Industry',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Hotels and Lodges',
      'label': 'Hotels and Lodges',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Information Technology',
      'label': 'Information Technology',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Insurance',
      'label': 'Insurance',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Law',
      'label': 'Law',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Life Sciences',
      'label': 'Life Sciences',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Manufacturing',
      'label': 'Manufacturing',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Materials',
      'label': 'Materials',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Media and Television',
      'label': 'Media and Television',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Mining and Extraction',
      'label': 'Mining and Extraction',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Professional Services',
      'label': 'Professional Services',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Publishing',
      'label': 'Publishing',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Real Estate',
      'label': 'Real Estate',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Restaurants',
      'label': 'Restaurants',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Retail',
      'label': 'Retail',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Security Services',
      'label': 'Security Services',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Science and Technology',
      'label': 'Science and Technology',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Social Services',
      'label': 'Social Services',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Sports and Fitness',
      'label': 'Sports and Fitness',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Telecommunication',
      'label': 'Telecommunication',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Textiles',
      'label': 'Textiles',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Tourism',
      'label': 'Tourism',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Transportation and Logistics',
      'label': 'Transportation and Logistics',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Utilities',
      'label': 'Utilities',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Waste Management',
      'label': 'Waste Management',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Water',
      'label': 'Water',
      'icon': Icon(Icons.business_sharp),
    },
    {
      'value': 'Wholesale',
      'label': 'Wholesale',
      'icon': Icon(Icons.business_sharp),
    },

  ];
  String currency_value = '';
  String _valueChanged = '';
  String _valueToValidate = '';
  String _valueSaved = '';
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
    Map<String, String> user1 = {
      'sme': _controllerSME.text,
      'number': _controllerNumber.text,
      'fname': _controllerFname.text,
      'sname': _controllerSname.text,
      'email': _controllerEmail.text,
      'desc':_controllerDesc.text,
      'currency':currency_value,
      'sector':sectorController.text,

    };
    String the_name=_controllerFname.text;
    // //// send mail start
    // String message="<html><body>Hi, $the_name<br><br>Welcome to Kupfuma, we will help you build wealth for your small business through our business analytics and flexible funding. <br><br>There is a funding gap of \$300billion across small business in Africa, our analytics will help your small businesses become profitable whilst our flexible funding will reward you with more capital to grow your small business to become a big business. <br><br>We are highly geared towards funding small businesses for down stream value addition to undertake import substitution across Africa, a phase which will help unlock the growth potential for Africa to catch up with the rest of the world. <br><br>Simply doubling down on efforts for small businesses with business analytics and flexible funding, we will easily double Africa’s Gross Domestic Product to help improve living standards across the continent. <br><br>Be part of our journey, to build wealth for your small business. <br><br>Kupfuma | Building wealth<br> <a href='www.kupfuma.com'>www.cKupfuma.com</a><br>Facebook handle and Twitter handle</body></html>";
    // final Email send_email = Email(
    //   body: '$message',
    //   subject: 'Kupfuma Registration',
    //   recipients: [_controllerEmail.text],
    //   isHTML: true,
    // );
    //
    // await FlutterEmailSender.send(send_email);
   // send mail end
    try {

      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      User? user = Auth().currentUser;
      String uid = user?.uid ??' ';
      await FirebaseDatabase.instance.ref().child('User'+'/'+uid).set(user1);
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
  Future<AuthStatus> resetPassword({required String email}) async {
    AuthStatus _status = AuthStatus.successful;
    await Auth()
        .sendPasswordResetEmail(email: email)
        .then((value) => _status = AuthStatus.successful)
        .catchError((e) => _status = AuthExceptionHandler.handleAuthException(e));
    return _status;
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

  Widget _passwordResetButton() {
    return TextButton(
      onPressed: () {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Reset Password'),
            content: _entryField('Email', _controllerEmail),
            actions: <Widget>[

              TextButton(
                onPressed: () => {

                  resetPassword(email:_controllerEmail.text),
                  Navigator.pop(context, 'Submit'),
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        );
      },
      child: Text(
        "Forgot Password",
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
                  TextField(

                    keyboardType: TextInputType.multiline,
                    maxLines: 6,
                    controller: _controllerDesc,
                    decoration: InputDecoration(
                      labelText: 'Business Description [300 Characters]',
                      hintText: '[300 Characters Limit]',
                      filled: true, //<-- SEE HERE
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  _entryField('First Name',_controllerFname),
                  _entryField('Surname',_controllerSname),
                  SelectFormField(
                    type: SelectFormFieldType.dialog,
                    controller: sectorController,
                    //initialValue: _initialValue,
                    icon: Icon(Icons.format_shapes),
                    labelText: 'Sectors',
                    changeIcon: true,
                    dialogTitle: 'Select Sector',
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
            _passwordResetButton(),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SecondRoute()),
                  );
                },
              child: const Text('Terms & Conditions',
                  style: TextStyle(fontStyle: FontStyle.italic)
              ),
            ),
            Center(
              child: Text('Our support to the small business in Africa is to enable value addition for import substitution, the phase which will unlock Africa\’s growth potential to catch up with the rest of the world.',
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


class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kupfuma: Terms & Conditions'),
      ),
        body: SfPdfViewer.asset(
            'assets/terms.pdf'),
    );
  }
}
