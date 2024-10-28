// import 'dart:async';
// import 'package:chewie/chewie.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
//
// class VideoPlayerWidget extends StatefulWidget {
//   final String videoPath;
//   const VideoPlayerWidget({Key? key, required this.videoPath}) :super(key: key);
//
//   @override
//   _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
// }
//
// class _VideoPlayerWidgetState extends State<VideoPlayerWidget>{
//   VideoPlayerController? _controller;
//   ChewieController? _chewieController;
//   bool _isError = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _videoInit();
//   }
//   void _videoInit(){
//     _controller = widget.videoPath.startsWith('http')
//         ? VideoPlayerController.network(widget.videoPath)
//         : VideoPlayerController.asset(widget.videoPath);
//     _controller?.initialize().then((_){
//       if (mounted){
//         _chewieController = ChewieController(
//           videoPlayerController: _controller!,
//           aspectRatio: _controller!.value.aspectRatio,
//           autoPlay: true,
//           looping: true,
//         );
//         setState((){});
//       }
//     }).catchError((error){
//       setState(() {
//         _isError = true;
//       });
//       print("Video yuklashda xato $error");
//     });
//   }
//   @override
//   Widget build(BuildContext context){
//     if (_isError){
//       return Container(
//         height: 300,
//         color: Colors.black,
//         child: Center(
//           child: Text("Video yuklashda xato",
//             style: TextStyle(color: Colors.red),
//           ),
//         ),
//       );
//     }
//     if (_controller == null || !_controller!.value.isInitialized){
//       return Container(
//         height: 300,
//         color: Colors.black,
//         child: Center(child:CircularProgressIndicator()),
//       );
//     }
//     return Chewie(
//       controller: _chewieController!,
//     );
//   }
// }