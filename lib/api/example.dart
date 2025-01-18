// Future<void> deletePostHandler(int postId) async {
//   try {
//     String? token = await ApiService().getUserToken();
//     await PostService().deletePost(postId: postId, token: token!);
//     setState(() {
//       widget.userProfile.posts.removeWhere((post) => post.id == postId);
//     });
//
//     // Navigator orqali deletedPostId ni qaytaramiz.
//     Navigator.pop(context, postId);
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Postni o`chirishda xatolik')),
//     );
//   }
// }
