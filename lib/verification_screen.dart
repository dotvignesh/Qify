import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:qifyadmin/current_user.dart';

import 'doctor_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class VerificationScreen extends StatefulWidget {
  bool isVerified;
  VerificationScreen(this.isVerified);
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {


  bool loading =  false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.isVerified == true) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
          return DoctorScreen();
        }));
      }
    });

  }


  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      child: Scaffold(
        backgroundColor: Color(0xFF0A0E21),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Waiting for Doctor to be verified.....',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.white,size: 32,),
                  onPressed: () async{
                    setState(() {
                      loading=true;
                    });
                    await Firestore.instance
                        .collection('users')
                        .document(Provider.of<CurrentUser>(context, listen: false).loggedInUser.uid)
                        .get()
                        .then((document) {
                      widget.isVerified = document.data['isVerified'];
                    });
                    if (widget.isVerified) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
                        return DoctorScreen();
                      }));
                    }
                    setState(() {
                      loading=false;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut().then((value) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                            return LoginPage();
                          }));
                    });
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

//class VerificationPage extends StatefulWidget {
//    VerificationPage({Key key}) : super(key: key);
//
//    @override
//    _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
//}
//
//class _MyStatefulWidgetState extends State<VerificationPage> {
//
//
//    @override
//    Widget build(BuildContext context) {
//      return Scaffold(
//        backgroundColor: Color(0xFF0A0E21),
//        appBar: AppBar(
//          title: const Text('',
//            style: TextStyle(
//              color: Colors.white,
//            ),),
//        ),
//        body: Center(
//          child: Text(
//            'Verifying user.....',
//            style: TextStyle(
//              fontWeight: FontWeight.bold,
//              fontSize: 40,
//            ),
//          ),
//        ),
//
//
//      );
//    }
//}
