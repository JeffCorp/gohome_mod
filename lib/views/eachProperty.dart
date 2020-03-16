import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:go_home/views/nearbyPlaces.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:network/network.dart' as network;
import 'package:http/http.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:share/share.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../views/testMap.dart';

import '../components/propertyList.dart';

import '../views/makeRequest.dart';
import '../classes/property.dart';
import '../classes/success.dart';
import '../views/testMap.dart';

class EachProperty extends StatefulWidget {
  final Property item;
  EachProperty({this.item});

  @override
  State<StatefulWidget> createState() => _EachPropertyState(item: item);
}

class _EachPropertyState extends State<EachProperty> {
  // GoogleMapController mapController;

  // final LatLng _center = const LatLng(45.521563, -122.677433);

  // void _onMapCreated(GoogleMapController controller) {
  //   mapController = controller;
  // }

  final Property item;

  _EachPropertyState({this.item});

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  sendMessage() async {
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    var user = shared_User.getStringList('user');
    debugPrint(user.toString());
    debugPrint(user[2]);
    String senderId = user[0].toString();

    String receiverId = item.user_id;

    String body;

    String title = "Request to view property";
    String name = nameController.text;
    String email = emailController.text;
    String phone = phoneController.text;
    String message = messageController.text;

    if (title.length > 0 && message.length > 0) {
      setState(() {
        // isLoading = true;
      });

      // set up POST request arguments
      String url = 'https://www.gohome.ng/send_message.php';
      Map<String, String> headers = {"Content-type": "application/json"};
      String json =
          '{"sender_id" : "${senderId}", "receiver_id" : "${receiverId}", "name" : "${name}", "email" : "${email}", "phone_no" : "${phone}", "title" : "${title}", "message" : "${message}", "propId" : "${item.prop_id}", "sender" : ${senderId} }';

      print(json);
      // make POST request
      Response response = await post(url, headers: headers, body: json);
      // check the status code for the result
      int statusCode = response.statusCode;
      // this API passes back the id of the new item added to the body
      body = response.body;

      Success success = Success.fromJson(jsonDecode(body));
      if (success.status == "OK") {
        debugPrint(success.message);
        Map decode_options = jsonDecode(body);
        // String userData = user.email;
        // shared_Success.setString('user', userData);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => Dashboard(),
        //   ),
        // );
        setState(() {
          nameController.text = "";
          emailController.text = "";
          phoneController.text = "";
          messageController.text = "";
        });
        showSimpleCustomDialog(context, "Success",
            "Request has been sent successfully", "assets/success.gif");
      }
      // debugPrint(user.toString());
    } else {
      showSimpleCustomDialog(context, "Error",
          "Request could not be sent at this time", "assets/error.gif");
      print("error");
    }
  }

  FlutterMoneyFormatter fAmount;
  String imgToDisplay;

