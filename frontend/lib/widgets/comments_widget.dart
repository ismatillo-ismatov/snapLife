import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:ismatov/forms/commnetInput.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/models/comments.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/comment_service.dart';
import 'package:ismatov/api/user_service.dart';
import 'package:ismatov/widgets/profile.dart';

class CommentsPage extends StatefulWidget {
  final String token;
  final int postId;
  final int? scrollCommentId;
  final void Function()? onCommentAdded;

  const CommentsPage({required this.token, required this.postId, this.scrollCommentId, this.onCommentAdded});

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  late Future<List<Comment>> _commentsFuture;
  Map<int, GlobalKey> commentKeys = {};
  bool isExpanded = false;
  Set<int> expandedComments = {};

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _showReplyDialog(Comment parentComment) {
    final TextEditingController _replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Reply to ${parentComment.ownerUserName}"),
          content: TextField(
            controller: _replyController,
            decoration: InputDecoration(hintText: "Write your comment"),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Reply"),
              onPressed: () async {
                if (_replyController.text.trim().isNotEmpty) {
                  bool success = await CommentService.postReply(
                    widget.token,
                    parentComment.id,
                    _replyController.text.trim(),
                  );
                  if (success) {
                    Navigator.of(context).pop();
                    _loadComments();
                    widget.onCommentAdded?.call();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  String formatImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return "";
    }
    if (imagePath.startsWith("/media/")) {
      return "${ApiService.baseImage}" + imagePath;
    }
    return imagePath;
  }

  void _loadComments() {
    setState(() {
      _commentsFuture = CommentService.fetchComments(widget.token, widget.postId);
    });

    _commentsFuture.then((comments) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.scrollCommentId != null && commentKeys.containsKey(widget.scrollCommentId)) {
          final key = commentKeys[widget.scrollCommentId];
          if (key?.currentContext != null) {
            Scrollable.ensureVisible(
              key!.currentContext!,
              duration: Duration(milliseconds: 500),
              alignment: 0.5,
              curve: Curves.easeInOut,
            );
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text("Comments")),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Comment>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print("Error details: ${snapshot.error} ");
                  return Center(
                    child: Text("Error ${snapshot.error.toString()}"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No comments available"));
                } else {
                  final comments = snapshot.data!;
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      commentKeys[comment.id] = GlobalKey();
                      return Container(
                        key: commentKeys[comment.id],
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final profileId = comment.profileId ?? comment.owner['profile_id'] ?? 0;
                                print("Profil ID si: $profileId");
                                print("userName: ${comment.ownerUserName}");
                                print("profileImage: ${comment.ownerProfileImage}");
                                if (profileId == 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Profil ID si topilmadi")),
                                  );
                                  return;
                                }
                                try {
                                  final userService = UserService();
                                  print("Token: ${widget.token}");
                                  final userProfile = await userService.fetchUserProfileById(profileId, widget.token);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfilePage(userProfile: userProfile),
                                    ),
                                  );
                                } catch (e) {
                                  print("Xato: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Profilni yuklashda xato: $e")),
                                  );
                                  // Fallback: Mahalliy ma'lumotlardan foydalanamiz
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfilePage(
                                        userProfile: UserProfile(
                                          id: profileId,
                                          userName: comment.ownerUserName ?? 'default',
                                          profileImage: comment.ownerProfileImage != null
                                              ? formatImageUrl(comment.ownerProfileImage)
                                              : null,
                                          posts: [],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  formatImageUrl(comment.ownerProfileImage),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(comment.ownerUserName ?? 'default'),
                                  Text(
                                    comment.comment ?? '',
                                    maxLines: isExpanded ? null : 5,
                                    overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  if ((comment.comment?.length ?? 0) > 100)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isExpanded = !isExpanded;
                                        });
                                      },
                                      child: Text(
                                        isExpanded ? "show less" : "continue reading",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 5,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.favorite,
                                          color: comment.isLiked ? Colors.blue : Colors.grey,
                                        ),
                                        onPressed: () async {
                                          try {
                                            final response = await CommentService.likeComment(widget.token, comment.id);
                                            if (response != null) {
                                              setState(() {
                                                comments[index] = Comment(
                                                  id: comment.id,
                                                  owner: comment.owner,
                                                  profileId: comment.profileId,
                                                  post: comment.post,
                                                  comment: comment.comment,
                                                  replies: comment.replies,
                                                  commentImage: comment.commentImage,
                                                  commentDate: comment.commentDate,
                                                  ownerUserName: comment.ownerUserName,
                                                  ownerProfileImage: comment.ownerProfileImage,
                                                  likes: response['like_count'],
                                                  isLiked: response['is_liked'],
                                                );
                                              });
                                            }
                                          } catch (e) {
                                            print('error like comment $e');
                                          }
                                        },
                                      ),
                                      Text('${comment.likes} likes'),
                                      SizedBox(width: 10),
                                      TextButton(
                                        child: Text('Reply'),
                                        onPressed: () {
                                          _showReplyDialog(comment);
                                        },
                                      ),
                                      if (comment.replies.isNotEmpty)
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              if (expandedComments.contains(comment.id)) {
                                                expandedComments.remove(comment.id);
                                              } else {
                                                expandedComments.add(comment.id);
                                              }
                                            });
                                          },
                                          child: Text(
                                            expandedComments.contains(comment.id)
                                                ? 'Hide replies'
                                                : 'Show replies(${comment.replies.length})',
                                            style: TextStyle(color: Colors.blue),
                                          ),
                                        ),
                                      if (expandedComments.contains(comment.id))
                                        ...comment.replies.map((reply) => Padding(
                                          padding: EdgeInsets.only(left: 40.0, top: 8.0),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  print("Profil sahifasiga o'tish (Reply)");
                                                  final profileId = reply.profileId ?? reply.owner['profile_id'] ?? 0;
                                                  print("Profil ID si: $profileId");
                                                  print("userName: ${reply.ownerUserName}");
                                                  print("profileImage: ${reply.ownerProfileImage}");
                                                  if (profileId == 0) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text("Profil ID si topilmadi")),
                                                    );
                                                    return;
                                                  }
                                                  try {
                                                    final userService = UserService();
                                                    print("Token: ${widget.token}");
                                                    final userProfile = await userService.fetchUserProfileById(profileId, widget.token);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ProfilePage(userProfile: userProfile),
                                                      ),
                                                    );
                                                  } catch (e) {
                                                    print("Xato: $e");
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text("Profilni yuklashda xato: $e")),
                                                    );
                                                    // Fallback: Mahalliy ma'lumotlardan foydalanamiz
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ProfilePage(
                                                          userProfile: UserProfile(
                                                            id: profileId,
                                                            userName: reply.ownerUserName ?? 'default',
                                                            profileImage: reply.ownerProfileImage != null
                                                                ? formatImageUrl(reply.ownerProfileImage)
                                                                : null,
                                                            posts: [],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: CircleAvatar(
                                                  radius: 15,
                                                  backgroundImage: NetworkImage(formatImageUrl(reply.ownerProfileImage)),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(reply.ownerUserName ?? 'default'),
                                                    Text(reply.comment ?? '', style: TextStyle(fontSize: 14)),
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.thumb_up,
                                                            size: 18,
                                                            color: reply.isLiked ? Colors.blue : Colors.grey,
                                                          ),
                                                          onPressed: () async {
                                                            try {
                                                              final response = await CommentService.likeComment(
                                                                widget.token,
                                                                reply.id,
                                                              );
                                                              if (response != null) {
                                                                setState(() {
                                                                  final updatedReplies = comment.replies.map((r) {
                                                                    if (r.id == reply.id) {
                                                                      return Comment(
                                                                        id: r.id,
                                                                        owner: r.owner,
                                                                        profileId: r.profileId,
                                                                        post: r.post,
                                                                        comment: r.comment,
                                                                        replies: r.replies,
                                                                        commentImage: r.commentImage,
                                                                        commentDate: r.commentDate,
                                                                        ownerUserName: r.ownerUserName,
                                                                        ownerProfileImage: r.ownerProfileImage,
                                                                        likes: response['like_count'],
                                                                        isLiked: response['is_liked'],
                                                                      );
                                                                    }
                                                                    return r;
                                                                  }).toList();
                                                                  comments[index] = Comment(
                                                                    id: comment.id,
                                                                    owner: comment.owner,
                                                                    profileId: comment.profileId,
                                                                    post: comment.post,
                                                                    comment: comment.comment,
                                                                    replies: updatedReplies,
                                                                    commentImage: comment.commentImage,
                                                                    commentDate: comment.commentDate,
                                                                    ownerUserName: comment.ownerUserName,
                                                                    ownerProfileImage: comment.ownerProfileImage,
                                                                    likes: comment.likes,
                                                                    isLiked: comment.isLiked,
                                                                  );
                                                                });
                                                              }
                                                            } catch (e) {
                                                              print('error like reply $e');
                                                            }
                                                          },
                                                        ),
                                                        Text('${reply.likes} likes', style: TextStyle(fontSize: 12)),
                                                        TextButton(
                                                          child: Text('Reply', style: TextStyle(fontSize: 12)),
                                                          onPressed: () {
                                                            _showReplyDialog(reply);
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CommentInputField(
              token: widget.token,
              postId: widget.postId,
              onCommentAdded: () {
                _loadComments();
                widget.onCommentAdded?.call();
              },
            ),
          ),
        ],
      ),
    );
  }
}
