import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ismatov/api/api_service.dart';
import 'package:hive/hive.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/api/post_service.dart';
import 'package:ismatov/models/userProfile.dart';


class UserService{
  final ApiService _apiService = ApiService();

  Future<bool> registerUser(String username,
      String email,
      String password1,
      String password2,) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/dj-rest-auth/registration/'),
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
      Uri.parse('${ApiService.baseUrl}/token-login'),
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
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/my-profile/'),
      headers: {'Authorization': 'Token $token'},
    );
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");


    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<Post> posts = data['posts'] != null
          ? (data['posts'] as List<dynamic>)
          .map((post) => Post.fromJson(post as Map<String, dynamic>))
          .toList()
          : [];

      return UserProfile(
          id: data['id'],
          userName: data['userName'],
          profileImage: data['profileImage'] != null
              ? '${ApiService.baseImage}${data['profileImage']}'
              : null,
          gender: data['gender'],
          posts: data['posts'] != null && data['posts'] is List
              ? (data['posts'] as List<dynamic>)
              .map((post) {
            if (post['postImage'] != null && post['postImage'].isNotEmpty) {
              post['postImage'] = '${ApiService.baseImage}${post['postImage']}';
            }
            return Post.fromJson(post as Map<String, dynamic>);
          }).toList()
              : []
      );
    } else {
      throw Exception("Failed to load user profile");
    }
  }


  Future<String?> getUserToken() async {
    return await _apiService.getUserToken();
  }

  Future<void> saveAuthToken(String token) async {
    return await _apiService.saveAuthToken(token);
  }


  Future<void> logout() async {
    return await _apiService.logout();
  }

}