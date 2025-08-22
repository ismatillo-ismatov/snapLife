import 'package:ismatov/models/post.dart';
import 'package:ismatov/models/userProfile.dart';
class Likes {
  final int id;
  final List<Post> posts;

  Likes({
    required this.id,
    required this.posts,
});

  factory Likes.fromJson(Map<String,dynamic>json){
    return Likes(
        id: json['id'],
        posts: (json['posts'] as List).map((postJson) => Post.fromJson(postJson)).toList(),
    );

  }
}