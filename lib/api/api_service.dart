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


  Future<List<Post>> fetchPosts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> results = jsonData['results'];
      return results.map((post) {
        final Map<String, dynamic> postMap = post as Map<String, dynamic>;
        print("Before modification: $postMap");
        if (postMap['postImage'] != null && postMap['postImage'].isNotEmpty) {
          postMap['postImage'] = '$baseImage${postMap['postImage']}';
        } else {
          postMap['postImage'] = null;
        }
        print("After modification: $postMap");
        return Post.fromJson(postMap);
      }).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }


  Future<bool> registerUser(String username,
      String email,
      String password1,
      String password2,) async {
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
              ? '$baseImage${data['profileImage']}'
              : null,
          gender: data['gender'],
          posts: data['posts'] != null && data['posts'] is List
              ? (data['posts'] as List<dynamic>)
              .map((post) {
            if (post['postImage'] != null && post['postImage'].isNotEmpty) {
              post['postImage'] = '$baseImage${post['postImage']}';
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
    var box = await Hive.openBox('authBox');
    String? token = box.get('auth_token');
    return token;
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

  Future<ToggleLikeResponse> toggleLike({
    required int postId,
    required bool isLiked,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/likes/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'post': postId,
        'liked': isLiked,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 204) {
      final data = jsonDecode(response.body);
      return ToggleLikeResponse(
        likeId: data['id'] ?? null,
      );
    } else {
      throw Exception("Failed to toggle like : ${response.body}");
    }
  }


  static Future<List<Comment>> fetchComments(String token, int postId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/comments/?post_id=$postId"),
      headers: {
        'Authorization': "Token $token",
        // 'Content-type':'application/json',
      },
    );
    print("response body:${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> results = jsonData["results"];
      return results.map((data) => Comment.fromJson(data)).toList();
    } else {
      throw Exception("Failed to load comments");
    }
  }

  static Future<bool> postComment(String token, int postId,
      String commentText) async {
    final response = await http.post(
      Uri.parse("$baseUrl/comments/"),
      headers: {
        'Authorization': "Token $token",
        'Content-type': 'application/json'
      },
      body: json.encode({
        'post': postId,
        'comment': commentText,
      }),
    );
    print("response body: ${response.body}");
    if (response.statusCode == 201) {
      print("Comment is successfuly");
      return true;
    } else {
      print("Failed to post comment: ${response.body}");
      return false;
    }
  }

  // static Future<Map<String , dynamic>> toggleLikeComment(String token, int commentId) async {
  //   final response = await http.post(
  //     Uri.parse("$baseUrl/comments/$commentId/like/"),
  //     headers: {
  //       'Authorization': "Token $token",
  //     },
  //   );
  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else {
  //     throw Exception('Failed to like');
  //   }
  // }


  static Future<Map<String, dynamic>?> likeComment(String token,
      int commentId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/comments/$commentId/like/"),
      headers: {
        'Authorization': "Token $token",
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // if (  data['results'] != null && data['results'].isNotEmpty) {
      //   return {
      //     'liked': data['results'][0]['is_liked'],
      //     'like_count': data['results'][0]['like_count'],
      //   };
      // }
    } else {
      return null;
    }
  }

// static Future<bool> likeComment(String token, int commentId) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/comments/$commentId/like/"),
//       headers: {
//         'Authorization': "Token $token",
//         'Content-Type': 'application/json',
//       },
//     );
//     if (response.statusCode == 200) {
//       final data  = jsonDecode(response.body);
//       return data['success'] ?? false;
//     } else {
//       throw Exception("Failed to like comment");
//     }
//     // return response.statusCode == 200;
// }

  static Future<bool> postReply(String token, int commentId,
      String reply) async {
    final response = await http.post(
        Uri.parse("$baseUrl/comments/$commentId/reply/"),
        headers: {
          "Authorization": "Token $token",
          'Content-type': 'application/json',
        },
        body: json.encode({
          'comment': reply
        })
      // body: json.encode({
      //   'parent': commentId,
      //   'comment': replyText,
      // }),
    );
    return response.statusCode == 201;
  }

  String formatImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return "";
    }
    if (imagePath.startsWith("/media/")) {
      return "${ApiService.baseImage}" + imagePath;
    }
    return imagePath;
  }
}
class ToggleLikeResponse{
  final int likeId;
  ToggleLikeResponse({required this.likeId});
  factory ToggleLikeResponse.fromJson(Map<String,dynamic> json){
    return ToggleLikeResponse(
    likeId: json['Id']
    );
  }
}
