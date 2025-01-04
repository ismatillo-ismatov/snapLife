




















// class CommentsPage extends StatefulWidget {
//   final int postId;
//   final String token;
//
//   CommentsPage({required this.postId, required this.token});
//
//   @override
//   _CommentsPageState createState() => _CommentsPageState();
// }
//
// class _CommentsPageState extends State<CommentsPage> {
//   late Future<List<Comment>> _commentsFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadComments(); // Dastlabki yuklash
//   }
//
//   void _loadComments() {
//     setState(() {
//       _commentsFuture = ApiService.fetchComments(widget.token, widget.postId);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Comments'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: FutureBuilder<List<Comment>>(
//               future: _commentsFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   print("Error details: ${snapshot.error}");
//                   return Center(
//                     child: Text("Error: ${snapshot.error.toString()}"),
//                   );
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Center(child: Text("No Comments available"));
//                 } else {
//                   final comments = snapshot.data!;
//                   return ListView.builder(
//                     itemCount: comments.length,
//                     itemBuilder: (context, index) {
//                       final comment = comments[index];
//                       return Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             CircleAvatar(
//                               backgroundImage: NetworkImage(
//                                 ApiService.formatImageUrl(comment.ownerProfileImage),
//                               ),
//                             ),
//                             SizedBox(width: 10),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(comment.ownerUserName),
//                                   Text(
//                                     comment.comment ?? "",
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: TextStyle(fontSize: 15),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 }
//               },
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(8.0),
//             child: CommentInputField(
//               token: widget.token,
//               postId: widget.postId,
//               onCommentAdded: _loadComments, // Qo‘shimcha funksiyani uzatamiz
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




















// class CommentsPage extends StatefulWidget {
//   final String token;
//   final int postId;
//
//   const CommentsPage({required this.token, required this.postId, Key? key}) : super(key: key);
//
//   @override
//   _CommentsPageState createState() => _CommentsPageState();
// }
//
// class _CommentsPageState extends State<CommentsPage> {
//   List<Comment> comments = []; // Mahalliy ro'yxat
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadComments();
//   }
//
//   Future<void> _loadComments() async {
//     final fetchedComments = await ApiService.fetchComments(widget.token, widget.postId);
//     setState(() {
//       comments = fetchedComments;
//       isLoading = false;
//     });
//   }
//
//   void _addComment(String newCommentText) async {
//     final success = await ApiService.postComment(widget.token, widget.postId, newCommentText);
//     if (success) {
//       setState(() {
//         comments.insert(
//           0,
//           Comment(
//             comment: newCommentText,
//             ownerUserName: "You", // Yangi yozilgan kommentga o'zingizning username'ni qo'yasiz.
//             commentDate: DateTime.now().toString(),
//           ),
//         );
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to post comment.")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Comments")),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: comments.length,
//               itemBuilder: (context, index) {
//                 final comment = comments[index];
//                 return ListTile(
//                   leading: CircleAvatar(
//                     backgroundImage: NetworkImage(comment.ownerProfileImage ?? ""),
//                   ),
//                   title: Text(comment.ownerUserName ?? "Anonymous"),
//                   subtitle: Text(comment.comment ?? ""),
//                 );
//               },
//             ),
//           ),
//           CommentInputField(
//             token: widget.token,
//             postId: widget.postId,
//             onCommentPosted: _addComment, // Yangi yozilgan kommentni qo'shish funksiyasi
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
//
//
//
//
//
//
//
// // class CommentInputField extends StatelessWidget {
// //   final String token;
// //   final int postId;
// //   final Function(String) onCommentPosted;
// //
// //   const CommentInputField({
// //     required this.token,
// //     required this.postId,
// //     required this.onCommentPosted,
// //     Key? key,
// //   }) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final TextEditingController _controller = TextEditingController();
// //
// //     return Row(
// //       children: [
// //         Expanded(
// //           child: TextField(
// //             controller: _controller,
// //             decoration: InputDecoration(hintText: "Write a comment..."),
// //           ),
// //         ),
// //         IconButton(
// //           icon: Icon(Icons.send),
// //           onPressed: () {
// //             if (_controller.text.trim().isNotEmpty) {
// //               onCommentPosted(_controller.text.trim());
// //               _controller.clear();
// //             } else {
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 SnackBar(content: Text("Comment cannot be empty.")),
// //               );
// //             }
// //           },
// //         ),
// //       ],
// //     );
// //   }
// // }
//
// //
// //
// //
// //
// //
// //
// //
// //
// //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Row(
// // //       children: [
// // //         Expanded(
// // //           child: TextField(
// // //             controller: _controller,
// // //             decoration: InputDecoration(hintText: "Write a comment..."),
// // //           ),
// // //         ),
// // //         IconButton(
// // //           icon: _isLoading
// // //               ? SizedBox(
// // //             height: 24,
// // //             width: 24,
// // //             child: CircularProgressIndicator(strokeWidth: 2),
// // //           )
// // //               : Icon(Icons.send),
// // //           onPressed: _isLoading ? null : _postComment,
// // //         ),
// // //       ],
// // //     );
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _controller.dispose();
// // //     super.dispose();
// // //   }
// // // }
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // // // static Future<bool>postComment(String token, int postId, String commentText) async {
// // // // final response = await http.post(
// // // // Uri.parse("$baseUrl/comments/"),
// // // // headers: {
// // // // 'Authorization': "Token $token",
// // // // 'Content-type': 'application/json'
// // // // },
// // // // body: json.encode({
// // // // 'post':postId,
// // // // 'comment':commentText,
// // // // }),
// // // // );
// // // // print("response body: ${response.body}");
// // // // if (response.statusCode == 201) {
// // // // print("Comment is successfuly");
// // // // return true;
// // // // } else{
// // // // print("Failed to post comment: ${response.body}");
// // // // return false;
// // // // }
// // // // }
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //
// // // // // return ListTile(
// // // // //
// // // // //   leading:
// // // // //   comment.ownerProfileImage != null
// // // // //   ? CircleAvatar(
// // // // //     backgroundImage: NetworkImage(formatImageUrl(comment.ownerProfileImage)),
// // // // //   ) :
// // // // //       CircleAvatar(
// // // // //         child: Icon(Icons.person),
// // // // //       ),
// // // // //   title: Text(
// // // // //    comment.comment ?? "",
// // // // //     maxLines: 2,
// // // // //     overflow: TextOverflow.ellipsis,
// // // // //
// // // // //   ),
// // // // //
// // // // //   subtitle: Text("Posted on: ${comment.commentDate ?? 'Unknown Date'}"),
// // // // //
// // // // // );
// // //
// // //
// // //
// // // // Future<void> postComment(String token, int postId, String commentText) async {
// // // // try{
// // // // final response = await ApiService.postComment(token, postId, commentText);
// // // // if(response.statusCode == 201){
// // // //   final newComment = Comment.fronJson(json.decode(response.body));
// // // //   setState(() {
// // // //     comments.insert(0,newComment);
// // // //   });
// // // // } else{
// // // //   print("Failed to post comment: ${response.body}");
// // // // }
// // // // } catch (e) {
// // // //   print("error posting comment: $e");
// // // // }
// // // // }