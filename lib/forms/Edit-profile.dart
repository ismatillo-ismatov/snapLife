// import 'package:flutter/material.dart';
// import 'package:instagram_clone/models/post.dart';
//
// class CommentsPage extends StatefulWidget {
//   final Post post;
//
//   const CommentsPage({Key? key, required this.post}) : super(key: key);
//
//   @override
//   _CommentsPageState createState() => _CommentsPageState();
// }
//
// class _CommentsPageState extends State<CommentsPage> {
//   void _toggleLike(int commentId, Comment parentComment) {
//     setState(() {
//       Comment comment = parentComment.replies.firstWhere((c) => c.commentId == commentId, orElse: () => parentComment);
//       comment.isLiked = !comment.isLiked;
//     });
//   }
//
//   void _addReply(int commentId, String replyText) {
//     setState(() {
//       Comment parentComment = widget.post.comments.firstWhere((c) => c.commentId == commentId);
//       parentComment.replies.add(
//         Comment(
//           commentId: widget.post.comments.length + parentComment.replies.length + 1,
//           userName: "sizning foydalanuvchi ismingiz",
//           profileImage: 'assets/images/your_profile.jpg',
//           commentText: replyText,
//           timestamp: DateTime.now(),
//         ),
//       );
//     });
//   }
//
//   Future<void> _showReplyDialog(int commentId) async {
//     String replyText = "";
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Reply to comment"),
//           content: TextField(
//             onChanged: (value) {
//               replyText = value;
//             },
//             decoration: InputDecoration(hintText: "Enter your reply"),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _addReply(commentId, replyText);
//               },
//               child: Text("Reply"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Izohlar'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add_comment),
//             onPressed: () {
//               // Yangi izoh qo'shish funksiyasi
//             },
//           ),
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: widget.post.comments.length,
//         itemBuilder: (context, index) {
//           final comment = widget.post.comments[index];
//           return CommentTile(
//             comment: comment,
//             toggleLike: _toggleLike,
//             addReply: _showReplyDialog,
//           );
//         },
//       ),
//     );
//   }
// }
//
// class CommentTile extends StatelessWidget {
//   final Comment comment;
//   final Function(int, Comment) toggleLike;
//   final Function(int) addReply;
//
//   const CommentTile({
//     Key? key,
//     required this.comment,
//     required this.toggleLike,
//     required this.addReply,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ListTile(
//             leading: CircleAvatar(
//               backgroundImage: AssetImage(comment.profileImage),
//             ),
//             title: Text(
//               comment.userName,
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(comment.commentText),
//                 if (comment.commentImage != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Image.asset(comment.commentImage!),
//                   ),
//               ],
//             ),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: Icon(
//                     comment.isLiked ? Icons.favorite : Icons.favorite_border,
//                     color: comment.isLiked ? Colors.red : Colors.black,
//                   ),
//                   onPressed: () {
//                     toggleLike(comment.commentId, comment);
//                   },
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.reply),
//                   onPressed: () {
//                     addReply(comment.commentId);
//                   },
//                 ),
//               ],
//             ),
//           ),
//           // Javoblarni ko'rsatish
//           if (comment.replies.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.only(left: 40.0),
//               child: Column(
//                 children: comment.replies.map((reply) {
//                   return CommentTile(
//                     comment: reply,
//                     toggleLike: toggleLike,
//                     addReply: addReply,
//                   );
//                 }).toList(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