  String textFav;
  String a;
  double _width;
  Color _color;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    item.amount.length < 1 ? a = "0" : a = item.amount;
    fAmount = FlutterMoneyFormatter(amount: double.parse(a));
    imgToDisplay = item.img1;
    textFav = "Add to Favourites";
    _width = 150;
    _color = Color(0xFF79c942);
  }

  _addToFavorites() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List user = preferences.getStringList("user");
    String body;

    String url = "https://www.gohome.ng/api/send_to_favs_api.php";

    Map<String, String> headers = {"Content-type": "application/json"};
    var s = '{"user_id": "${user[1]}", "propId": "${item.prop_id}"}';
    String json = s;

    // make POST request
    Response response = await post(url, headers: headers, body: json);

    // check the status code for the result

    int statusCode = response.statusCode;
    // this API passes back the id of the new item added to the body
    body = response.body;

    print(body);

    if (body.isNotEmpty) {
      Fluttertoast.showToast(
          msg: "Added to favorites",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    setState(() {
      textFav = "Added to Favorites";
      _width = 170.0;
      _color = Colors.red;
    });
  }

  void showSimpleCustomDialog(BuildContext context, String messageHead,
      String messageBody, String dialogType) {
    Dialog simpleDialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        height: 300.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      dialogType,
                      height: 100,
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      child: Text(
                        messageBody,
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Color(0xFF79c942), fontSize: 20),
                      ),
                    ),
                  ],
                )),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Center(
                    child: MaterialButton(
                      elevation: 0,
                      color: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Ok!',
                        style:
                            TextStyle(fontSize: 18.0, color: Color(0xFF79c942)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            item.title.length > 20 ? item.title.substring(0, 20) : item.title),
        backgroundColor: Color(0xFF79c942),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.white,
            ),
            onPressed: () {
              Share.share(
                  "https://www.gohome.ng/property-details.php?prop=${item.prop_id}");
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        // child: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.4,
              child: FadeInImage.assetNetwork(
                image: "http://gohome.ng/assets/upload/" +
                    item.prop_id +
                    "/" +
                    imgToDisplay,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: "assets/property_location.jpg",
              ),
            ),
            Container(
              height: 100,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          imgToDisplay = item.img1;
                        });
                      },
                      child: Container(
                        height: 100,
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              child: Image(
                                image: NetworkImage(
                                    "http://gohome.ng/assets/upload/" +
                                        item.prop_id +
                                        "/" +
                                        item.img1),
                                width: MediaQuery.of(context).size.width * 0.25,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          imgToDisplay = item.img2;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Image(
                              image: NetworkImage(
                                  "http://gohome.ng/assets/upload/" +
                                      item.prop_id +
                                      "/" +
                                      item.img2),
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          imgToDisplay = item.img3;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Image(
                              image: NetworkImage(
                                  "http://gohome.ng/assets/upload/" +
                                      item.prop_id +
                                      "/" +
                                      item.img3),
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          imgToDisplay = item.img4;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Image(
                              image: NetworkImage(
                                  "http://gohome.ng/assets/upload/" +
                                      item.prop_id +
                                      "/" +
                                      item.img4),
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          imgToDisplay = item.img5;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Image(
                              image: NetworkImage(
                                  "http://gohome.ng/assets/upload/" +
                                      item.prop_id +
                                      "/" +
                                      item.img5),
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          imgToDisplay = item.img6;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Image(
                              image: NetworkImage(
                                  "http://gohome.ng/assets/upload/" +
                                      item.prop_id +
                                      "/" +
                                      item.img6),
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          imgToDisplay = item.img7;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Image(
                              image: NetworkImage(
                                  "http://gohome.ng/assets/upload/" +
                                      item.prop_id +
                                      "/" +
                                      item.img7),
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          imgToDisplay = item.img8;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Image(
                              image: NetworkImage(
                                  "http://gohome.ng/assets/upload/" +
                                      item.prop_id +
                                      "/" +
                                      item.img8),
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          imgToDisplay = item.img9;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Image(
                              image: NetworkImage(
                                  "http://gohome.ng/assets/upload/" +
                                      item.prop_id +
                                      "/" +
                                      item.img9),
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          imgToDisplay = item.img10;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Image(
                              image: NetworkImage(
                                  "http://gohome.ng/assets/upload/" +
                                      item.prop_id +
                                      "/" +
                                      item.img10),
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          imgToDisplay = item.img12;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Image(
                              image: NetworkImage(
                                  "http://gohome.ng/assets/upload/" +
                                      item.prop_id +
                                      "/" +
                                      item.img12),
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          imgToDisplay = item.img13;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Image(
                              image: NetworkImage(
                                  "http://gohome.ng/assets/upload/" +
                                      item.prop_id +
                                      "/" +
                                      item.img13),
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          imgToDisplay = item.img14;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Image(
                              image: NetworkImage(
                                  "http://gohome.ng/assets/upload/" +
                                      item.prop_id +
                                      "/" +
                                      item.img14),
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          imgToDisplay = item.img15;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Image(
                              image: NetworkImage(
                                  "http://gohome.ng/assets/upload/" +
                                      item.prop_id +
                                      "/" +
                                      item.img15),
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            !item.isFav
                ? GestureDetector(
                    onTap: _addToFavorites,
                    child: Container(
                      alignment: Alignment.bottomRight,
                      width: _width,
                      child: Card(
                        color: _color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.favorite,
                                color: Colors.white,
                              ),
                              Text(
                                textFav,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(3),
                        ),
                      ),
                    ),
                  )
                : Container(
                    alignment: Alignment.bottomRight,
                    width: 170,
                    child: Card(
                      color: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Container(
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.favorite,
                              color: Colors.white,
                            ),
                            Text(
                              "Added to Favourites",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(3),
                      ),
                    ),
                  ),

            Container(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      item.title,
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    child: Text(
                      "\u20A6 " + fAmount.output.nonSymbol + "/year",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF79c942),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Description",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 20),
              ),
            ),
            Container(
                padding: EdgeInsets.all(10), child: Text(item.description)),
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.call,
                        color: Color(0xFF79c942),
                      ),
                      Text(item.phone),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.mail,
                        color: Color(0xFF79c942),
                      ),
                      Text(" " + item.user_email),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: <Widget>[
                            Text(
                              "Make a request",
                              style: TextStyle(fontSize: 20),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              child: TextFormField(
                                controller: nameController,
                                decoration:
                                    InputDecoration(hintText: 'Username'),
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.only(top: 10, bottom: 10),
                                child: TextFormField(
                                  controller: emailController,
                                  decoration:
                                      InputDecoration(hintText: 'Email'),
                                )),
                            Container(
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              child: TextFormField(
                                controller: phoneController,
                                decoration:
                                    InputDecoration(hintText: 'Phone Number'),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20, bottom: 20),
                              child: TextField(
                                controller: messageController,
                                maxLines: 8,
                                decoration: InputDecoration(
                                    hintText: "Enter your text here"),
                              ),
                            ),
                            MaterialButton(
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                              onPressed: () {
                                sendMessage();
                              },
                              color: Color(0xFF79c942),
                            ),
                            // MaterialButton(
                            //   padding: EdgeInsets.all(15),
                            //   shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.all(
                            //       Radius.circular(20),
                            //     ),
                            //   ),
                            //   child: Text(
                            //     "Send",
                            //     style: TextStyle(color: Colors.white),
                            //   ),
                            //   onPressed: null,
                            //   color: Color(0xFF79c942),
                            // )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // //Map goes here
            // Container(
            //   child: GoogleMap(
            //     onMapCreated: _onMapCreated,
            //     initialCameraPosition: CameraPosition(
            //       target: _center,
            //       zoom: 11.0,
            //     ),
            //   ),
            // ),
            Container(
              child: Text("Nearby areas"),
              margin: EdgeInsets.only(bottom: 10),
            ),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NearbyPlaces(),
                            ),
                          );
                        },
                        child: Column(
                          children: <Widget>[
                            Image(
                              image: AssetImage("assets/property_location.jpg"),
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                            Text("Property location")
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Image(
                            image: AssetImage("assets/gym.png"),
                            width: MediaQuery.of(context).size.width * 0.25,
                          ),
                          Text("Gym")
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Image(
                            image: AssetImage("assets/school.png"),
                            width: MediaQuery.of(context).size.width * 0.25,
                          ),
                          Text("School")
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Image(
                            image: AssetImage("assets/hospital.png"),
                            width: MediaQuery.of(context).size.width * 0.25,
                          ),
                          Text("Hospitals")
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Image(
                            image: AssetImage("assets/eatery.png"),
                            width: MediaQuery.of(context).size.width * 0.25,
                          ),
                          Text("Eatery")
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Image(
                            image: AssetImage("assets/hotel.png"),
                            width: MediaQuery.of(context).size.width * 0.25,
                          ),
                          Text("Hotel")
                        ],
                      ),
                    )
                  ],
                ))
          ],
        ),
      ),
      // ),
    );
  }
}
