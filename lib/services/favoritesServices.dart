import 'dart:convert';
import 'package:http/http.dart' as http;
import '../classes/property.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesServices {
  // static const String url = "https://www.gohome.ng/api/get_favorites_api.php?userId=";

  static Future<List<Property>> getProperties() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List user = preferences.getStringList("user");
    String url = "https://www.gohome.ng/api/get_favorites_api.php?userId=${user[1]}";
    print(url);
    try {
      
      final response =await http.get(url);
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