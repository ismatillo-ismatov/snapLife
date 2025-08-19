import 'package:flutter/material.dart';
import 'package:ismatov/models/comments.dart';
import 'package:ismatov/api/api_service.dart';

class Post {
  final int id;
  // final int ownerId;
  final int? profileId;
  final String userName;
  final String? ownerProfileImage;
  final String content;
  final String? postImage;
  final String? postVideo;
  final DateTime postDate;
  final List<Comment> comments;
  final int commentCount;
  bool liked;
  int likeCount;
  int? likeId;

  Post({
    required this.id,
    this.profileId,
    required this.content,
    required this.userName,
    this.ownerProfileImage,
    this.postImage,
    this.postVideo,
    required this.postDate,
    this.comments = const [],
    required this.commentCount,
    this.liked = false,
    this.likeCount = 0,
    this.likeId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] ?? {};
    return Post(
      id: json['id'],
      profileId: owner['profile_id'] ?? 0,
      content: json['content'],
      userName: owner['username'] ?? '',
      ownerProfileImage: owner['profileImage'],
      postImage: json['postImage'],
      postVideo: json['postVideo'],
      postDate: DateTime.parse(json['post_date']),
      liked: json['liked'] ?? false,
      likeCount: json['likeCount'] ?? 0,
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e))
              .toList() ??
          [],
      commentCount: int.tryParse(['comment_count'].toString()) ?? 0,
      likeId: json['likeId'],
    );
  }
}
