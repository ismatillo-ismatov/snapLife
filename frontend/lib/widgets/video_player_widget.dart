import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:ismatov/widgets/video_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoManager {
  static final VideoManager _instance = VideoManager._internal();
  factory VideoManager() => _instance;
  VideoManager._internal();


  VideoPostState? _currentVideo;

  void register(VideoPostState video) {
    if(_currentVideo != null && _currentVideo != video){
      _currentVideo!.pauseVideo();
    }
    _currentVideo = video;
  }
  void unregister(VideoPostState video) {
    if(_currentVideo == video) {
      _currentVideo = null;
    }

  }
  void pauseAll() {
    _currentVideo?.pauseVideo();
    // _currentVideo = null;
  }
}


class VideoPost extends StatefulWidget {
  final String url;
  final String id;

  const VideoPost({Key? key,required this.url, required this.id});

  @override
  VideoPostState createState() => VideoPostState();
}

class VideoPostState extends State<VideoPost>with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _isVisible = false;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_){
        setState((){});
      });
  }



  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    VideoManager().unregister(this);
    _controller.dispose();
    super.dispose();
  }





  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    if (state != AppLifecycleState.resumed) {
      pauseVideo();
    }
  }

  void pauseVideo() {
    _controller.pause();
  }

  void _playOrPause() {
    if(_isVisible && _controller.value.isInitialized ) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }



  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.id),
      onVisibilityChanged: (VisibilityInfo info) {
        bool visible = info.visibleFraction > 0.5;
        if (visible != _isVisible) {
          setState(() {
            _isVisible = visible;
            if(_isVisible) {
              VideoManager().register(this);
            }
            _playOrPause();
          });
        }
      },
      child: _controller.value.isInitialized
          ? GestureDetector(
        onTap: () {
          setState(() {
            if(_controller.value.isPlaying) {
              _controller.pause();
            } else {
              VideoManager().register(this);
              _controller.play();
            }
          });
        },
          child:  Stack(
            alignment: Alignment.center,
            children: [

                  Container(
                    color: Colors.black,
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                    child: AspectRatio(
                        aspectRatio: 4 / 5,
                      child: VideoPlayer(_controller),
                    ),
                    ),

          //       child: FittedBox(
          //     fit: BoxFit.cover,
          //   child:  SizedBox(
          //     width: _controller.value.size.width,
          //     height: _controller.value.size.height,
          //     child: VideoPlayer(_controller),
          //   ),
          // )
              if(!_controller.value.isPlaying)
                Icon(Icons.play_circle_fill, size: 80, color: Colors.white70),
            ],
          )

      )

          : Center(child: CircularProgressIndicator()),
      );
  }


}
