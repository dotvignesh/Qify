import 'package:flutter/material.dart';

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Color(0xFF0A0E21),
    ),
      body: Container(
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 250,
            ),
            Center(
              child: Text(
                  'Forgot Password',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextFormField(
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(width: 1,color: Colors.white10),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  icon: Icon(Icons.email, color: Colors.white),
                  //labelText: 'Password',
                  hintText: 'Email',
                  hintStyle: new TextStyle(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(
              height: 40,
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
                  child: Text('Generate OTP'),
                  onPressed: () {
                    //Add forgot pw stuff here
                  },
                )),
          ],
        )
      ),
    );
  }
}