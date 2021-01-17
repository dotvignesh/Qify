import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:time_range_picker/time_range_picker.dart';

import 'current_user.dart';

class AddWindow extends StatefulWidget {
  final String title;
  final String startTime;
  final String endTime;
  final String date;
  final String docId;
  bool editState;
  AddWindow(
      {this.title,
      this.startTime,
      this.endTime,
      this.date,
      this.docId,
      this.editState});
  @override
  _AddWindowState createState() => _AddWindowState();
}

class _AddWindowState extends State<AddWindow> {
  bool inProgress = false;
  String text;
  String imgUrl;
  String startTime = "9";
  String endTime = "9";
  bool alteredTime = false;
  bool alteredDate = false;

  TextEditingController textEditingController;
  String _uploadedFileURL;

  DateTime selectedDate = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020, 7),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
    print((selectedDate.toIso8601String()).substring(0, 10));
  }

  Future pushData() async {
    try {
      if (((textEditingController.text == "" ||
          textEditingController.text == null))) {
        setState(() {
          inProgress = false;
        });
        BotToast.showSimpleNotification(
            title: 'Appointment window title is empty!');
      } else {
        DocumentReference reference =
            await Firestore.instance.collection('windows').add({
          'title': textEditingController.text,
          'startTime': startTime,
          'endTime': endTime,
          'date': (selectedDate.toIso8601String()).substring(0, 10),
          'uid':
              Provider.of<CurrentUser>(context, listen: false).loggedInUser.uid,
          'time': FieldValue.serverTimestamp(),
        });

        textEditingController.clear();
        setState(() {
          inProgress = false;
        });
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
      setState(() {
        inProgress = false;
      });
    }
  }

  Future update() async {
    try {
      if (((textEditingController.text == "" ||
          textEditingController.text == null))) {
        setState(() {
          inProgress = false;
        });
        BotToast.showSimpleNotification(
            title: 'Appointment window title is empty!');
      } else {
        await Firestore.instance
            .collection('windows')
            .document(widget.docId)
            .updateData({
          'title': textEditingController.text,
          'startTime': alteredTime?startTime:widget.startTime,
          'endTime': alteredTime?endTime:widget.endTime,
          'date': alteredDate?(selectedDate.toIso8601String()).substring(0, 10):widget.date,
          'uid':
              Provider.of<CurrentUser>(context, listen: false).loggedInUser.uid,
          'time': FieldValue.serverTimestamp(),
        });

        textEditingController.clear();
        setState(() {
          inProgress = false;
        });
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
      setState(() {
        inProgress = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.editState) {
      textEditingController =
          TextEditingController(text:widget.title);
    } else {
      textEditingController =
          TextEditingController();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editState
            ? 'Edit Appointment Window'
            : 'Add Appointment Window'),
        backgroundColor: Color(0xFF0A0E21),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ModalProgressHUD(
          inAsyncCall: inProgress,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    child: TextField(
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: textEditingController,
                      onChanged: (value) {
                        setState(() {
                          text = value;
                        });
                      },
                      decoration: InputDecoration(
                          hintText: "Appointment Window Title",
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixStyle: TextStyle(color: Color(0xFF0A0E21)),
                          contentPadding: EdgeInsets.only(top: 14.0),
//                        border: OutlineInputBorder(
//                          //borderRadius: BorderRadius.all(Radius.circular(32.0)),
//                        ),
//                        enabledBorder: OutlineInputBorder(
//                          borderSide: BorderSide(color: Color(0xFF0A0E21), width: 1.0),
//                        ),
//                        focusedBorder: OutlineInputBorder(
//                          borderSide: BorderSide(color: Color(0xFF0A0E21), width: 2.0),
//                        ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.access_time,
                              color: Color(0xFF0A0E21),
                            ),
                            onPressed: () async {
                              TimeRange result = await showTimeRangePicker(
                                context: context,
                                start: TimeOfDay(hour: 10, minute: 0),
                                end: TimeOfDay(hour: 10, minute: 15),
                                onStartChange: (start) {
                                  print("${start.hour} ${start.minute}");
                                  startTime = "${start.hour}:${start.minute}";
                                  alteredTime = true;
                                  //print("start time " + start.toString());
                                },
                                onEndChange: (end) {
                                  print(end.hour);
                                  endTime = "${end.hour}:${end.minute}";
                                  alteredTime = true;
                                },
                              );
                              print("result " + result.toString());
                            },
                          )),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13),
                      child: Container(
                        child: FlatButton(
                            color: Color(0xFF0A0E21),
                            child: Row(
                              //mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Pick Date',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () async {
                              alteredDate = true;
                              await _selectDate(context);
                            }),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13),
                      child: Container(
                        child: FlatButton(
                            color: Color(0xFF0A0E21),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.lock_open,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  widget.editState ? 'Update' : 'Set',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () async {
                              setState(() {
                                inProgress = true;
                              });
                              FocusScope.of(context).unfocus();
                              if (widget.editState) {
                                await update();
                              } else {
                                await pushData();
                              }
                            }),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Visibility(
                    visible: widget.editState,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 13),
                        child: Container(
                          child: FlatButton(
                              color: Color(0xFF0A0E21),
                              child: Row(
                                //mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.delete_forever,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Delete Appointment Window',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              onPressed: () async {
                                setState(() {
                                  inProgress=true;
                                });
                                try {
                                  DocumentReference ref = Firestore.instance.document('windows/' + widget.docId);
                                  await Firestore.instance.runTransaction((Transaction myTransaction) async {
                                    await myTransaction.delete(ref);
                                  });
                                } catch (e) {
                                  BotToast.showSimpleNotification(title: 'Something went wrong :(');
                                }

                                setState(() {
                                  inProgress=false;
                                });
                              }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
