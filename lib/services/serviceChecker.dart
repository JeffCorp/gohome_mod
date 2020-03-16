import 'package:flutter/material.dart';
import 'package:go_home/classes/message.dart';
import 'package:go_home/classes/property.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiver/async.dart';


class MessageListener {



  static const String url = "https://www.gohome.ng/api/services_api.php";

  static getInfo() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List userData = List();
    int prevLength  = preferences.getInt("newCount");
    // runNotif();

    var response = await http.get(
          Uri.encodeFull(url),
          headers: {"Accept": "application/json"});
      userData = json.decode(response.body);
      // List<String> messageData = [userData[0].title, userData[0].message];
    preferences.setInt("newCount", userData[0]["count"]);
    preferences.setStringList("channel", [userData[0]["sender_id"], userData[0]["receiver_id"]]);
    int newcount =preferences.getInt("newCount");

    if (prevLength != newcount) {
      preferences.setString("isSame", "false");
      print("Service: false");
      // showNotification();

    } else {
      preferences.setString("isSame", "true");
      print("Service: true");
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


  //  static showNotification() async{
  //   var android = new AndroidNotificationDetails("channelId", "channelName", "channelDescription");
  //   var iOS = new IOSNotificationDetails();
  //   var platform = new NotificationDetails(android, iOS);
  //   await notificationsPlugin.show(0, "New message", "Message from Jane Doe", platform);
  // }

  static int _startChecker = 5;
  static int _currentChecker = 5;
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
        _currentChecker = 5;
        startChecker();
      }
      sub.cancel();
    });
  }
 
}