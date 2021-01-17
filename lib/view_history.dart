import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qifyadmin/appointment_tile.dart';
import 'package:qifyadmin/schedule_tile.dart';

import 'current_user.dart';

class ViewHistory extends StatefulWidget {
  final String title;
  final String windowID;
  ViewHistory({this.title, this.windowID});
  @override
  _ViewHistoryState createState() => _ViewHistoryState();
}

class _ViewHistoryState extends State<ViewHistory> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 10, left: 8, right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Appointments History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A0E21),
                fontFamily: 'Helvetica Neue',
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('appointments')
              // .orderBy('date')
                  .where('uid', isEqualTo: Provider.of<CurrentUser>(context, listen: false).loggedInUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data.documents.length == 0) {
                  return Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Text(
                      "We're getting your pending appointment history ready!",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }
                final windows = snapshot.data.documents;
                List<AppointmentTile> tiles = [];
                for (var window in windows) {
                  final name = window.data['name'];
                  final content = window.data['description'];
                  final windowID = window.data['doctorWindowID'];
                  String status = window.data['appointmentStatus'];
                  final image = window.data['image'];
                  final docID = window.documentID;

                  print(window.data);

                  bool cancelAp;
                  try {
                    cancelAp = (status=="Approval Pending" || status.substring(0, 9)=="Forwarded")?true:false;
                  } catch (e) {
                    cancelAp=false;
                  }

                  tiles.add(
                    AppointmentTile(
                      userName: name,
                      content: content,
                      postImage: image,
                      status: status,
                      docId: docID,
                      changeStatus: false,
                      cancelAp: cancelAp,
                    ),
                  );
                }
                return Expanded(
                  child: tiles.length != 0
                      ? ListView(
                    children: tiles,
                  )
                      : Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text('No appointment windows found'),
                  ),
                );
              },
            ),
          ],
        ),
      );
  }
}
