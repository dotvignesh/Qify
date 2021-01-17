import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qifyadmin/appointment_tile.dart';
import 'package:qifyadmin/schedule_tile.dart';
import 'package:qifyadmin/view_profile.dart';

import 'current_user.dart';

class PendingRequests extends StatefulWidget {
  final String title;
  final String windowID;
  PendingRequests({this.title, this.windowID});
  @override
  _PendingRequestsState createState() => _PendingRequestsState();
}

class _PendingRequestsState extends State<PendingRequests> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),
        backgroundColor:  Color(0xFF0A0E21),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 10, left: 8, right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('appointments')
                  // .orderBy('date')
                  .where('doctorWindowID', isEqualTo: widget.windowID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data.documents.length == 0) {
                  return Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Text(
                      "We're getting your pending appointment requests ready!",
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
                  final status = window.data['appointmentStatus'];
                  final image = window.data['image'];
                  final uid = window.data['uid'];
                  final docID = window.documentID;

                  print(window.data);

                  bool changeStatus;

                  try {
                    changeStatus = (status=="Approval Pending" || status.substring(0, 9)=="Forwarded")?true:false;
                  } catch (e) {
                    changeStatus=false;
                  }

                  tiles.add(
                    AppointmentTile(
                      userName: name,
                      content: content,
                      postImage: image,
                      status: status,
                      docId: docID,
                      changeStatus: changeStatus,
                      cancelAp: false,
                      onPress: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return ViewProfile(uid: uid, name: name,);
                        }));
                      }
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
      ),
    );
  }
}
