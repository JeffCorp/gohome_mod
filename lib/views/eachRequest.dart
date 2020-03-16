import 'package:flutter/material.dart';
import 'package:go_home/components/InspectionView.dart';
import 'package:flutter/material.dart';
import 'package:go_home/login.dart';
import 'package:go_home/views/eachMessage.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quiver/async.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:async/async.dart';

class EachRequest extends StatefulWidget {
  final String title;
  final String propId;

  EachRequest({this.title, this.propId});

  @override
  State<StatefulWidget> createState() =>
      _EachRequestState(title: title, propId: propId);
}

class _EachRequestState extends State<EachRequest> {
  final String title;
  final String propId;

  _EachRequestState({this.title, this.propId});

  Map data;
  List userData;
  static List updatedData;

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  bool isAuth = false;

  Future isAuthValid() async {
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    bool isAuthenticated = shared_User.getBool("isAuth");
    setState(() {
      isAuth = isAuthenticated;
    });
    print("Prop: " + propId);
  }

  getData() async {
    return this._memoizer.runOnce(() async {
      SharedPreferences shared_User = await SharedPreferences.getInstance();
      bool isAuthenticated = shared_User.getBool("isAuth");
      List user = shared_User.getStringList("user");
      setState(() {
        isAuth = isAuthenticated;
      });
      var response;

      if (isAuthenticated) {
        response = await http.get(
            Uri.encodeFull(
                "http://www.gohome.ng/api/get_property_message.php?receiver_id=" +
                    user[0] +
                    "&prop_id=$propId"),
            headers: {"Accept": "application/json"});
        List userData;
        print(userData);
        print("http://www.gohome.ng/api/get_property_message.php?receiver_id=" +
            user[0] +
            "&prop_id=$propId");
        userData = json.decode(response.body);

        // Message messages =Message.fromJson(response.body);

        // userData = [messages.title, messages.body, messages.senderName];

        if (userData.isEmpty) {
          return null;
        } else {
          setState(() {
            updatedData = [for (var i = 0; i < 1; i += 1) userData[i]];
          });

          debugPrint(userData.toString());
          print("userData: " + userData.toString());
          return userData;
        }
      } else {
        print("Not auth");
      }
    });
  }

  int _start = 10;
  int _current = 10;

  void startTimer() {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: _start),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        _current = _start - duration.elapsed.inSeconds;
      });
    });

    sub.onDone(() {
      print("Done");
      sub.cancel();
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    isAuthValid();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Color(0xFF79c942),
          ),
        body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  isAuth
                      ? Container(
                          margin: EdgeInsets.only(top: 20),
                          child: new FutureBuilder(
                            future: getData(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData && _current > 0) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (!snapshot.hasData && _current == 0) {
                                return Column(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(top: 250),
                                      child: Icon(
                                        Icons.priority_high,
                                        size: 40,
                                        color: Colors.red,
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        "You don't have any messages!!!",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    )
                                  ],
                                );
                              } else {
                                var myData = snapshot.data;
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final item = myData[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EachMessage(senderId: item["sender_id"], propId: item["propId"], img1: item["img1"],)
                                          ),
                                        );
                                      },
                                      child: InspectionView(
                                        id: item["id"],
                                        title: item["sender_name"],
                                        requestQuestion: item["propTitle"],
                                        followUp: item["message"],
                                        imagePath: item["img1"],
                                        location: item["location"],
                                        propId: item["propId"],
                                      ),
                                    );
                                  },
                                  itemCount: myData.length,
                                );
                              }
                            },
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.only(top: 200),
                          child: Column(
                            children: <Widget>[
                              Text(
                                "You are not logged in!!!",
                                style: TextStyle(fontSize: 20),
                              ),
                              Container(
                                child: MaterialButton(
                                  child: Text(
                                    "Login",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: Color(0xFF79c942),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Login(),
                                      ),
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
