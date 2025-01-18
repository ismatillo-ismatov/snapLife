import 'package:flutter/material.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/comment_service.dart';
import'package:ismatov/models/comments.dart';






class CommentInputField extends StatelessWidget {
  final String token;
  final int postId;
  final VoidCallback onCommentAdded;

  const CommentInputField({
    required this.token,
    required this.postId,
    required this.onCommentAdded,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Write a comment..."),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () async {
            if (_controller.text.trim().isNotEmpty) {
              bool success = await CommentService.postComment(
                  token, postId, _controller.text.trim());
              print("Sending postId $postId");
              if (success) {
                _controller.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Comment added successfully .")),
                );
                onCommentAdded();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed add to comment")),
                );
              }
            } else{
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("comment cannot be empty")),
              );
            }
          } ,
        ),
      ],
    );
  }
}

