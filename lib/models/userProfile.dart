import 'package:ismatov/models/post.dart';

class UserProfile {
  final int id;
  final String userName;
  final String gender;
  List<Post> posts;
  final String? profileImage;
  final String? phone;
  final String? dob;

  UserProfile({
    required this.id,
    required this.userName,
    required this.gender,
    this.profileImage,
    this.phone,
    this.dob,
    List<Post>?  posts,

}): posts = posts ?? [];

  factory UserProfile.fromJson(Map<String,dynamic>json){
    return UserProfile(
        id: json['id']?? 0,
        userName: json['userName'].toString() ,
        gender: json['gender'],
        profileImage: json['profileImage'],
        phone: json['phone'],
        posts: json['posts'],
    );
  }

}




// class UserProfile {
//   final int userId;
//   final String userName;
//   final String userImage;
//   final List<Post> posts;
//
//   UserProfile({
//     required this.userId,
//     required this.userName,
//     required this.userImage,
//     required this.posts,
//   });
// }