import 'package:flutter/material.dart';

class MessagePill extends StatelessWidget {
  final String msgData;
  final String identity;
  final String timestamp;

  MessagePill({this.msgData, this.identity, this.timestamp});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            msgData,
            style: TextStyle(fontSize: 18),
          ),
          Text(
            identity + "\n " + timestamp,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
