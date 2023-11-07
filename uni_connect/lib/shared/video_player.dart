import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter/material.dart';
import 'package:uni_connect/screens/progress_screen.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';

// enum Source { Asset, Network }

class VideoView extends StatefulWidget {
  VideoView({required this.videoUri});

  // // video path
  // late String videoName;

  // video uri object
  late Uri videoUri;

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late CustomVideoPlayerController _customVideoPlayerController;

  // // video Uri object
  // late Uri videoUri;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // get the video download url and when got then set the uri object value and initialize video player
    // downloadVideo().then((videoURL) {
    //   videoUri = Uri.parse(videoURL);
    //   initializeVideoPlayer();
    // });
    initializeVideoPlayer();
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    super.dispose();
  }

/*
  // function to get the download url of video
  Future<String> downloadVideo() async {
    try {
      // final FirebaseStorage storage = FirebaseStorage.instance;
      // print(widget.videoPath);
      final videoRef = storage.FirebaseStorage.instance
          .ref()
          .child('post_media')
          .child(widget
              .videoName); // get the video file ref at the location with the name of video
      // final Reference videoRef = storage.ref('post_media/');
      final String videoURL = await videoRef
          .getDownloadURL(); // get the donwload/playable url of video

      print("video url: $videoURL");

      return videoURL;
    } catch (e) {
      print("Err in downloadVideo: ${e.toString()}");
      return '';
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? PoppableProgressScreen.withBgColorBlack(text: 'Loading video...')
          : Container(
              // height: MediaQuery.of(context).size.height,
              // width: MediaQuery.of(context).size.width,
              color: Colors.black,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomVideoPlayer(
                    customVideoPlayerController: _customVideoPlayerController,
                  ),
                  // _sourceButtons(),
                ],
              ),
            ),
    );
  }

  /*Widget _sourceButtons() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MaterialButton(
          color: Colors.red,
          child: const Text(
            "Network",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          onPressed: () {
            setState(() {
              currentSource = Source.Network;
              initializeVideoPlayer(currentSource);
            });
          },
        ),
        MaterialButton(
          color: Colors.red,
          child: const Text(
            "Asset",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          onPressed: () {
            setState(() {
              currentSource = Source.Asset;
              initializeVideoPlayer(currentSource);
            });
          },
        ),
      ],
    );
  }*/

  void initializeVideoPlayer() {
    try {
      setState(() {
        isLoading = true;
      });
      VideoPlayerController _videoPlayerController;
      _videoPlayerController = VideoPlayerController.networkUrl(widget.videoUri)
        ..initialize().then((value) {
          setState(() {
            isLoading = false;
          });
        });
      _customVideoPlayerController = CustomVideoPlayerController(
          context: context, videoPlayerController: _videoPlayerController);
    } catch (e) {
      print(e.toString());
    }
  }
}
