class Comment {
  final int id;
  // final String owner;
  final Map<String, dynamic> owner;
  final int? profileId;
  final String post;
  final String? comment;
  final List<Comment> replies;
  final String? commentImage;
  final String commentDate;
  final String? ownerProfileImage;
  final String? ownerUserName;
  int likes;
  bool isLiked;

  Comment({
    required this.id,
    required this.owner,
    this.profileId,
    required this.post,
    this.comment,
    this.replies = const [],
    this.commentImage,
    required this.commentDate,
    this.ownerUserName,
    this.ownerProfileImage,
    this.likes = 0,
    this.isLiked = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] is Map ? json['owner']: {};
    return Comment(
      id: json['id'],
      owner: owner,
      profileId: owner['profile_id'] ?? null, 
      // owner: json['owner'].toString(),
      post: json['post'].toString(),
      comment: json['comment']?.toString(),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e))
              .toList() ??
          [],
      commentImage: json['comment_image']?.toString(),
      ownerProfileImage: json['ownerProfileImage'],
      ownerUserName: json['ownerUserName'],
      commentDate: json['comment_date'].toString(),
      likes: json['likes'] ?? 0,
      isLiked: json['is_liked'] ?? false,
    );
  }
}
