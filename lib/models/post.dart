import 'package:flutter/material.dart';
import 'package:ismatov/models/comments.dart';


class Post {
  final int id;
  final String owner;
  final String content;
  final String? postImage;
  final DateTime postDate;
  final List<dynamic>comments;
  bool liked;
  int likeCount;
  int? likeId;
  // final List<dynamic>votes;
  // bool save;



  Post({
    required this.id,
    required this.owner,
    required this.content,
    this.postImage,
    required this.postDate,
    this.comments = const [],
    this.liked = false,
    this.likeCount = 0,
    this.likeId,


});

  factory Post.fromJson(Map<String, dynamic> json){
    return Post(
      id: json['id'],
      owner: json['owner'],
      content: json['content'],
      postImage: json['postImage'],
      postDate: DateTime.parse(json['post_date']),
      liked: json['liked']?? false,
      likeCount: json['likeCount'] ?? 0,
      comments: json['comments'] ?? [],
      // likeId: json['likeId'],
    );
  }

}



