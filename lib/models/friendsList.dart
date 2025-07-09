import 'package:flutter/cupertino.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/models/post.dart';

class Friend{
  final int id;
  final String userName;
  final String? profileImage;
  List<Post> posts;
  final bool isOnline;
  final DateTime? lastActive;


  Friend({
    required this.id,
    required this.userName,
    this.profileImage,
    List<Post>? posts,
    required this.isOnline,
    this.lastActive,

}): posts = posts ?? [];
  factory Friend.fromJson(Map<String,dynamic>json) {
    return Friend(
        id: json['id'] as int? ?? 0 ,
        userName: json['userName'] as String? ?? 'No username',
        profileImage: json['profileImage'] != null
        ? '${ApiService.baseImage}${json['profileImage']}'
            :null,
      posts: json['posts'] != null
      ?(json ['posts'] as List<dynamic>)
      .map((post) => Post.fromJson(post)).toList()
      : [],
      isOnline: json['is_online'] ?? false,
      lastActive: json['last_activity'] != null
        ? DateTime.parse(json['last_activity'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': userName,
      'profile_image': profileImage?.replaceAll(ApiService.baseImage, ''),
      'last_active':lastActive,
      'is_online': isOnline,
    };
  }
  @override
  bool operator == (Object other) =>
      identical(this, other) ||
  other is Friend && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}