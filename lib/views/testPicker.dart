import 'package:flutter/material.dart';
import 'package:go_home/classes/images.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:storage_path/storage_path.dart';

class TestPicker extends StatefulWidget {
  @override
  _TestPickerState createState() => new _TestPickerState();
}

class _TestPickerState extends State<TestPicker> {
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';
  String file;
  String base64String;
  String imagePath;

  @override
  void initState() {
    super.initState();
    getImagePath("imgName");
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
      file = resultList[0].name;
    });

    print(getImagePath(resultList[0].name));
  }



  getImagePath(String imgName) async{
    try {
      imagePath = await StoragePath.imagesPath; //contains images path and folder name in json format
    } on Exception {
      imagePath = 'Failed to get path';
    }


    Directory tempDir = await getTemporaryDirectory();
String tempPath = tempDir.path;

Directory appDocDir = await getApplicationDocumentsDirectory();
String appDocPath = appDocDir.path;

    print(tempPath + ", " + appDocPath);

    List imageList = json.decode(imagePath);

    List realPaths = imageList[0]["files"];

    // Images image =imageList[0];

    // print("Image_Path: " + );

    String name = realPaths.where((t) => t.toString().contains(imgName)).toString();

    print("Image_Path: " + name);
    print(realPaths.toString());

    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            Center(child: Text('Error: $_error')),
            RaisedButton(
              child: Text("Pick images"),
              onPressed: loadAssets,
            ),
            Expanded(
              child: buildGridView(),
            ),
            RaisedButton(
                onPressed: () async => showDialog(
                      context: context,
                      builder: (_) => Container(
                        child: FutureBuilder(
                          future: getImageFileFromAssets(getImagePath(images[0].name)),
                          builder: (BuildContext context,
                              AsyncSnapshot<File> snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                null != snapshot.data) {
                              base64String =
                                  base64Encode(snapshot.data.readAsBytesSync());
                              // return Container(
                              //   child: Text(snapshot.data.toString())
                              // );
                              return Flexible(
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  child: Image.file(
                                    snapshot.data,
                                    fit: BoxFit.fill,
                                    width:100,
                                    height: 200,
                                  ),
                                ),
                              );
                            } else if (null != snapshot.error) {
                              return Text(
                                snapshot.error.toString(),
                                textAlign: TextAlign.center,
                              );
                            } else {
                              return const Text(
                                "No image found",
                                textAlign: TextAlign.center,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                child: Text('Show Image'))
          ],
        ),
      ),
    );
  }
}
