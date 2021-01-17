import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qifyadmin/user.dart';

class CurrentUser extends ChangeNotifier {
  FirebaseUser loggedInUser;
  FirebaseAuth auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;

  String displayName;
  String photoUrl;
  String phoneNumber;
  String address;
  bool isDoctor;
  
  List<User> requests = [];


  Future getCurrentUser() async {
    try {
      var user = await auth.currentUser();

      if (user != null) {
        loggedInUser = user;
        displayName = loggedInUser.displayName;
        await getInfo();
      }
    } catch (e) {
      print(e);
    }
  }

  Future getInfo({bool update}) async {
      print('updating..');
      displayName = loggedInUser.displayName;
      await firestore
          .collection('users')
          .document(loggedInUser.uid)
          .get()
          .then((document) {
        print(document.data['photoUrl']);
        displayName = document.data['displayName'];
        photoUrl = document.data['photoUrl'];
        isDoctor = document.data['isDoctor'];
        phoneNumber = document.data['number'];
        address = document.data['address'];
        print(displayName);
        notifyListeners();
      });
  }



//  Future getUsersInfo(String uid) async {
//    Map doc;
//    await firestore.collection('users').document('$uid').get().then((document) {
//      String url = document['photoUrl'];
//      String name = document['displayName'];
//      bool isPandit = document['isPandit'];
//      doc = {'photoUrl': url, 'displayName': name, 'isPandit': isPandit};
//    });
//    return doc;
//  }
//
//  Future getUserInfo(String uid) async {
//    Map doc;
//    await firestore.collection('users').document('$uid').get().then((document) {
//      int numConn = document['numConn'];
//      doc = {'numConn': numConn};
//    });
//    return doc;
//  }

  Future getRequests() async {
      requests.clear();
      await firestore
          .collection('users')
          .where('isVerified', isEqualTo: false).getDocuments()
          .then((document) async {
        List<DocumentSnapshot> incomingRequests = document.documents;
        for (var request in incomingRequests) {
          print(request.data);
          requests.add(User(
            name: request.data['displayName'],
            photoUrl: request.data['profile'],
            uid: request.data['uid'],
            isDoctor: request.data['isDoctor'],
          ));
        }
      });

      notifyListeners();
  }

  Future acceptRequest(uid, index) async {
    DocumentReference doctorRef = Firestore.instance.document('users/' + uid);

    var val = ['$uid'];
    await firestore.runTransaction((transaction) async {
      DocumentSnapshot freshSnap1 = await transaction.get(doctorRef);

      await transaction.update(freshSnap1.reference, {
        'isVerified': true,
      });
    });

    requests.removeAt(index);
    notifyListeners();
  }

  Future declineRequest(uid, index) async {
    DocumentReference doctorRef = Firestore.instance.document('users/' + uid);

    var val = ['$uid'];
    await firestore.runTransaction((transaction) async {
      DocumentSnapshot freshSnap1 = await transaction.get(doctorRef);

      await transaction.update(freshSnap1.reference, {
        'isVerified': null,
      });
    });

    requests.removeAt(index);
    notifyListeners();
  }


}
