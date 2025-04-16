import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ismatov/api/api_service.dart';
import 'package:hive/hive.dart';
import 'package:http_parser/http_parser.dart';
import 'package:ismatov/api/example.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import 'package:ismatov/models/post.dart';


class PostService {
  final ApiService _apiService =  ApiService();



  Future<List<Post>> fetchPosts(String token) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/posts/'),
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
          postMap['postImage'] = ApiService().formatImageUrl(postMap['postImage']);
          // postMap['postImage'] = '${ApiService.baseImage}${postMap['postImage']}';
        } else {
          postMap['postImage'] = null;
        }
        // if (postMap['postVideo'] != null && !postMap['postVideo'].startsWith('http')) {
        //   postMap['postVideo'] = '${postMap['postVideo']}';
        // }

        if (postMap['postVideo'] != null && postMap['postVideo'].isNotEmpty) {
            // postMap['postVideo'] = '${ApiService.baseImage}${postMap['postVideo']}';
            postMap['postVideo'] = ApiService().formatVideoUrl(postMap['postVideo']);

        //   postMap['postVideo'] = '${ApiService.baseImage}${postMap['postVideo']}';
        // } else {
        //   postMap['postVideo'] = null;
        }

        print("After modification: $postMap");
        return Post.fromJson(postMap);
      }).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }






  Future<Post> createPost({
    required String content,
    required String token,
    File? postImage,
    File? postVideo,
    }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/posts/');
    final request = http.MultipartRequest('POST',uri)
    ..headers['Authorization'] = 'Token $token'
    ..fields['content'] = content;

    if (postImage != null) {
      request.files.add(
          await http.MultipartFile.fromPath(
              'postImage',postImage.path,
              // contentType: MediaType(mimeType[0],mimeType[1]),
          ),
      );
    }
    if (postVideo != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'postVideo',postVideo.path,
          // contentType: MediaType(mimeType[0],mimeType[1]),
        ),
      );
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201){
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Post yaratishda xatolik ${response.statusCode}');
    }
    }

  Future<Post> updatePost({
    required int postId,
    required String content,
    String? postImagePath,
    required String token,
  }) async {
    var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiService.baseUrl}/posts/$postId/')
    );
    request.headers['Authorization'] = 'Token $token';
    request.fields['content'] = content;

    if (postImagePath != null){
      request.files.add(await http.MultipartFile.fromPath('postImage',postImagePath));
    }
    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      return Post.fromJson(jsonDecode(responseData.body));
    } else{
      throw Exception("Post yangilashda xatolik: ${response.statusCode}");
    }
  }

Future<void>deletePost({
    required int postId,
    required String token,

}) async {
    final url = Uri.parse('${ApiService.baseUrl}/posts/$postId/');
    final response = await http.delete(
        url,
      headers: {
          'Authorization':'Token $token',
      }
    );
    if (response.statusCode == 204) {
      print('Post movfaqiyatli ochirildi');
    } else {
      throw Exception('Postni ochirishda xatolik: ${response.statusCode}');
    }
}


  }








  Future<ToggleLikeResponse> toggleLike({
    required int postId,
    required bool isLiked,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/likes/'),
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











class ToggleLikeResponse{
  final int likeId;
  ToggleLikeResponse({required this.likeId});
  factory ToggleLikeResponse.fromJson(Map<String,dynamic> json){
    return ToggleLikeResponse(
        likeId: json['Id']
    );
  }
}
