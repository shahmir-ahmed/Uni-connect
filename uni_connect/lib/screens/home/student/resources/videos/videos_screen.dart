import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/video.dart';
import 'package:uni_connect/screens/home/student/resources/videos/video_card.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  @override
  Widget build(BuildContext context) {
    // consume all video stream here
    final videosList = Provider.of<List<Video>?>(context);

    return videosList != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: videosList
                .map((video) => VideoCard(videoUrl: video.url!))
                .toList(),
          )
        : WithinScreenProgress.withPadding(text: '', paddingTop: 10.0,);
  }
}
