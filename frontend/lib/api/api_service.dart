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


  static const String baseUrl = 'http://176.118.198.70/api';
  static const String baseImage = '';
  // static const String baseImage = 'http://176.118.198.70/';


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
    print('Raw Image Path: $imagePath'); // Xom URL’ni chop etish
    if (imagePath == null || imagePath.isEmpty) {
      print('Returning default image: https://picsum.photos/150');
      return "https://picsum.photos/150";
    }
    if (imagePath.startsWith("http://") || imagePath.startsWith("https://")) {
      print('Returning full URL: $imagePath');
      return imagePath; // To'liq URL bo'lsa, o'zgartirmasdan qaytarish
    }
    if (imagePath.startsWith("/profile_image/") || imagePath.startsWith("/media/")) {
      print('Formatted URL: https://storage.googleapis.com/snaplife/$imagePath');
      return "https://storage.googleapis.com/snaplife/$imagePath"; // Google Cloud Storage yo'li
    }
    print('Returning unchanged: $imagePath');
    return imagePath;
  }

  String formatVideoUrl(String videoUrl) {
    if (videoUrl.startsWith('http')){
      return videoUrl;
    }
    return '${ApiService.baseImage}$videoUrl';
  }



}

