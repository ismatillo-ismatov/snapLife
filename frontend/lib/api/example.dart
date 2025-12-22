// if (_isExpanded)
//   Positioned(
//     bottom: 80,
//     child: AnimatedBuilder(
//       animation: _anim,
//       builder: (context, child) {
//         double scale = _anim.value;

//         return SizedBox(
//           width: 230, // piramida kengligi
//           height: 180,
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               // TOP - PHOTO (markaz)
//               Positioned(
//                 top: 0,
//                 left: 90,
//                 child: Transform.scale(
//                   scale: scale,
//                   child: Column(
//                     children: [
//                       FloatingActionButton(
//                         heroTag: "photoBtn",
//                         mini: true,
//                         backgroundColor: Colors.pinkAccent,
//                         onPressed: () => _navigateToCreatePost(PostMediaType.photo),
//                         child: Icon(Icons.photo_camera),
//                       ),
//                       SizedBox(height: 6),
//                       Text("Photo", style: TextStyle(fontSize: 14)),
//                     ],
//                   ),
//                 ),
//               ),

//               // LEFT - VIDEO
//               Positioned(
//                 top: 70,
//                 left: 20,
//                 child: Transform.scale(
//                   scale: scale,
//                   child: Column(
//                     children: [
//                       FloatingActionButton(
//                         heroTag: "videoBtn",
//                         mini: true,
//                         backgroundColor: Colors.blue,
//                         onPressed: () => _navigateToCreatePost(PostMediaType.video),
//                         child: Icon(Icons.videocam),
//                       ),
//                       SizedBox(height: 6),
//                       Text("Video", style: TextStyle(fontSize: 14)),
//                     ],
//                   ),
//                 ),
//               ),

//               // RIGHT - STORY
//               Positioned(
//                 top: 70,
//                 right: 20,
//                 child: Transform.scale(
//                   scale: scale,
//                   child: Column(
//                     children: [
//                       FloatingActionButton(
//                         heroTag: "storyBtn",
//                         mini: true,
//                         backgroundColor: Colors.orange,
//                         onPressed: () => _navigateToCreatePost(PostMediaType.story),
//                         child: Icon(Icons.auto_stories),
//                       ),
//                       SizedBox(height: 6),
//                       Text("Story", style: TextStyle(fontSize: 14)),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     ),
//   ),
