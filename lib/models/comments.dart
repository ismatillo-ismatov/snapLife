class Comments{
  final int commentId;
  final String user;
  final String commentText;
  final String? commentImage;
  final DateTime timestamp;
  List<Comments> replies;
  bool isLiked;

  Comments({
    required this.commentId,
    required this.user,
    required this.commentText,
    this.commentImage,
    required this.timestamp,
    this.isLiked = false,
    List<Comments>? replies,
  }) :  replies = replies ?? [];
}