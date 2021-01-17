import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'current_user.dart';

class BookAppointment extends StatefulWidget {
  final String docId;
  BookAppointment({this.docId});
  @override
  _BookAppointmentState createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  bool inProgress = false;

  String text;
  String imgUrl;
  List groups;
  List groupNames;
  String groupId;
  double minPrice;
  double maxPrice;
  File postImage;
  TextEditingController textEditingController = TextEditingController();
  TextEditingController minPriceController = TextEditingController();
  TextEditingController maxPriceController = TextEditingController();
  TextEditingController titleEditingController = TextEditingController();
  String _uploadedFileURL;

  BottomNavigationBar navigationBar;

  Future uploadFile() async {
    StorageReference storageReference = FirebaseStorage.instance.ref().child(
        'posts/${Provider.of<CurrentUser>(context, listen: false).loggedInUser.uid} ${DateTime.now().toIso8601String()}');
    StorageUploadTask uploadTask = storageReference.putFile(postImage);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) async {
      await pushData(fileURL);
      setState(() {
        _uploadedFileURL = fileURL;
        imgUrl = fileURL;
      });
    });
  }

  Future pushData(url) async {
    try {
      if (((textEditingController.text == "" ||
              textEditingController.text == null) &&
          url == null)) {
        setState(() {
          inProgress = false;
        });
        BotToast.showSimpleNotification(title: 'Nothing to post!');
      } else {
        DocumentReference reference =
            await Firestore.instance.collection('appointments').add({
          'description': textEditingController.text,
          'image': url != null ? url : null,
          'appointmentStatus': 'Approval Pending',
          'uid':
              Provider.of<CurrentUser>(context, listen: false).loggedInUser.uid,
          'name':
              Provider.of<CurrentUser>(context, listen: false).displayName,
          'doctorWindowID': widget.docId,
          'time': FieldValue.serverTimestamp(),
        });

        print(Provider.of<CurrentUser>(context, listen: false).loggedInUser.email);
        http.Response _response = await http
            .get("https://us-central1-qify-931a1.cloudfunctions.net/sendMail?dest=${Provider.of<CurrentUser>(context, listen: false).loggedInUser.email}");

        if (_response.statusCode == 200) {
          print('sent');
        } else {
          print("Something went wrong!");
        }

        postImage = null;
        textEditingController.clear();
        Navigator.pop(context);
        setState(() {
          inProgress = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        inProgress = false;
      });
    }
  }

  File _image;
  var croppedImage;

  Future getImage() async {
    setState(() {
      inProgress = true;
    });
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
        compressQuality: 100,
        maxWidth: 512,
        maxHeight: 512,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: Color(0xFF0A0E21),
          toolbarTitle: 'Crop Image',
          backgroundColor: Colors.white,
        ),
      );
      setState(() {
        inProgress = false;
        _image = croppedImage;
        postImage = _image;
        print('image: $croppedImage');
      });
    } else {
      setState(() {
        inProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Your Appointment'),
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
                    padding: EdgeInsets.symmetric(horizontal: 15),
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
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 15, bottom: 11, top: 11, right: 15),
                        hintText: 'Problem Description',
                      ),
                    ),
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
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.camera,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Pick Image',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () async {
                              await getImage();
                            }),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Visibility(
                          visible: postImage != null ? true : false,
                          child: Stack(
                            children: <Widget>[
                              Container(
                                height: 256,
                                width: 512,
                                child: postImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        child: Image.file(
                                          postImage,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : null,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 6),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        postImage = null;
                                      });
                                    },
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Color(0x00000000),
                                      child: Icon(Icons.close,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Book your appointment',
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

                                  if (postImage != null) {
                                    await uploadFile();
                                  } else {
                                    await pushData(null);
                                  }
                                }),
                          ),
                        ),
                      ),
                    ],
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
