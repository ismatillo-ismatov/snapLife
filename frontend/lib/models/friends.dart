import 'package:ismatov/api/api_service.dart';

class FriendRequest {
  final int id;
  final int requestFromId;
  final int requestToId;
  final String userName;
  final String? profileImage;
  final String direction;

  // final String from;
  final String status;

  FriendRequest({
    required this.id,
    required this.requestFromId,
    required this.requestToId,
    required this.userName,
    this.profileImage,
    required this.status,
    required this.direction,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json){
    return FriendRequest(
        id: json['id'],
        requestFromId: json['request_from'] is Map
            ? json['request_from']['id']
            : json['request_from_id'] ?? 0,
        requestToId: json['request_to'] is Map
            ? json['request_to']['id']
            : json['request_to_id'] ?? 0,
        userName: json['request_from']is Map
            ? json['request_from']['username'] ?? 'Nomalum'
            : 'Nomalum',
        profileImage: json['request_from'] is Map
            ? (json['request_from']['profileImage'] != null
            ? '${ApiService.baseImage}${json['request_from']['profileImage']}'
            : null)
            : null,
        status: json['status'] ?? 'pending',
        direction: json['direction'] ?? 'none',
    );
  }
  @override
  String toString(){
    return 'FriendRequest(id: $id, userName: $userName, requestFromId: $requestFromId)';

  }
}
