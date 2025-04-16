import 'package:ismatov/models/post.dart';

class UserProfile {
  final int id;
  final String userName;
  final String? gender;
  final String? profileImage;
  final String? phone;
  final String? dob;
  List<Post> posts;

  UserProfile({
    required this.id,
    required this.userName, 
    this.gender,
    this.profileImage,
    this.phone,
    this.dob,
    List<Post>? posts,

}): posts = posts ?? [];

  factory UserProfile.fromJson(Map<String,dynamic>json){
    print("Parsed id: ${json['id']}");
    print("UserProfile JSON: $json");
    print("Foydalanuvchi JSON ma'lumotlari: $json");
    if(json['profile_id'] == null || json['profile_id'] == 0) {
      throw Exception('UserProfile ID notogri yoki yoq');
    }
    print(json);

    return UserProfile(
        id: json['profile_id'] ?? json['id'] ?? 0,
        userName: json['userName'] ,
        gender: json['gender'],
        profileImage: json['profileImage'],
        phone: json['phone'],
        dob: json['dob'],
        posts: json['posts'] != null
        ? (json ['posts'] as List<dynamic>)
            .map((post) => Post.fromJson(post)).toList()
            : [],

    );

  }

  @override
  String toString() {
    return 'UserProfile(id:$id, userName:$userName,profileImage:$profileImage,posts:$posts)';
  }

}




