import 'package:flutter/material.dart';
import 'package:go_home/classes/message.dart';
import 'package:go_home/classes/property.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiver/async.dart';


class ApprovedServices {
  static const String url = "https://www.gohome.ng/api/on_approved_listener.php?user_id=";

  static getInfo() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List userData = List();
    String isApproved  = preferences.getString("approved");
    // runNotif();

    String userId = preferences.getStringList("user")[0];

    var response = await http.get(
          Uri.encodeFull(url + userId),
          headers: {"Accept": "application/json"});
      userData = json.decode(response.body);
      // List<String> messageData = [userData[0].title, userData[0].message];
    preferences.setString("approved", userData[0]["approved"]);
    String newState = preferences.getString("approved");

    if (isApproved != newState) {
      preferences.setString("isApproved", "false");
      print("Service Props: false");
      // showNotification();

    } else {
      // preferences.setString("isPropCount", "true");
      print("Service Props: true " + userData[0].toString());
    }   
  } 

  static FlutterLocalNotificationsPlugin notificationsPlugin;

  static runNotif(){
    notificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android, iOS);
    notificationsPlugin.initialize(initSettings, onSelectNotification: onSelectNotification);
  }

  static Future onSelectNotification(String payload){
    debugPrint("payload: $payload");
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => Dashboard(
    //       user: user,
    //     ),
    //   ),
    // );
  }


   static showNotification() async{
    var android = new AndroidNotificationDetails("channelId", "channelName", "channelDescription");
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await notificationsPlugin.show(0, "New Notification", "New property has been added", platform);
  }

  static int _startChecker = 10;
  static int _currentChecker = 10;
  static void startChecker() {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: _startChecker),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      // setState(() {
        _currentChecker = _startChecker - duration.elapsed.inSeconds;
      // });
    });

    sub.onDone(() {
      print("Done");
      if (_currentChecker < 1 ){
        getInfo();
        _currentChecker = 10;
        startChecker();
      }
      sub.cancel();
    });
  }
 
}