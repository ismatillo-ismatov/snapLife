import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/forms/loginPage.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/models/comments.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.100.8:8000/api';
  static const String baseImage = 'http://192.168.100.8:8000';
  Future<String?> getUserToken() async {
    var box = await Hive.openBox('authBox');
    String? token = box.get('auth_token');
    print('Retrieved token from authBox: $token');
    return token;
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
    var box = await Hive.openBox('authBox');
    await box.put('auth_token', token);
    print('Current authBox contents: ${box.toMap()}');
    print('Token saqlandi: ${box.get("auth_token")}');
  }

  Future<String?>getAuthToken() async {
    var box = await Hive.openBox('authBox');
    final token = box.get('auth_token');
    print("Retrieved token: $token");
    return token;
  }


  Future<void>deleteAuthToken() async {
    var box = await Hive.openBox('authBox');
    await box.delete('auth_token');
    print("token deleted");
  }
  Future<void>saveUserId(int userId) async {
    var box = Hive.box('authBox');
    await box.put("user_id",userId);
    print("Stored user_id in Hive: $userId");
    print('User Id saved:$userId');
  }

  // Future<void> logout() async {
  //   var authBox = await Hive.openBox('authBox');
  //   var userBox = await Hive.openBox('userBox');
  //   await authBox.clear();
  //   await userBox.clear();
  //   await Hive.deleteBoxFromDisk('authBox');
  //   await Hive.deleteBoxFromDisk('userBox');
  //   await Hive.initFlutter();
  //   print('User logged out and Hive boxes cleared');
  //   print("Foydalanuvchi chiqdi");
  // }


  // Future<void> logout() async {
  //   var userBox = Hive.box('userBox');
  //   await userBox.delete('userProfile');
  //   await userBox.delete('userToken');
  // }

  Future<void>clearHiveBox() async {
    var box = await Hive.openBox('authBox');
    await box.clear();
    print('Hive box cleaned');
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

