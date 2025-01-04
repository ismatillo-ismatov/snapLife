// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:ismatov/widgets/comments_widget.dart';
// import 'package:video_player/video_player.dart';
// import 'package:ismatov/api/api_service.dart';
// import 'package:ismatov/models/post.dart';
// import 'package:ismatov/widgets/video_player_widget.dart';
//
//
// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   List<Post> posts = [];
//   // bool isLoading = true;
//   final ApiService apiService = ApiService();
//
//   @override
//   void initState() {
//     super.initState();
//     getPosts();
//   }
//
//   Future<void>getPosts() async {
//     try {
//       String? token = await ApiService().getUserToken();
//       if (token == null) {
//         print("token mavjud emas");
//         return;
//       }
//       List<Post>fetchedPosts = await apiService.fetchPosts(token);
//       setState(() {
//         posts = fetchedPosts;
//       });
//     } catch (error) {
//       print('Postlarni olishda xatolik $error');
//
//     }
//
//
//   // Future<void>getPosts()async {
//   //   String? token = await ApiService().getUserToken();
//   //     final apiService = ApiService();
//   //     List<Post>fetchedPosts = await apiService.fetchPosts();
//   //     setState(() {
//   //       posts = fetchedPosts;
//   //       isLoading = false;
//   //     });
//   //   }
//   //   catch (e) {
//   //     print("error loading posts: $e");
//   //     setState(() {
//   //       isLoading = false;
//   //     });
//   //   }
//   }
//
//   // void _toggleVotes(int id) {
//   //   setState(() {
//   //     Post post = posts.firstWhere((post) => post.id == id);
//   //     post.votes = !post.votes;
//   //   });
//   // }
//
//   // void _toggleSave(int id) {
//   //   setState(() {
//   //     Post post = posts.firstWhere((post) => post.id == id);
//   //     post.save = !post.save;
//   //   });
//   }
//
//   @override
//   // Widget build(BuildContext context) {
//     // if (isLoading){
//     //   return Center(child: CircularProgressIndicator());
//     // }
//     // return SingleChildScrollView(
//     //   scrollDirection: Axis.vertical,
//     //   child: Column(
//     //       children: posts.map((post){
//     //         return PostWidget(
//     //             post: post,
//     //             toggleLike: votes,
//     //             toggleSave: _toggleSave
//     //         );
//     //       }).toList()
//     //
//     //   ),
//     // );
// // }
//
// class PostWidget extends StatefulWidget{
//   final Post post;
//   final Function(int) votes;
//   // final Function(int) toggleSave;
//
//   const PostWidget({
//     Key? key,
//     required this.post,
//     required this.votes,
//     // required this.toggleSave,
//   }) : super(key: key);
//
//   @override
//   _PostWidgetState createState() => _PostWidgetState();
// }
//
// class _PostWidgetState extends State<PostWidget>{
//   bool isExpended = false;
//   @override
//   Widget build(BuildContext context) {
//     final fullImageUrl = 'http://192.168.43.197:8000/api/media/post_image/' + (widget.post.postImage ?? '');
//     return Column(
//       children: [
//         Container(
//           height: 300,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             border:  Border.all(color: Colors.greenAccent),
//           ),
//           child: Stack(
//             children: [
//               widget.post.postImage != null
//                   ? Container(
//                 height: double.infinity,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(widget.post.postImage!),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               )
//               //     :widget.post.videoPath != null
//               //     ? AspectRatio(
//               //   aspectRatio: 16 / 9,
//               //   child: VideoPlayerWidget(videoPath: widget.post.videoPath!),
//               //
//               // )
//               // ?VideoPlayerWidget(videoPath: widget.post.videoPath!)
//                   :SizedBox.shrink(),
//
//               Positioned(
//                 top: 20,
//                 left: 80,
//                 child: Text(
//                   widget.post.owner.toString(),
//                   style: TextStyle(color: Colors.white,fontSize:18),
//                 ),
//               ),
//               Positioned(
//                 top: 20,
//                 left: 20,
//                 child: Container(
//
//                   width: 50,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border:Border.all(color:Colors.white,width: 2),
//                     image: DecorationImage(
//                       image: NetworkImage(fullImageUrl),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//
//         // Padding(
//         //   padding: const EdgeInsets.only(
//         //     right: 180,
//         //   ),
//         //   child: Row(
//         //     mainAxisAlignment: MainAxisAlignment.center,
//         //     children: [
//         //       IconButton(
//         //         icon: Icon(
//         //           widget.post.votes
//         //               ?Icons.favorite
//         //               :Icons.favorite_outline_sharp,
//         //           size: 35,
//         //           color: widget.post.votes ? Colors.red : Colors.black,
//         //         ),
//         //         onPressed: (){
//         //           widget.toggl(widget.post.id);
//         //         },
//         //       ),
//               // IconButton(
//               //   icon: SvgPicture.asset('assets/svgs/comment.svg',
//               //     height: 35,
//               //     width: 35,
//               //   ),
//                 // onPressed: (){
//                 //   Navigator.push(
//                 //       context,
//                 //       MaterialPageRoute(
//                 //         builder: (context) =>
//                 //             CommentsPage(post: widget.post),
//                 //       )
//                 //   );
//                 // },
//
//               // ),
//           //     IconButton(
//           //       icon: SvgPicture.asset('assets/svgs/share.svg',
//           //         height: 27,
//           //         width: 27,
//           //       ),
//           //       onPressed: (){
//           //
//           //       },
//           //
//           //     ),
//           //
//           //   ],
//           //
//           // ),
//         // ),
//         Transform.translate(
//           offset: Offset(160, -50),
//           // child: IconButton(
//           //   icon: Icon(
//           //     widget.post.save
//           //         ? Icons.bookmarks_rounded
//           //         : Icons.bookmarks_outlined,
//           //     size: 35,
//           //   ),
//           //   onPressed: (){
//           //     widget.toggleSave(widget.post.id);
//           //   },
//           // ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(
//             left: 20,
//           ),
//
//           child: Column(
//             // crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Transform.translate(
//                   offset: Offset(0, -40),
//                   child: Column(
//                     children: [
//                       Text(
//                         widget.post.owner.toString(),
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       Text(
//                           widget.post.content,
//                           maxLines: isExpended ? null :2,
//                           overflow: isExpended
//                               ? TextOverflow.visible
//                               : TextOverflow.ellipsis
//                       ),
//                       GestureDetector(
//                         onTap: (){
//                           setState(() {
//                             isExpended = !isExpended;
//                           });
//                         },
//                         child: Text(
//                           isExpended ? 'Show less': 'Continue reading',
//                           style: TextStyle(color: Colors.blue),
//                         ),
//                       ),
//                     ],
//                   )
//
//               )
//
//             ],
//
//           ),
//         ),
//       ],
//     );
//   }
// }
