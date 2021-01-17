import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:qifyadmin/admin_screen.dart';
import 'package:qifyadmin/home_screen.dart';
import 'package:qifyadmin/verification_screen.dart';
import 'current_user.dart';
import 'register.dart';
import 'forgot_pw.dart';


class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<LoginPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;
  FirebaseUser _user;

//  String mail;
//  String password;
  String errorText;
  String mailErrorText;
  bool validateMail = false;
  bool validatePassword = false;
  bool _loading = false;

  var _mailController = TextEditingController();
  var _passwordController = TextEditingController();
  final FocusNode _mailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future logIn() async {
    setState(() {
      _loading = true;
    });
    try {
      if (_mailController.text == null || _mailController.text.length < 1) {
        setState(() {
          validateMail = true;
          mailErrorText = 'Enter a valid e-mail!';
          _loading = false;
        });
      } else if (_passwordController.text == null ||
          _passwordController.text.length < 8) {
        setState(() {
          validatePassword = true;
          validateMail = false;
          errorText = 'Enter a valid password!';
          _loading = false;
        });
      } else {
        setState(() {
          validatePassword = false;
          validateMail = false;
        });

        var user = await _auth.signInWithEmailAndPassword(
            email: _mailController.text, password: _passwordController.text);

        setState(() {
          _loading = false;
        });

        if (user != null) {

          _user=await _auth.currentUser();
          bool isDoc = false;
          bool admin = false;
          bool isVerified = false;
          await Firestore.instance
              .collection('users')
              .document(_user.uid)
              .get()
              .then((document) {
            print(document.data['photoUrl']);
            isDoc = document.data['isDoctor'];
            admin = document.data['admin'];
            isVerified = document.data['isVerified'];
          });
          Navigator.of(context).popUntil((route) => route.isFirst);
          await Provider.of<CurrentUser>(context, listen: false)
              .getCurrentUser();
          if (isDoc) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
              return VerificationScreen(isVerified);
            }));
          } else if (admin!=null || admin == true){
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
              return AdminScreen();
            }));
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
              return HomePage();
            }));
          }
        }
      }
    } catch (PlatformException) {
      setState(() {
        _loading = false;
        errorText = 'Check your email/password combination!';
        mailErrorText = null;
      });

      print(PlatformException.code);

      switch (PlatformException.code) {
        case "ERROR_INVALID_EMAIL":
          setState(() {
            mailErrorText = "Your email address appears to be malformed.";
            errorText = null;
            validateMail = true;
            validatePassword = false;
          });
          break;
        case "ERROR_WRONG_PASSWORD":
          setState(() {
            errorText = "Wrong password!";
            mailErrorText = null;
            validateMail = false;
            validatePassword = true;
          });
          break;
        case "ERROR_USER_NOT_FOUND":
          setState(() {
            mailErrorText = "User with this email doesn't exist.";
            errorText = null;
            validateMail = true;
            validatePassword = false;
          });
          break;
        case "ERROR_USER_DISABLED":
          setState(() {
            mailErrorText = "User with this email has been disabled.";
            errorText = null;
            validateMail = true;
            validatePassword = false;
          });
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          setState(() {
            errorText = "Too many requests. Try again later.";
            mailErrorText = null;
            validateMail = false;
            validatePassword = true;
          });
          break;
        case "ERROR_NETWORK_REQUEST_FAILED":
          setState(() {
            errorText = 'The internet connection appears to be offline';
            mailErrorText = null;
            validateMail = false;
            validatePassword = true;
          });
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _loading,
      child: Scaffold(
        backgroundColor: Color(0xFF0A0E21),
        body: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            SizedBox(
              height: 270,
            ),
            Column(
              children: <Widget>[
                Text(
                  'Qify',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 40,
                    fontFamily: 'Notable',
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.supervised_user_circle,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
            SizedBox(
              //width: ,
              height: 20,
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                textInputAction: TextInputAction.next,
                style: TextStyle(
                  color: Colors.white,
                ),
                focusNode: _mailFocus,
                controller: _mailController,
                keyboardType: TextInputType.emailAddress,
                onSubmitted: (value) {
                  _fieldFocusChange(context, _mailFocus, _passwordFocus);
                },
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(width: 1,color: Colors.white12),
                  ),
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  border:
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  fillColor: Colors.white,
                  hintText: 'Email',
                  errorText: validateMail ? mailErrorText : null,
                  hintStyle: new TextStyle(color: Colors.grey),
                  //labelText: 'User Name',
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: new TextField(
                style: TextStyle(
                  color: Colors.white,
                ),
                focusNode: _passwordFocus,
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(width: 1,color: Colors.white10),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  errorText: validatePassword ? errorText : null,
                  //labelText: 'Password',
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock,
                      color: Colors.white),
                  hintStyle: new TextStyle(color: Colors.grey),
                ),
                onSubmitted: (value) => logIn(),
              ),
            ),
            FlatButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecondRoute()),
                );
              },
              textColor: Colors.blue,
              child: Text(
                'Forgot Password',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Container(
                height: 50,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    //side: BorderSide(color: Colors.red)
                  ),
                  textColor: Colors.white,
                  color: Color(0xFF4440D9),
                  child: Text('Login'),
                  onPressed:  () async => await logIn(),
                )),
            Container(
              child: Row(
                children: <Widget>[
                  Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.white,
                        fontSize: 16),
                  ),
                  FlatButton(
                      textColor: Colors.white,
                      child: Text(
                        'Register here',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Register()),
                        );
                      }
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class FirstRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Route'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Open route'),
          onPressed: () {
            // Navigate to second route when tapped.
          },
        ),
      ),
    );
  }
}