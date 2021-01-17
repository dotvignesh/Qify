import 'package:flutter/material.dart';

class ScheduleTile extends StatelessWidget {
  final String title;
  final String startTime;
  final String endTime;
  final String date;
  final String docId;
  Function onLongPress;
  Function onPress;

  ScheduleTile({this.title, this.startTime, this.endTime, this.date, this.docId, this.onLongPress, this.onPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onPress,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$title',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 4,),
            Row(
              children: <Widget>[
                Text(
                  'From ',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
                Text(
                  '$startTime',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.pink,
                  ),
                ),
                Text(
                  ' to ',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
                Text(
                  '$endTime',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4,),
            Text(
              'On $date',
              style: TextStyle(
                fontSize: 16,
                color: Colors.pink,
              ),
            ),
            SizedBox(height: 5,),
            Container(
              height: 0.5,
              color: Colors.black26,
            ),
            SizedBox(height: 12,),
          ],
      ),
    );
  }
}
