import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ismatov/api/api_service.dart';
import 'package:hive/hive.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import 'package:ismatov/models/post.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';


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
          postMap['postImage'] = postMap['postImage'];
        } else {
          postMap['postImage'] = null;
        }

        if (postMap['postVideo'] != null && postMap['postVideo'].isNotEmpty) {
            postMap['postVideo'] = ApiService().formatVideoUrl(postMap['postVideo']);
            print("Formatted video URL: ${postMap['postVideo']}");


        }

        print("After modification: $postMap");
        return Post.fromJson(postMap);
      }).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }




  Future<Post> fetchPost(int postId, String token) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/posts/$postId/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );
    print("Fetch post response status: ${response.statusCode}");
    print("Fetch post response body: ${response.body}");

    if (response.statusCode == 200) {
      final postMap = json.decode(response.body) as Map<String, dynamic>;
      if (postMap['postImage'] != null && postMap['postImage'].isNotEmpty) {
        postMap['postImage'] = postMap['postImage'];
      } else {
        postMap['postImage'] = null;
      }

      if (postMap['postVideo'] != null && postMap['postVideo'].isNotEmpty) {
        postMap['postVideo'] = ApiService().formatVideoUrl(postMap['postVideo']);
        print("Formatted video URL: ${postMap['postVideo']}");
      }

      return Post.fromJson(postMap);
    } else {
      throw Exception('Failed to load post: ${response.statusCode}');
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
          ),
      );
    }
    if (postVideo != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'postVideo',postVideo.path,
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
  Future<LikeResponse> toggleLike({
    required int postId,
    required bool isLiked,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/posts/$postId/toggle_like/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return LikeResponse(
          liked: true,
          likeId: data['id'],
      );
    } else if (response.statusCode == 204){
      return LikeResponse(
        liked: false,
        likeId: 0,
      );
    } else {
      throw Exception("Failed to toggle like : ${response.body}");
    }

  }

  Future<List<dynamic>> fetchFriendPosts(String token) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/posts/friends/'),
      headers: {
        'Authorization': 'Token $token',
      },
    );
    print(json.decode(response.body));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Postlarni olishda xatolik: ${response.statusCode}");
    }

  }
  Future<List<dynamic>> fetchRandomPosts(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/posts/random-posts/'),
        headers: {'Authorization': 'Token $token'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Random postlarni olishda xato: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Random postlarni yuklashda xato: $e");
    }
  }

  }


  Future<File?> generateVideoThumbnail(String videoUrl) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
      thumbnailPath: tempDir.path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 300,
      quality: 75,
    );
    if (thumbnailPath != null) {
      return File(thumbnailPath);
    } else {
      return null;
    }
  } catch (e) {
    print('Thumbnail olishda xatolik: $e');
    return null;
  }
  }

class LikeResponse {
  final bool liked;
  final int? likeId;


  LikeResponse({required this.liked,this.likeId});


}
