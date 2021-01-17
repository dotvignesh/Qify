import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:qifyadmin/verification_screen.dart';

import 'current_user.dart';
import 'home_screen.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  TextEditingController _addressController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  final Firestore _db = Firestore.instance;
  FirebaseUser _user;

  var _mailController = TextEditingController();
  var _passwordController = TextEditingController();
  var _nameController = TextEditingController();
  var _civilIdController = TextEditingController();
  var _ageController = TextEditingController();
  var _specialityController = TextEditingController();
  final FocusNode _mailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  String errorText;
  String mailErrorText;
  bool isSwitched = false;

  bool validateMail = false;
  bool validatePassword = false;
  bool _loading = false;

  _fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  File _image;
  String _uploadedFileURL;
  String imgUrl;
  var croppedImage;

  Future getImage() async {
    setState(() {
      _loading = true;
    });
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        maxWidth: 512,
        maxHeight: 512,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.deepPurple,
          toolbarTitle: 'Crop Image',
          backgroundColor: Colors.white,
        ),
      );
      setState(() {
        _loading = false;
        _image = croppedImage;
        print('image: $croppedImage');
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future uploadFile(c) async {
    StorageReference storageReference = FirebaseStorage.instance.ref().child(
        'profile/${_mailController.text}');
    StorageUploadTask uploadTask = storageReference.putFile(croppedImage);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) async{
      await signUp(c, fileURL);
      setState(() {
        _uploadedFileURL = fileURL;
        imgUrl = fileURL;

      });
    });
  }

  Future signUp(c, url) async{
    setState(() {
      _loading=true;
    });

    try {

      if (_mailController.text==null || _mailController.text.length < 1) {
        setState(() {
          validateMail=true;
          mailErrorText='Enter a valid e-mail!';
          _loading=false;
        });
      } else if (_passwordController.text==null || _passwordController.text.length < 8) {
        setState(() {
          validatePassword=true;
          validateMail=false;
          errorText='Password should contain at least 8 characters!';
          _loading=false;
        });
      } else {
        setState(() {
          validatePassword=false;
          validateMail=false;
        });

        var user = await _auth.createUserWithEmailAndPassword(email: _mailController.text, password: _passwordController.text);


        setState(() {
          _loading=false;
        });


        if (user != null) {
          _user=await _auth.currentUser();
          await _firestore
              .collection('users')
              .document(_user.uid)
              .setData({
            'uid': _user.uid,
            'displayName': _nameController.text,
            'civilId': _civilIdController.text,
            'age':_ageController.text,
            'phone':_phoneController.text,
            'address':_addressController.text,
            'speciality':_specialityController.text,
            'isDoctor':isSwitched,
            'isVerified':isSwitched?false:null,
            'profile':url,
            'indexList':isSwitched?indexing(_nameController.text):null,
            'specialityIndex':isSwitched?indexing(_specialityController.text):null,
            'timestamp': FieldValue.serverTimestamp(),
          });

          await Provider.of<CurrentUser>(c, listen: false).getCurrentUser();
          Navigator.of(context).popUntil((route) => route.isFirst);
          if (isSwitched) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
              return VerificationScreen(false);
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
        _loading=false;
        errorText='Check your email/password combination!';
        mailErrorText=null;
      });

      print(PlatformException.code);

      switch (PlatformException.code) {
        case "ERROR_INVALID_EMAIL":
          setState(() {
            mailErrorText = "Your email address appears to be malformed.";
            errorText=null;
            validateMail=true;
            validatePassword=false;
          });
          break;
        case "ERROR_EMAIL_ALREADY_IN_USE":
          setState(() {
            mailErrorText = "The email address is already in use by another account.";
            errorText=null;
            validateMail=true;
            validatePassword=false;
          });
          break;
        case "ERROR_USER_DISABLED":
          setState(() {
            mailErrorText = "User with this email has been disabled.";
            errorText=null;
            validateMail=true;
            validatePassword=false;
          });
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          setState(() {
            errorText = "Too many requests. Try again later.";
            mailErrorText=null;
            validateMail=false;
            validatePassword=true;
          });
          break;
        case "ERROR_NETWORK_REQUEST_FAILED":
          setState(() {
            errorText='The internet connection appears to be offline';
            mailErrorText=null;
            validateMail=false;
            validatePassword=true;
          });
          break;
      }


    }

  }

  List indexing(name) {

    List<String> splitList = name.split(" ");
    List<String> indexList=[];
    for (var i=0; i<splitList.length; i++) {
      for(var y=1; y<splitList[i].length + 1; y++) {
        indexList.add(splitList[i].substring(0, y).toLowerCase());
      }
    }

    return indexList;

  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ModalProgressHUD(
        inAsyncCall: _loading,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF0A0E21),
          ),
          backgroundColor: Color(0xFF0A0E21),
          body: Container(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20.0),
              children: <Widget>[
                Text(
                  '  Registration',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Colors.white,
                    fontFamily: 'Notable',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Visibility(
                  visible: isSwitched,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: _image != null
                                ? Image.file(
                              _image,
                              fit: BoxFit.cover,
                            )
                                : Icon(
                              Icons.supervised_user_circle,
                              size: 50,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ),
                      FlatButton(
                        child: Text(
                          'Change profile photo',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        onPressed: () {
                          getImage();
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Patient', style: TextStyle(color: Colors.white),),
                    Switch(
                      value: isSwitched,
                      onChanged: (value) {
                        setState(() {
                          isSwitched = value;
                        });
                      },
                      activeTrackColor: Colors.deepPurpleAccent,
                      activeColor: Colors.deepPurple,
                    ),
                    Text('Doctor', style: TextStyle(color: Colors.white),),
                  ],
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child:  TextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    //controller: passwordController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(width: 1,color: Colors.white10),
                      ),
                      prefixIcon: Icon(Icons.perm_contact_calendar,
                          color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      //labelText: 'Password',
                      hintText: 'Name',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    controller: _ageController,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    //controller: passwordController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(width: 1,color: Colors.white10),
                      ),
                      prefixIcon: Icon(Icons.cake,
                          color: Colors.white),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      //labelText: 'Password',
                      hintText: 'Age',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    controller: _phoneController,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    //controller: passwordController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(width: 1,color: Colors.white10),
                      ),
                      prefixIcon: Icon(Icons.phone,
                          color: Colors.white),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      //labelText: 'Password',
                      hintText: 'Phone Number',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    controller: _addressController,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    //controller: passwordController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(width: 1,color: Colors.white10),
                      ),
                      prefixIcon: Icon(Icons.markunread_mailbox,
                          color: Colors.white),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      //labelText: 'Password',
                      hintText: 'Address',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Visibility(
                  visible: isSwitched,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextField(
                      controller: _specialityController,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      //controller: passwordController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          borderSide: BorderSide(width: 1,color: Colors.white10),
                        ),
                        prefixIcon: Icon(Icons.content_paste,
                            color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        //labelText: 'Password',
                        hintText: 'Speciality',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    controller: _mailController,
                    focusNode: _mailFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    //controller: passwordController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(width: 1,color: Colors.white10),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      prefixIcon: Icon(Icons.email,
                          color: Colors.white),
                      //labelText: 'Password',
                      hintText: 'Email',
                      errorText: validateMail ? mailErrorText : null,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: true,
                    //controller: passwordController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(width: 1,color: Colors.white10),
                      ),
                      prefixIcon: Icon(Icons.lock,
                          color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      //labelText: 'Password',
                      hintText: 'Password',
                      errorText: errorText,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) {
                      signUp(context, null);
                    },
                  ),
                ),
                SizedBox(
                  height: 27,
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
                      child: Text('Register'),
                      onPressed: () async => await isSwitched?uploadFile(context):signUp(context, null),
                    )),
                FlatButton(
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Already have an account? Go back!',
                    style: TextStyle(fontSize: 16),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}