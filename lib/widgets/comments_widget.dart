import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:ismatov/forms/commnetInput.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/models/comments.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/comment_service.dart';


class CommentsPage extends StatefulWidget {
  final String token;
  final int postId;
  final int? scrollCommentId;
  final void Function()? onCommentAdded;

  const CommentsPage({required this.token, required this.postId, this.scrollCommentId, this.onCommentAdded});

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage>{
  late Future<List<Comment>> _commentsFuture;
  Map<int,GlobalKey> commentKeys = {};
  bool isExpanded = false;
  Set<int> expandedComments = {};

  @override
  void initState(){
    super.initState();
    _loadComments();

  }


void _showReplyDialog(Comment parentComment){
    final TextEditingController _replyController = TextEditingController();
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Reply to ${parentComment.ownerUserName}"),
            content:  TextField(
              controller: _replyController,
              decoration: InputDecoration(hintText: "Write your comment"),
            ),
            actions: [
              TextButton(
                  child: Text('concel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                  child:Text("Reply"),
                onPressed: () async {
                    if (_replyController.text.trim().isNotEmpty){
                      bool success = await CommentService.postReply(
                        widget.token,
                        parentComment.id,
                        _replyController.text.trim(),
                      );
                      if (success){
                        Navigator.of(context).pop();
                        _loadComments();
                      }
                    }
                },
              )
            ],
          );
        });
}

String formatImageUrl(String? imagePath){
        if (imagePath == null || imagePath.isEmpty){
          return "";
        }
        if (imagePath.startsWith("/media/")){
          return "${ApiService.baseImage}" + imagePath;
        }
        return imagePath;
      }

  void _loadComments() {
    setState(() {
      _commentsFuture =  CommentService.fetchComments(widget.token, widget.postId);
    });

    _commentsFuture.then((comments){
      WidgetsBinding.instance.addPostFrameCallback((_){
        if (widget.scrollCommentId != null &&
        commentKeys.containsKey(widget.scrollCommentId)) {
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
      appBar: AppBar(title: Text("Comments")
      ),

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
                      return Center(child: Text("No comments availble"));
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
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                 formatImageUrl(comment.ownerProfileImage),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(comment.ownerUserName.toString()),
                                        Text(
                                          comment.comment!,
                                          maxLines: isExpanded ? null : 5,
                                          overflow: isExpanded
                                          ? TextOverflow.visible
                                          : TextOverflow.ellipsis,
                                          // overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            setState(() {
                                              isExpanded = !isExpanded;
                                            });
                                          },
                                          child: Text(
                                            isExpanded
                                            ? "show less"
                                                : "continue reading",
                                            style: TextStyle(color: Colors.blue),
                                          ),
                                        ),
                                        Wrap(
                                          spacing:10,
                                          runSpacing:5,
                                          children: [
                                          IconButton(
                                              icon: Icon(
                                                  Icons.favorite,
                                              color: comment.isLiked ? Colors.blue: Colors.grey
                                              ),
    onPressed: () async {
    try {
    final response = await CommentService.likeComment(widget.token, comment.id);
    if (response != null) {
    setState(() {
    comments[index] = Comment(
    owner: comment.owner,
    post: comment.owner,
    isLiked: response['is_liked'],
    likes: response['like_count'],
    id: comment.id,
    comment: comment.comment,
    ownerUserName: comment.ownerUserName,
    ownerProfileImage: comment.ownerProfileImage,
    replies: comment.replies,
    commentDate: comment.commentDate
    );
    });
    }
    } catch (e) {
    print('error like comment $e');
    }
                                            }
                                            ),
                                            Text('${comment.likes} likes'),
                                            SizedBox(width: 10),
                                            TextButton(
                                                child: Text('Reply'),
                                              onPressed: (){
                                                  _showReplyDialog(comment);
                                              },
                                            ),
                                            if (comment.replies != null && comment.replies!.isNotEmpty)
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
                                                        : 'show replies(${comment.replies!.length})',
                                                    style: TextStyle(color: Colors.blue),
                                                  )
                                              ),

                                              if (expandedComments.contains(comment.id))
                                                ...comment.replies!.map((reply) => Padding(
                                                  padding: EdgeInsets.only(left: 40.0,top: 8.0),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 15,
                                                        backgroundImage: NetworkImage(ApiService().formatImageUrl(reply.ownerProfileImage)),
                                                      ),
                                                      SizedBox(width: 10,),
                                                      Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(reply.ownerUserName!),
                                                              Text(reply.comment ?? '', style: TextStyle(fontSize: 14),),
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
                                                                              reply.id
                                                                          );
                                                                          if (response != null ) {
                                                                            setState(() {
                                                                              reply.isLiked = response['is_liked'];
                                                                              reply.likes = response['like_count'];
                                                                            });
                                                                          }
                                                                        } catch (e) {
                                                                          print('error like reply $e');
                                                                        }
                                                                    },

                                                                  ),
                                                                  Text('${reply.likes} likes',style:  TextStyle(fontSize: 12),),
                                                                  TextButton(
                                                                      child: Text('Reply',style: TextStyle(fontSize: 12)),
                                                                    onPressed: () {
                                                                        _showReplyDialog(reply);
                                                                    },
                                                                  )
                                                                ],
                                                              )
                                                            ],
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                )

                                                )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                      );
                    }
                  }),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CommentInputField(
                token: widget.token,
                postId: widget.postId,
                onCommentAdded: () {
                  Navigator.pop(context,true);
                }
            ),
          )
          // Padding(
          //     padding: EdgeInsets.all(8.0),
          //   child: CommentInputField(
          //       token: widget.token,
          //       postId: widget.postId,
          //     onCommentAdded: _loadComments
          //   ),
          // )
        ],
      ),

    );
  }

    }
