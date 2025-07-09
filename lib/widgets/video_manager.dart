// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:visibility_detector/visibility_detector.dart';
// import 'package:ismatov/widgets/video_player_widget.dart';
//
//
// class VideoManager {
//   static final VideoManager _instance = VideoManager._internal();
//   factory VideoManager() => _instance;
//   VideoManager._internal();
//
//
//   _VideoPostState? _currentVideo;
//
//
//   void register(_VideoPostState video) {
//     if(_currentVideo != null && _currentVideo != video){
//       _currentVideo!.pauseVidoe();
//     }
//     _currentVideo = video;
//   }
//   void unregister(_VideoPostState video) {
//     if(_currentVideo = video) {
//       _currentVideo = null;
//     }
//   }
// }
