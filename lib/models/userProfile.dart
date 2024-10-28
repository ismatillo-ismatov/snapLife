import 'package:ismatov/models/post.dart';


class UserProfile {
  final int userId;
  final String userName;
  final String userImage;
  final List<Post> posts;

  UserProfile({
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.posts,
  });
}