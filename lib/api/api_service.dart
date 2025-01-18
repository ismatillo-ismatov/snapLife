import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:ismatov/api/example.dart';
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
  }

  Future<void> logout() async {
    var userBox = Hive.box('userBox');
    await userBox.delete('userProfile');
    await userBox.delete('userToken');
  }

  String formatImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return "https://via.placeholder.com/150";
    }
    if (imagePath.startsWith("/media/")) {
      return "${baseImage}$imagePath";
    }
    return imagePath;
  }
}

