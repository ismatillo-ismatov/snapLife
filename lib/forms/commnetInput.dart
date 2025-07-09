import 'package:flutter/material.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/comment_service.dart';
import'package:ismatov/models/comments.dart';






class CommentInputField extends StatelessWidget {
  final String token;
  final int postId;
  final int? parentId;
  final VoidCallback onCommentAdded;

  const CommentInputField({
    required this.token,
    required this.postId,
    this.parentId,
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
            decoration: InputDecoration(
                hintText: parentId != null
                ? 'Write a reply'
                : "Write a comment..."

            ),
          ),
        ),

        IconButton(
          icon: Icon(Icons.send),
          onPressed: () async {
            final text = _controller.text.trim();
            if(text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Comment can not be empty"),)
              );
              return;

            }
            bool success;
            if (parentId != null) {
              success = await CommentService.postComment(token, postId!, text,parentId: parentId);
    } else {
              success = await CommentService.postComment(token, postId, text);
    }
            if(success) {
              _controller.clear();
              onCommentAdded();
              ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Comment added successfully"))
              );
    } else {
              ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("failed to add comment"))
              );
    }
            }
        ),
        ],


    );
  }
}

