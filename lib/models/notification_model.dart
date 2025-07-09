import 'package:ismatov/models/post.dart';

class NotificationModel {
  final int id;
  final String notificationType;
  bool isRead;
  final String createdAt;
  final MiniProfile sender;
  final MiniProfile receiver;
  final Map<String,dynamic>? post;
  final Map<String, dynamic>? comment;
  final Map<String, dynamic>? like;
  NotificationModel({
    required this.id,
    required this.notificationType,
    required this.isRead,
    required this.createdAt,
    required this.sender,
    required this.receiver,
    this.post,
    this.comment,
    this.like,

});
  factory NotificationModel.fromJson(Map<String,dynamic>json) {
    return NotificationModel(
        id: json['id'],
        notificationType: json['notification_type'],
        isRead: json['is_read'],
        createdAt: json['created_at'],
        sender: MiniProfile.fromJson(json['sender']),
        receiver:MiniProfile.fromJson(json['receiver']),
        post: json['post'] is Map<String,dynamic> ? json['post'] : null,
        comment: json['comment'] is Map<String,dynamic> ? json['comment'] : null,
        like: json['like'] != null && json['like'] is Map<String,dynamic> ? json['like'] : null,
    );

  }



  @override
  String toString() {
    return 'NotificationModel(id: $id, type: $notificationType, isRead: $isRead, sender: $sender, receiver: $receiver)';
  }
}

class MiniProfile{
  final int id;
  final String? username;
  final String? profileImage;

  MiniProfile({
    required this.id,
    this.username,
    this.profileImage,
});
  factory MiniProfile.fromJson(Map<String,dynamic> json ){
    return MiniProfile(
        id: json['id'],
      username: json['username'] ?? json['username'] ?? json['user_name'],
      profileImage: json['profileImage'],
    );
  }

}


