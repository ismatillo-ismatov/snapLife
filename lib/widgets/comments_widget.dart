import 'package:flutter/material.dart';
// import 'package:ismatov/forms/Edit-profile.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/models/comments.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/models/userProfile.dart';


class CommentsPage extends StatefulWidget{
  final Post post;
  const CommentsPage({ Key? key, required this.post}): super(key: key);
  @override
  _CommentsPageState createState() => _CommentsPageState();
}
class _CommentsPageState extends State<CommentsPage> {
  void _toggleLike(int commentId, Comments parentComment){
    setState(() {
      Comments comments = parentComment.replies.firstWhere((c) => c.commentId == commentId, orElse: () => parentComment);
      comments.isLiked = !comments.isLiked;
    });
  }
  void _addReply(int commentId,String replyText){
    setState(() {
      Comments parentComment = widget.post.comments.firstWhere((c) => c.commentId == commentId);
      parentComment.replies.add(
        Comments(
            commentId: widget.post.comments.length + parentComment.replies.length + 1,
            user: widget.post.userName,
            commentImage: widget.post.profileImage,
            commentText: replyText,
            timestamp: DateTime.now()
        ),
      );
    });
  }
  Future<void> _showReplyDialog(int commentId) async {
    String replyText = "";
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Reply to comment"),
          content: TextField(
            onChanged: (value){
              replyText = value;
            },
            decoration: InputDecoration(hintText: "Enter your reply"),
          ),
          actions:[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addReply(commentId, replyText);
              },
              child: Text('Reply'),
            )
          ],
        );
      },

    );
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:Text(
          "Comments",
          style: TextStyle(fontSize: 18,),
        ),
      ),
      body:ListView.builder(
        itemCount: widget.post.comments.length,
        itemBuilder:(context,index){
          final comment = widget.post.comments[index];
          return CommentTile(
              comment: comment,
              toggleLike: _toggleLike,
              addReply: _showReplyDialog
          );
        },
      ),

    );


  }
}

class CommentTile extends StatelessWidget{
  final Comments comment;
  final Function(int, Comments) toggleLike;
  final Function(int) addReply;


  const CommentTile({
    Key? key,
    required this.comment,
    required this.toggleLike,
    required this.addReply,
  }) : super(key:key);

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(comment.commentImage!),
              ),
              title: Text(
                comment.user,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment.commentText),
                  if (comment.commentImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Image.asset(comment.commentImage!),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      comment.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: comment.isLiked ? Colors.red : Colors.black,
                    ),
                    onPressed: (){
                      toggleLike(comment.commentId, comment);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.reply),
                    onPressed: (){
                      addReply(comment.commentId);
                    },
                  ),
                ],
              )
          ),
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Column(
                children: comment.replies.map((reply) {
                  return CommentTile(
                      comment: reply ,
                      toggleLike: toggleLike,
                      addReply: addReply
                  );
                }).toList(),
              ),
            )
        ],
      ),
    );
  }
}
