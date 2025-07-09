import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ismatov/api/api_service.dart';
import 'package:hive/hive.dart';
import 'package:ismatov/api/post_service.dart';
import 'package:ismatov/models/comments.dart';


class CommentService {
  final ApiService _apiService = ApiService();


    static Future<List<Comment>> fetchComments(String token, int postId) async {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/comments/?post_id=$postId"),
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

  static Future<bool> postComment(String token, int postId, String comment,{int? parentId}) async {
      final Map<String,dynamic> data = {
        'post':postId,
        'comment':comment
      };
      if (parentId != null) {
        data['parent'] = parentId;
      }
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/comments/"),
      headers: {
        'Authorization': "Token $token",
        'Content-type': 'application/json'
      },
      body: jsonEncode(data),

    );
    print("response body: ${response.body}");
    if (response.statusCode == 201) {
      print("Comment is successfully");
      return true;
    } else {
      print("Failed to post comment: ${response.body}");
      return false;
    }
  }


  static Future<Map<String, dynamic>?> likeComment(String token, int commentId) async {
  final response = await http.post(
    Uri.parse("${ApiService.baseUrl}/comments/$commentId/like/"),
    headers: {
      'Authorization': "Token $token",
      'Content-Type': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    return  jsonDecode(response.body);
  } else {
    return null;
  }
}

  static Future<bool> postReply(String token, int commentId,
      String reply) async {
    final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/comments/$commentId/reply/"),
        headers: {
          "Authorization": "Token $token",
          'Content-type': 'application/json',
        },
        body: json.encode({
          'comment': reply
        })

    );
    return response.statusCode == 201;
  }


}