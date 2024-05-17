import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Stateful widget to display YouTube video preview
class VideoCard extends StatefulWidget {
  VideoCard({required this.videoUrl});

  // YouTube video URL
  final String videoUrl;

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late YoutubePlayerController _controller;
  late Future<Map<String, String>> _videoDetails;
  String? videoId;

  @override
  void initState() {
    super.initState();
    // Extract video ID from the provided YouTube URL
    videoId = widget.videoUrl.substring(widget.videoUrl.length -
        11); // extract video id from url (source: stackoverflow)

    // Initialize YouTube player controller with the video ID
    _controller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: true,
      ),
    );

    // Fetch video details asynchronously
    _videoDetails = _fetchVideoDetails(videoId!);
  }

  // Function to fetch video details using YouTube player controller
  Future<Map<String, String>> _fetchVideoDetails(String videoId) async {
    /*
// Wait for the controller to be initialized
    _controller.load(videoId);
    await Future.delayed(
        Duration(seconds: 1));
        */ // Give time for metadata to be available

    // Retrieve video title and thumbnail URL from the controller
    final title = _controller.metadata.title;
    final thumbnailUrl = YoutubePlayer.getThumbnail(
      videoId: videoId,
      quality: ThumbnailQuality.high,
    );

    // Return a map with the video title and thumbnail URL
    return {
      'title': title,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  // Function to launch YouTube URL in a web browser or YouTube app
  void _launchURL(BuildContext context, String videoId) async {
    final url = 'https://www.youtube.com/watch?v=$videoId';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _videoDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while fetching video details
          return Container(
              width: MediaQuery.of(context).size.width - 20,
              height: 100.0,
              child: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          // Show error message if an error occurs
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          // Show message if no data is available
          return Center(child: Text('No video data'));
        } else {
          // Extract video data from snapshot and display the preview
          final videoData = snapshot.data!;
          return YouTubeVideoPreview(
            videoId: videoId!, // Use the extracted video ID
            title: videoData['title']!,
            thumbnailUrl: videoData['thumbnailUrl']!,
          );
        }
      },
    );
  }
}

// Stateless widget to display YouTube video preview with title and thumbnail
class YouTubeVideoPreview extends StatelessWidget {
  final String videoId;
  final String title;
  final String thumbnailUrl;

  YouTubeVideoPreview(
      {required this.videoId, required this.title, required this.thumbnailUrl});

  // Function to launch YouTube URL in a web browser or YouTube app
  void _launchURL(BuildContext context, String videoId) async {
    final url = 'https://www.youtube.com/watch?v=$videoId';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 210, 209, 209)),
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      margin: EdgeInsets.symmetric(vertical: 10.0),
      // color: Colors.amber,
      height: 290.0,
      width: MediaQuery.of(context).size.width - 20,
      child: GestureDetector(
        onTap: () => _launchURL(
            context, videoId), // Open YouTube app when preview is clicked
        child: Card(
          elevation: 0.0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width - 30,
                    height: 250,
                    child:
                        Image.network(thumbnailUrl)), // Display video thumbnail
                // Play button icon
                Icon(Icons.play_circle_fill, size: 50, color: Colors.white),
                /*
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title, // Display video title
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                */
              ],
            ),
          ),
        ),
      ),
    );
  }
}
