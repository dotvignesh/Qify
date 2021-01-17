import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:qifyadmin/user_tile.dart';

import 'current_user.dart';
import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {


  bool loading;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<CurrentUser>(context, listen: false).getRequests();
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: Color(0xFF0A0E21),
        actions: <Widget>[
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
          // overflow menu

        ],
      ),

      body: ModalProgressHUD(
        inAsyncCall: loading,
        child: SafeArea(
            child: Consumer<CurrentUser>(
              builder: (context, userData, child) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Doctor Verification Requests',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Helvetica Neue',
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      userData.requests.length == 0
                          ? Text(
                        'No new requests',
                        style: TextStyle(fontSize: 16.5),
                      )
                          : ListView.builder(
                          shrinkWrap: true,
                          //reverse: true,
                          itemCount: userData.requests.length,
                          itemBuilder: (context, index) {
                            return UserTile(
                              userName: userData.requests[index].name,
                              photoUrl: userData.requests[index].photoUrl,
                              request: true,
                              accept: () async {
                                await userData.acceptRequest(
                                    userData.requests[index].uid, index);
                              },
                              decline: () async {
                                await userData.declineRequest(
                                    userData.requests[index].uid, index);
                              },
                            );
                          }),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

    );
  }
}
