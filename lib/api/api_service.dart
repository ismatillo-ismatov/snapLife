import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';


class ApiService {

  static Box? _authBox;

  static const String baseUrl = 'http://192.168.100.8:8000/api';
  static const String baseImage = 'http://192.168.100.8:8000';
  final storage = FlutterSecureStorage();
  Future<String?> getUserToken() async {
    var box = await Hive.openBox('authBox');
    String? token = box.get('auth_token');
    print('Retrieved token from authBox: $token');
    return token;
  }

  Future<Box> _getBox() async {
    if (_authBox == null || !_authBox!.isOpen) {
      _authBox = await Hive.openBox('authBox');
    }
    return _authBox!;
  }





  Future<void> saveFCMToken(String token) async {
    final authToken = await getUserToken();
    if (authToken == null ) {
      print("⚠️ Auth token topilmadi - foydalanuvchi hali login qilmagan");
      return;
    }
    final url = Uri.parse('$baseUrl/save_fcm_token/');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Token $authToken',
        'Content-type': 'application/json',
      },
      body: jsonEncode({'fcm_token':token}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Firebase token serverga yuborildi');
    } else {
      print("❌ Token yuborishda xatolik: ${response.body}");
      throw Exception('Token yuborishda xatolik: ${response.statusCode}');
    }

  }


  Future<List<dynamic>> searchUsers(String query,String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search_users/?search=$query'),
      headers: {'Authorization':'Token $token'},
    );
    if(response.statusCode == 200){
      final Map<String,dynamic> data = jsonDecode(response.body);
      return data['results'];
    } else{
      throw Exception("Qidiruvda xatolik: ${response.body}");
    }
  }









  Future<void> saveAuthToken(String token) async {
    final box = await _getBox();
    // var box = await Hive.openBox('authBox');
    await box.put('auth_token', token);
    print('Current authBox contents: ${box.toMap()}');
    print('Token saqlandi: ${box.get("auth_token")}');
  }

  Future<String?>getAuthToken() async {
    final box = await _getBox();
    // var box = await Hive.openBox('authBox');
    final token = box.get('auth_token');
    print("Retrieved token: $token");
    return token;
  }


  Future<void>deleteAuthToken() async {
    final box = await _getBox();
    // var box = await Hive.openBox('authBox');
    await box.delete('auth_token');
    print("token deleted");
  }
  Future<void>saveUserId(int userId) async {
    final box = await _getBox();
    // var box = Hive.box('authBox');
    await box.put("user_id",userId);
    print("Stored user_id in Hive: $userId");
    print('User Id saved:$userId');
  }
  void clearAllUserData() async {
    var authBox = await Hive.openBox('authBox');
    var userBox = await Hive.openBox('userBox');

    await authBox.clear();
    await userBox.clear();

    print("Barcha foydalanuvchi ma'lumotlari Hive'dan o‘chirildi.");
  }



  String formatImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return "https://picsum.photos/150";
    }
    if (imagePath.startsWith("/media/")) {
      return "${baseImage}$imagePath";
    }
    return imagePath;
  }

  String formatVideoUrl(String videoUrl) {
    if (videoUrl.startsWith('http')){
      return videoUrl;
    }
    return '${ApiService.baseImage}$videoUrl';
  }



}

