import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'package:fluttertoast/fluttertoast.dart';

import './pills.dart';

class PropertyList extends StatefulWidget {
final String id;
final String amount;
final String location;
final String propId;
final String state;
final String region;
final String imagePath;
final String saleOrRent;
final String title;
final String phone;
final String name;
final String email;
final Widget goto;
final bool isFav;

  const PropertyList({Key key, this.id, this.amount, this.location, this.propId, this.state, this.region, this.imagePath, this.saleOrRent, this.title, this.phone, this.name, this.email, this.goto, this.isFav}) : super(key: key);
  @override
  _PropertyListState createState() => _PropertyListState(this.id, this.amount, this.location, this.propId, this.state, this.region, this.imagePath, this.saleOrRent, this.title, this.phone, this.name, this.email, this.goto, this.isFav);
}

class _PropertyListState extends State<PropertyList> {

  final String id;
  final String amount;
  final String location;
  final String propId;
  final String state;
  final String region;
  final String imagePath;
  final String saleOrRent;
  final String title;
  final String phone;
  final String name;
  final String email;
  final Widget goto;
  bool isFav;

  _PropertyListState(
    this.id,
    this.amount,
    this.location,
    this.propId,
    this.region,
    this.state,
    this.imagePath,
    this.saleOrRent,
    this.title,
    this.phone,
    this.name,
    this.email,
    this.goto,
    this.isFav,
  );

  _addToFavorites() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List user = preferences.getStringList("user");
    String body;

    String url = "https://www.gohome.ng/api/send_to_favs_api.php";

    Map<String, String> headers = {"Content-type": "application/json"};
    var s = '{"user_id": "${user[1]}", "propId": "$propId"}';

    print(s);
    String json = s;
    // make POST request
    Response response = await post(url, headers: headers, body: json);
    // check the status code for the result
    int statusCode = response.statusCode;
    // this API passes back the id of the new item added to the body
    body = response.body;

    print(body);

    if (body.isNotEmpty) {

      String msg = "Added to favorites";
      if(isFav) {
        msg = "Removed from favorites";
      }
      Fluttertoast.showToast(
          msg: msg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      setState((){
        this.isFav = !this.isFav;
      });
    }
  }

  void showSimpleCustomDialog(BuildContext context) {
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
                    Text(
                      "User Details",
                      style: TextStyle(fontSize: 20),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        name,
                        style:
                            TextStyle(color: Color(0xFF79c942), fontSize: 20),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text("E-mail: " + email),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text("Phone number: " + phone),
                    )
                  ],
                )),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  MaterialButton(
                    color: Color(0xFF79c942),
                    onPressed: () => launch("tel:${phone}"),
                    child: Text(
                      'Call Contact',
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  MaterialButton(
                    color: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel!',
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  )
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

  void addToFavorites(BuildContext context) {

    String msg = "Add " + title + " to favorites";
    if(isFav) {
      msg = "Remove " + title + " from favorites";
    }
    Dialog simpleDialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        height: 200.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  Text(
                    msg,
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Fluttertoast.showToast(
                            msg: isFav ? "Removing from Favorites" : "Adding "
                                "to "
                                "Favorites",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                        _addToFavorites();

                        // setState(() {
                        //   isActive = true;
                        //   Navigator.of(context).pop();
                        // });
                      },
                      child: Icon(
                        Icons.check,
                        color: Color(0xFF79c942),
                      )),
                  MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.clear,
                        color: Colors.red,
                      )),
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

  // bool isActive = false;
  toCurrency(String a) {
    FlutterMoneyFormatter fAmount;
    try {
      fAmount = FlutterMoneyFormatter(amount: double.parse(a));
    } catch (e) {
      fAmount = FlutterMoneyFormatter(amount: double.parse("0.0"));
      print(e.toString());
    }

    return fAmount;
  }

  // @override
  // void initState() {
  //   super.initState();
  //   isActive = false;
  //   a = amount;
  //   try{
  //     fAmount =
  //       FlutterMoneyFormatter(amount: double.parse(a));
  //   }catch (e){
  //     fAmount = FlutterMoneyFormatter(amount: double.parse("0.0"));
  //     print(e.toString());
  //   }

  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        Share.share("https://www.gohome.ng/property-details.php?prop=$propId");
      },
      child: Card(
        child: Container(
          height: 180.0,
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  GestureDetector(
                    onLongPress: () {
                      addToFavorites(context);
                    },
                    onTap: () {
//                      Navigator.push(
//                        context,
//                        MaterialPageRoute(builder: (context) => goto),
//                      );
                    },
                    child: Row(
                      children: <Widget>[
                        CachedNetworkImage(
                          imageUrl: "http://gohome.ng/assets/upload/" +
                              propId +
                              "/" +
                              imagePath,
                          placeholder: (context, url) =>
                              new CircularProgressIndicator(),
                          errorWidget: (context, url, error) => new Image(
                            image: AssetImage("assets/property_location.jpg"),
                            width: 100,
                          ),
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    saleOrRent.length > 1
                                        ? Flexible(
                                            flex: 2,
                                            child: Container(
                                              child: Pill("For " + saleOrRent),
                                            ),
                                          )
                                        : null,
                                    Expanded(
                                      child: Container()
                                    ),
                                    GestureDetector(
                                      onTap: () => addToFavorites(context),
                                      child: Container(
                                        alignment: Alignment.bottomRight,
                                        child: Card(
                                          color: isFav  ? Colors.red : Color
                                            (0xFF79c942),
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

                                              ],
                                            ),
                                            padding: EdgeInsets.all(3),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),

                              Container(
                                child: Text(
                                  title.length > 20
                                      ? title.substring(0, 25) +
                                          "\n" +
                                          title.substring(
                                              25,
                                              title.length < 50
                                                  ? title.length
                                                  : 50) +
                                          (title.length > 50 ? "..." : "")
                                      : title + "\n",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF79c942),
                                  ),
                                ),
                              ),
                              // Container(
                              //   padding: EdgeInsets.only(left: 5),
                              //   child: Text(region + ", " + state),
                              // ),
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.location_on),
                                    Text(
                                      location.length > 20
                                          ? location.substring(0, 20) + "..."
                                          : location,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 5),
                                child: Text(
                                  "\u20A6 " +
                                      toCurrency(amount)
                                          .output
                                          .nonSymbol
                                          .toString(),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF79c942),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      showSimpleCustomDialog(context);
                    },
                    child: Container(
                      color: Color(0xFF79c942),
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 25, right: 25),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.phone,
                            color: Colors.white,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text(
                              "View Contact",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => goto),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 25, right: 25),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.home,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text("View Property"),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
