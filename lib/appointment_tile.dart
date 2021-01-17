import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qifyadmin/forward_screen.dart';

class AppointmentTile extends StatefulWidget {
  final String userName;
  final String content;
  final String postImage;
  final String docId;
  final String uid;
  final int index;
  final String status;
  final bool changeStatus;
  final bool cancelAp;
  Function onPress;

  AppointmentTile({
    this.userName,
    this.content,
    //this.location,
    this.postImage,
    this.docId,
    this.uid,
    this.index,
    this.status,
    this.changeStatus,
    this.cancelAp,
    this.onPress,
  });

  @override
  _AppointmentTileState createState() => _AppointmentTileState();
}

class _AppointmentTileState extends State<AppointmentTile> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPress,
      child: Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Patient Name: ${widget.userName}',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.1),
                  ),
                  Text(
                    widget.status!="Done"?'Status: ${widget.status}':"",
                    style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 0.1,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Visibility(
                visible: widget.content != null ? true : false,
                child: Text(
                  '${widget.content}',
                  style: TextStyle(
                    fontSize: 17,
                    letterSpacing: 0.15,
                    height: 1.3,
                  ),
                ),
              ),
              Visibility(
                visible: (widget.postImage != null) ? true : false,
                child: SizedBox(
                  height: 10,
                ),
              ),
              Visibility(
                visible: (widget.postImage != null) ? true : false,
                child: Container(
                  height: 256,
                  width: 512,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Image.network(
                      '${widget.postImage}',
                      fit: BoxFit.cover,
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              SizedBox(height: 4,),
              Visibility(
                visible: widget.changeStatus,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.green,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.check, color: Colors.white,),
                          Text('Approve', style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      onPressed: () async {

                          DocumentReference doctorRef = Firestore.instance.document('appointments/' + widget.docId);

                          await Firestore.instance.runTransaction((transaction) async {
                            DocumentSnapshot freshSnap1 = await transaction.get(doctorRef);

                            await transaction.update(freshSnap1.reference, {
                              'appointmentStatus': 'Approved',
                            });
                          });

                      },
                    ),
                    RaisedButton(
                      color: Colors.red,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.close, color: Colors.white,),
                          Text('Reject', style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      onPressed: () async {

                        DocumentReference doctorRef = Firestore.instance.document('appointments/' + widget.docId);

                        await Firestore.instance.runTransaction((transaction) async {
                          DocumentSnapshot freshSnap1 = await transaction.get(doctorRef);

                          await transaction.update(freshSnap1.reference, {
                            'appointmentStatus': 'Rejected',
                          });
                        });

                      },
                    ),
                    RaisedButton(
                      color: Colors.orange,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.send, color: Colors.white,),
                          Text('Forward', style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return ForwardScreen(docID: widget.docId,);
                            }
                        ));
                      },
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: widget.cancelAp,
                child: RaisedButton(
                  color: Colors.red,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.close, color: Colors.white,),
                      Text('Cancel', style: TextStyle(color: Colors.white),),
                    ],
                  ),
                  onPressed: () async {

                    try {
                      DocumentReference ref = Firestore.instance.document('appointments/' + widget.docId);
                      await Firestore.instance.runTransaction((Transaction myTransaction) async {
                        await myTransaction.delete(ref);
                      });
                    } catch (e) {
                      BotToast.showSimpleNotification(title: 'Something went wrong :(');
                    }

                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 0.5,
                color: Colors.black26,
              ),
              SizedBox(height: 12,),
            ],
          ),
        ),
      ),
    );
  }
}
