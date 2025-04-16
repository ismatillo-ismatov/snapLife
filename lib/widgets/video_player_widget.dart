import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SimpleVideoPlayer extends StatefulWidget {
  @override
  _SimpleVideoPlayerState createState() => _SimpleVideoPlayerState();
}

class _SimpleVideoPlayerState extends State<SimpleVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    );

    try {
      await _controller.initialize();
      setState(() {});
    } catch (error) {
      print("Video yuklashda xatolik yuz berdi: $error");
      // Foydalanuvchiga xabar bering
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Video yuklashda xatolik yuz berdi: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Oddiy Video Pleer")),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
              _isPlaying = false;
            } else {
              _controller.play();
              _isPlaying = true;
            }
          });
        },
        child: Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// import 'package:chewie/chewie.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
//
// class VideoPlayerWidget extends StatefulWidget {
//   final String videoUrl;
//
//   const VideoPlayerWidget({required this.videoUrl, Key? key}) : super(key:key);
//
//   @override
//   _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
// }
//
// class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
//   late VideoPlayerController _videoPlayerController;
//   ChewieController? _chewieController;
//
//   @override
//   void initState(){
//     super.initState();
//     initializeVideoPlayer();
//   }
//   void initializeVideoPlayer() {
//     String videoUrl = "${widget.videoUrl}?t=${DateTime.now().millisecondsSinceEpoch}";
//     _videoPlayerController = VideoPlayerController.network(videoUrl)
//   ..initialize().then((_) {
//       setState(() {
//         _chewieController = ChewieController(
//           videoPlayerController: _videoPlayerController,
//           autoPlay: true,
//           looping: true,
//           showControls: true,
//           allowFullScreen: true,
//           materialProgressColors: ChewieProgressColors(
//             playedColor: Colors.blue,
//             handleColor: Colors.blueAccent,
//             backgroundColor: Colors.grey,
//           ),
//         );
//       });
//     }).catchError((error) {
//      print("Video yuklashda xatolik: $error");
//      if(!mounted) return;
//      setState(() {
//        _chewieController = null;
//      });
//      _videoPlayerController.dispose();
//   });
//         }
//
//
//   @override
//   void dispose(){
//     _videoPlayerController.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return _videoPlayerController.value.isInitialized && _chewieController != null
//         ? Chewie(controller: _chewieController!)
//     : Center(child:  CircularProgressIndicator());
//   }
//
//   }
