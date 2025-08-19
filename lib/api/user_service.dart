import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:ismatov/api/api_service.dart';
import 'package:hive/hive.dart';
import 'package:ismatov/main.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/api/post_service.dart';
import 'package:ismatov/models/userProfile.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<bool> registerUser(
    String username,
    String email,
    String password1,
    String password2,
  ) async {
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

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      print("Backendga muvafiqiyatli qoshildi:${response.body}");
      return true;
    } else {
      print("Failed to register: ${response.body}");
      return false;
    }
  }

  Future<UserProfile> loginUser(String username, String password) async {
    try {
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
        var verifiedToken = await getAuthToken();
        print("login successfully,  Token verified: ${verifiedToken != null}");

        await FirebaseMessaging.instance.deleteToken();
        final fcmToken = await FirebaseMessaging.instance.getToken();
        print("📲 Login paytida FCM token: $fcmToken");
        if (fcmToken != null) {
          await ApiService().saveFCMToken(fcmToken);
        }

        return await fetchUserProfile(token);
      } else {
        throw Exception('login failed');
      }
    } catch (e) {
      print('Error in loginUser: $e');
      rethrow;
    }
  }

  // Future<UserProfile> loginUser(String username, String password) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('${ApiService.baseUrl}/token-login'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode({
  //         'username': username,
  //         'password': password,
  //       }),
  //     );
  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //       print('Response data: $responseData');
  //       final token = responseData['token'];
  //       await saveAuthToken(token);
  //       var verifiedToken = await getAuthToken();
  //       print("login successfully,  Token verified: ${verifiedToken != null}");

  //       final fcmToken = await FirebaseMessaging.instance.getToken();
  //       print("📲 Login paytida FCM token: $fcmToken");
  //       if (fcmToken != null) {
  //         await ApiService().saveFCMToken(fcmToken);
  //       }

  //       return await fetchUserProfile(token);
  //     } else {
  //       throw Exception('login failed');
  //     }
  //   } catch (e) {
  //     print('Error in loginUser: $e');
  //     rethrow;
  //   }
  // }

  Future<UserProfile> fetchUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/my-profile/'),
      headers: {'Authorization': 'Token $token'},
    );
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['id'] == null || data['id'] == 0) {
        throw Exception("Invalid User ID  in API response");
      }

      List<Post> posts = data['posts'] != null
          ? (data['posts'] as List<dynamic>)
              .map((post) => Post.fromJson(post as Map<String, dynamic>))
              .toList()
          : [];

      return UserProfile(
          id: data['id'],
          userName: data['userName'],
          profileImage: data['profileImage'],
          gender: data['gender'],
          posts: data['posts'] != null && data['posts'] is List
              ? (data['posts'] as List<dynamic>).map((post) {
                  if (post['postImage'] != null &&
                      post['postImage'].isNotEmpty) {}
                  return Post.fromJson(post as Map<String, dynamic>);
                }).toList()
              : []);
    } else {
      throw Exception("Failed to load user profile");
    }
  }

  Future<UserProfile> fetchUserProfileById(int userId, String token) async {
    final response = await http
        .get(Uri.parse('${ApiService.baseUrl}/profile/$userId'), headers: {
      'Authorization': 'Token $token',
    });
    print(
        "fetchUserProfileById: userId=$userId, Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Post> posts = data['posts'] != null
          ? (data['posts'] as List<dynamic>).map((post) {
              return Post.fromJson(post as Map<String, dynamic>);
            }).toList()
          : [];
      return UserProfile(
          id: data['id'],
          userName: data['userName'],
          profileImage: data['profileImage'],
          posts: posts);
    } else {
      throw Exception(
          "User Topilmadi: Status ${response.statusCode}, Body: ${response.body}");
    }
  }

  Future<void> refreshToken() async {
    final apiService = ApiService();
    String? newToken = await apiService.getUserToken();
    if (newToken != null) {
      await apiService.saveAuthToken(newToken);
      print('Token refreshed');
    } else {
      print('Error: Failed to refresh token');
    }
  }

  Future<void> refreshUserId() async {
    final apiService = ApiService();
    String? token = await apiService.getUserToken();
    if (token != null) {
      int? newUserId = await getUserIdFromToken(token);
      if (newUserId != null) {
        await apiService.saveUserId(newUserId);
        print('User ID refreshed: $newUserId');
      } else {
        print("Error: Failed to refresh user ID");
      }
    } else {
      print("Error: Token is null");
    }
  }

  Future<int?> getUserIdFromToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/get-user-id/'),
        headers: {'Authorization': 'Token $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['id'];
      } else {
        throw Exception("Failed to fetch user ID from token");
      }
    } catch (e) {
      print('Error fetching user ID from token $e');
      return null;
    }
  }

  Future<void> saveAuthToken(String token) async {
    try {
      var box = await Hive.openBox('authBox');
      await box.put('auth_token', token);
      print("token successfully saved to authBox");
      var savedToken = box.get("auth_token");
      print("Saved token verification $savedToken");
    } catch (e) {
      print('Error saving token: $e');
      throw Exception("Failed to save token");
    }
  }

  Future<String?> getAuthToken() async {
    try {
      var box = await Hive.openBox('authBox');
      var token = box.get('auth_token');
      if (token == null) {
        print("no token found is authBox");
      } else {
        print("Retrieved token from authBox");
      }
      return token;
    } catch (e) {
      print("Error retrieving token $e");
      return null;
    }
  }

  Future<void> clearAuthToken() async {
    try {
      var box = await Hive.openBox('authBox');
      await box.delete('auth_token');
      print('Token successfully cleared from authBox');
    } catch (e) {
      print("Error clearing token $e");
      throw Exception("Failed to clear token");
    }
  }

  Future<bool> checkToken() async {
    try {
      var box = await Hive.openBox('authBox');
      String? token = box.get('auth_token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Error checking token: $e');
      return false;
    }
  }

  Future<String?> getUserToken() async {
    return await _apiService.getUserToken();
  }

  Future<void> logout() async {
    try {
      final token = await getUserToken();
      if (token != null) {
        final url = Uri.parse('${ApiService.baseUrl}/clear-fcm-token/');
        await http.post(
          url,
          headers: {
            'Authorization': 'Token: $token',
            'Content-Type': 'application/json',
          }
        );
      }
      await clearAuthToken();
      try {
        var userBox = await Hive.openBox('userBox');
        await userBox.clear();
        print("userBox clear successfully");
      } catch (e) {
        print("Error clearing userBox $e");
      }
      print("user logged out successfully");
    } catch (e) {
      print("Error during logout: $e");
      throw Exception('login failed');
    }
  }

  // Future<void> logout() async {
  //   try {
  //     await clearAuthToken();
  //     try {
  //       var userBox = await Hive.openBox('userBox');
  //       await userBox.clear();
  //       print("userBox clear successfully");
  //     } catch (e) {
  //       print("Error clearing userBox $e");
  //     }
  //     print("user logged out successfully");
  //   } catch (e) {
  //     print("Error during logout: $e");
  //     throw Exception('login failed');
  //   }
  // }

  Future<void> updateUserProfile({
    required String userName,
    required String bio,
    required String gender,
    File? imageFile,
  }) async {
    final token = await getUserToken();
    if (token == null) {
      print("❌ Auth token topilmadi!");
      throw Exception("Auth token topilmadi");
    }
    final uri = Uri.parse('${ApiService.baseUrl}/edit-profile/');
    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = 'Token $token';
    request.fields['username'] = userName;
    request.fields['bio'] = bio;
    request.fields['gender'] = gender;
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profileImage',
        imageFile.path,
      ));
    }
    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 202) {
      print("✅ Profile yangilandi");
      print('Response $respStr');
    } else {
      print("❌ Xatolik: ${response.statusCode}, ${respStr}");
      throw Exception('Profile yangilandi xatolik ${response.statusCode}');
    }
  }
  Future<List<UserProfile>> fetchNonFriends(String token,{String? username }) async {
    try{
      final uri = username != null
      ? Uri.parse('${ApiService.baseUrl}/friends/find-friends/?username=$username')
      : Uri.parse('${ApiService.baseUrl}/friends/find-friends/');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Token $token',
        },
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> results = jsonData is List ? jsonData : jsonData['results'] ?? [];
        if (results.isEmpty && jsonData.containsKey('message')) {
          return [];
        }
        return results.map((e) => UserProfile.fromJson(e)).toList();
      } else {
        throw Exception("Do'st bolmagan foydalanuvchilar olishda xatolik: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Do'st bolmagan foydalanuchilar olishda xatolik: $e");
    }
  }
}
