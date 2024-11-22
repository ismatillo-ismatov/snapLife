import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/forms/loginPage.dart';
import 'package:ismatov/models/userProfile.dart';



class ApiService {
  static const String baseUrl = 'http://192.168.123.3:8000/api';

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts/'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Post.fromJson(data)).toList();
    } else {
      throw Exception("Failed to load posts");
    }
  }


  Future<bool> registerUser(String username,
      String email,
      String password1,
      String password2,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/dj-rest-auth/registration/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'email': email,
        'password1': password1,
        'password2': password2,

      }),

    );

    if (response.statusCode == 200 || response.statusCode == 201 ||
        response.statusCode == 204) {
      print("Backendga muvafiqiyatli qoshildi:${response.body}");
      return true;
    } else {
      print("Failed to register: ${response.body}");
      return false;
    }
  }


  Future<UserProfile> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token-login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('Response data: $responseData');
      final token = responseData['token'];
      await saveAuthToken(token);
      final userProfile = await fetchUserProfile(token);
      print("login movfaqiyatli, token: $token");
      return userProfile;
    } else {
      throw Exception('login failed');
    }
  }

  Future<UserProfile> fetchUserProfile(String token) async {
    final response = await http.get(Uri.parse('$baseUrl/my-profile/'),
    headers: {'Authorization': 'Token $token'},
    );
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return UserProfile.fromJson(jsonResponse);
    } else {
      throw Exception("Failed to load user profile");
    }
  }

  Future<String?> getUserToken() async {
    var box = await Hive.openBox('authBox');
    String? token = box.get('auth_token');
    return token;
  }

  Future<void> saveAuthToken(String token) async {
    var box = await Hive.openBox('authBox');
    await box.put('auth_token', token);
  }



}