import 'dart:convert';
import 'package:http/http.dart' as http;
import '../classes/property.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeaturedServices {
  static const String url = "https://www.gohome.ng/api/fetch_featured_api.php";

  static Future<List<Property>> getProperties() async{
    try {
      var response;
      SharedPreferences preferences = await SharedPreferences.getInstance();
       if(preferences.getBool("isAuth")){
         String userEmail =preferences.getStringList("user")[1];
          response =await http.get(url + "?user_email=$userEmail");
       }else{
          response =await http.get(url);
       }
      
      
      if(response.statusCode == 200){
        List<Property> list = parseProperties(response.body);
        return list;
      }else{
        throw Exception("Error");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static List<Property> parseProperties(String responseBody){
    final parsed =json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Property>((json) => Property.fromJson(json)).toList();
  }
}