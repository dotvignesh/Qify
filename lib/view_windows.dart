import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qifyadmin/book_appointment.dart';
import 'package:qifyadmin/schedule_tile.dart';

import 'current_user.dart';

class ViewWindows extends StatefulWidget {
  final uid;
  final name;
  ViewWindows({this.name, this.uid});
  @override
  _ViewWindowsState createState() => _ViewWindowsState();
}

class _ViewWindowsState extends State<ViewWindows> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.name}'s available windows"),
        backgroundColor: Color(0xFF0A0E21),
      ),
      body: SafeArea(
        child: Consumer<CurrentUser>(
          builder: (context, userData, child) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Available Appointment Windows',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Helvetica Neue',
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection('windows')
                        // .orderBy('date')
                        .where('uid', isEqualTo: widget.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.data.documents.length == 0) {
                        return Padding(
                          padding: EdgeInsets.only(top: 15),
                          child: Text(
                            "We're getting your scheduled appointment windows ready!",
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }
                      final windows = snapshot.data.documents;
                      List<ScheduleTile> tiles = [];
                      for (var window in windows) {
                        final title = window.data['title'];
                        final startTime = window.data['startTime'];
                        final endTime = window.data['endTime'];
                        final date = window.data['date'];
                        final docID = window.documentID;

                        print(window.data);

                        tiles.add(
                          ScheduleTile(
                            title: title,
                            startTime: startTime,
                            endTime: endTime,
                            date: date,
                            docId: docID,
                            onPress: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return BookAppointment(
                                  docId: docID,
                                );
                              }));
                            },
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
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
