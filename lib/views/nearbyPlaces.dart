import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import '../components/notificationPill.dart';
import '../services/cityContentServices.dart';
import '../classes/property.dart';
import '../components/propertyList.dart';
import './eachProperty.dart';

class NearbyPlaces extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NearbyPlacestate();
}

class _NearbyPlacestate extends State<NearbyPlaces> {
  Completer<GoogleMapController> _controller = Completer();

  // initial camera position
         CameraPosition _cameraPos;
     // A map of markers
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
        // function to generate random ids
  int generateIds() {
        var rng = new Random();
        var randomInt;      
          randomInt = rng.nextInt(100);
          print(rng.nextInt(100));
        return randomInt;
      }

  static const apiKey = 'AIzaSyACDaIJn21j0iIg3DizilxBRa3uJRuuwKQ';
  static const myLat = 6.5467204;
  static const myLong = 3.3272275;

  List nearestLat = List();
  List nearestLong = List();

  static const LatLng _center = const LatLng(myLat, myLong);
  Set<Marker> _markers = {};
  List<Set<Marker>> _markerList = List();
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    print(await searchNearby("hotel"));
  }
@override
  void initState(){
    super.initState();
    // _onAddMarkerButtonPressed();
    
  }



  searchNearby(String keyword) async {
    var dio = Dio();
    var url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
    var parameters = {
      'key': apiKey,
      'location': '$myLat, $myLong',
      'radius': '800',
      'keyword': keyword
    };

    var response = await dio.get(url, data: parameters);
    setState(() {
      nearestLat = response.data["results"]
        .map<String>(
            (result) => result['geometry']['location']['lat'].toString())
        .toList();
    nearestLong = response.data["results"]
        .map<String>(
            (result) => result['geometry']['location']['lng'].toString())
        .toList();
    });
    
    return response.data["results"]
        .map<String>(
            (result) => result['geometry']['location']['lat'].toString())
        .toList();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  int i = 0;
  _onAddMarkerButtonPressed() {
    if (i < nearestLat.length) {
      _markers.add(
        Marker(
            markerId: MarkerId(_lastMapPosition.toString()),
            position: LatLng(
                double.parse(nearestLat[i]), double.parse(nearestLong[i])),
            infoWindow: InfoWindow(
              title: "This is a title",
              snippet: "This is a snippet",
            ),
            icon: BitmapDescriptor.defaultMarker),
      );
      _markerList.add(_markers);
      i++;
      _onAddMarkerButtonPressed();
    }
    print(_markers); 
  }

 

  Widget button(Function function, IconData icon, var val) {
    return FloatingActionButton(
      heroTag: "button$val",
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.blue,
      child: Icon(
        icon,
        size: 36.0,
      ),
    );
  }

  void _getLocation() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    final Map<String, Marker> _markers = {};

    setState(() {
      _markers.clear();
      final marker = Marker(
        markerId: MarkerId("curr_loc"),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(title: 'Your Location'),
      );
      _markers["Current Location"] = marker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearest Locations'),
        backgroundColor: Color(0xFF79c942),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "button3",
        onPressed: _getLocation,
        tooltip: 'Get Location',
        child: Icon(Icons.flag),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            mapType: _currentMapType,
            markers: _markers,
            myLocationEnabled: true,
            onCameraMove: _onCameraMove,
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  button(_onMapTypeButtonPressed, Icons.map, 1),
                  SizedBox(
                    height: 16.0,
                  ),
                  button(_onAddMarkerButtonPressed, Icons.add_location, 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
