import 'package:flutter/material.dart';
import 'package:ismatov/models/comments.dart';


class Post {
  final int id;
  final int owner;
  final String content;
  final String? postImage;
  final String postDate;
  bool isLiked;
  bool save;



  Post({
    required this.id,
    required this.owner,
    required this.content,
    this.postImage,
    required this.postDate,
    this.isLiked = false,
    this.save = false,

});

  factory Post.fromJson(Map<String, dynamic> json){
    return Post(
      id: json['id'],
      owner: json['owner'],
      content: json['content'],
      postImage: json['postImage'],
      postDate: json['postDate'],
      isLiked: json['isLiked'],
      save: json['save'],
    );
  }

}



// class Post {
//   final int id;
//   final String userName;
//   final String profileImage;
//   final String postTitle;
//   final String? imagePath;
//   final String? videoPath;
//   final String postText;
//   bool isLiked;
//   bool save;
//   List<Comments> comments;
//   Post({
//     required this.id,
//     required this.userName,
//     required this.profileImage,
//     required this.postTitle,
//     this.imagePath,
//     this.videoPath,
//     required this.postText,
//     this.isLiked = false,
//     this.save = false,
//     this.comments = const [],
//   }): assert(
//   (imagePath != null && videoPath == null)||
//       (imagePath == null && videoPath != null),
//   );
// }
// List<Post> posts = [
//   Post(
//       id: 1,
//       profileImage: 'assets/images/ismatov.jpg',
//       userName: "ismatov",
//       imagePath: 'assets/images/5.jpg',
//       postTitle: "hello everyone",
//       postText: "Agar matn uzun bo‘lsa va faqat boshlang‘ich ikkita qatorni ko‘rsatib, qolgan qismini 'Continue reading' tugmasini bosganida ko‘rsatishni xohlasangiz, Text vidjetida maxLines va TextOverflow.ellipsis parametrlari bilan ishlash mumkin. Shuningdek, uzun matnni yashirish va ochish uchun bool qiymatidan foydalanasiz.",
//       comments: [
//         Comments(
//           commentId: 1,
//           user: 'ismatov',
//           commentImage: "assets/images/3.jpg",
//           timestamp: DateTime.now(),
//           commentText: "hello my friend",
//         ),
//         Comments(
//           commentId: 1,
//           user: 'Qodirov',
//           commentImage: "assets/images/2.jpg",
//           timestamp: DateTime.now(),
//           commentText: "hello my friend",
//         ),
//       ]
//
//   ),
//
//   Post(
//       id: 2,
//       profileImage: 'assets/images/5.jpg',
//       userName: 'johongir',
//       imagePath: 'assets/images/5.jpg',
//       postTitle: "hello everyone",
//       postText:
//       "Agar matn uzun bo‘lsa va faqat boshlang‘ich ikkita qatorni ko‘rsatib, qolgan qismini 'Continue reading' tugmasini bosganida ko‘rsatishni xohlasangiz, Text vidjetida maxLines va TextOverflow.ellipsis parametrlari bilan ishlash mumkin. Shuningdek, uzun matnni yashirish va ochish uchun bool qiymatidan foydalanasiz",
//       comments: [
//         Comments(
//           commentId: 1,
//           user: 'ismatov',
//           commentImage: "assets/images/3.jpg",
//           timestamp: DateTime.now(),
//           commentText: "hello my friend I like this comment",
//         ),
//         Comments(
//           commentId: 2,
//           user: 'ismatov',
//           commentImage: "assets/images/3.jpg",
//           timestamp: DateTime.now(),
//           commentText: "hello my friend",
//         ),
//       ]
//
//   ),
//   Post(
//       id: 3,
//       profileImage: 'assets/images/4.jpg',
//       userName: 'qodirov',
//       imagePath: 'assets/images/2.jpg',
//       postTitle: "hello everyone",
//       postText: "hello qodirov",
//       comments: [
//         Comments(
//           commentId: 1,
//           user: 'ismatov',
//           commentImage: "assets/images/3.jpg",
//           timestamp: DateTime.now(),
//           commentText: "hello my friend",
//         ),
//         Comments(
//           commentId: 1,
//           user: 'ismatov',
//           commentImage: "assets/images/3.jpg",
//           timestamp: DateTime.now(),
//           commentText: "hello my friend",
//           replies: [
//             Comments(
//               commentId: 2,
//               user: 'hasan',
//               commentImage: "assets/images/3.jpg",
//               commentText: 'gapiz togri',
//               timestamp: DateTime.now(),
//             ),
//           ],
//         ),
//       ]
//   ),
//   Post(
//     id: 4,
//     profileImage: 'assets/images/3.jpg',
//     userName: 'qodirov',
//     imagePath: 'assets/images/3.jpg',
//     postTitle: "hello everyone",
//     postText: "hello qodirov",
//   ),
// ];