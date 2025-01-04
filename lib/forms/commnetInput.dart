import 'package:flutter/material.dart';
import 'package:ismatov/api/api_service.dart';
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
              bool success = await ApiService.postComment(
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

// class CommentInputField extends StatelessWidget {
//   final String token;
//   final int postId;
//   final Function(String) onCommentPosted;
//
//   const CommentInputField({
//     required this.token,
//     required this.postId,
//     required this.onCommentPosted,
//     Key? key,
//   }) : super(key: key);
//
//
//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController _controller = TextEditingController();
//     return Row(
//       children: [
//         Expanded(
//           child: TextField(
//             controller: _controller,
//             decoration: InputDecoration(hintText: "white a comment..."),
//
//           ),
//         ),
//         IconButton(
//             icon: Icon(Icons.send),
//             onPressed: () {
//               if (_controller.text.trim().isNotEmpty) {
//                 onCommentPosted(_controller.text.trim());
//                 _controller.clear();
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Comment cannot be empty"),)
//                 );
//               }
//             }
//
//         )
//
//       ],
//     );
//   }
// }

//
// class CommentInputField extends StatefulWidget {
//   final String token;
//   final int postId;
//
//   const CommentInputField({required this.token, required this.postId,Key? key}): super (key:key);
//
//   @override
//   _CommentInputFieldState  createState() => _CommentInputFieldState();
// }
//
// class _CommentInputFieldState extends State<CommentInputField>{
//   final TextEditingController _controller = TextEditingController();
//   bool _isLoading = false;
//
//
//   void _postComment() async {
//     if(_controller.text.trim().isEmpty){
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Comment cannot be empty")),
//       );
//       return;
//     }
//     setState(() {
//       _isLoading = true;
//     });
//
//     final  success = await ApiService.postComment(widget.token,widget.postId, _controller.text);
//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Comment posted!")));
//       _controller.clear();
//     } else{
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to post comment.")));
//     }
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children:[
//         Expanded(
//             child: TextField(
//               controller: _controller,
//               decoration: InputDecoration(hintText: "write a comment..."),
//             ),
//         ),
//         IconButton(
//             icon: _isLoading
//             ? CircularProgressIndicator()
//             : Icon(Icons.send),
//           onPressed: _isLoading ? null : _postComment,
//         ),
//       ]
//     );
//   }
//   @override
//   void dispose(){
//     _controller.dispose();
//     super.dispose();
//   }
