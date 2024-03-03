import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/post.dart';
import 'package:uni_connect/screens/home/student/post_card.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';

class NewsFeed extends StatefulWidget {
  NewsFeed({required this.stdProfileId});

  // student profile doc id needed by post body
  String stdProfileId;

  @override
  State<NewsFeed> createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  @override
  Widget build(BuildContext context) {
    // consume the following unis list stream
    final followingList = Provider.of<List<dynamic>?>(context);

    // consume the posts stream
    final posts = Provider.of<List<Post>?>(context);

    // print('here');
    // print(followingList); correct
    // print(posts); correct

    // new posts list
    List<Post> feedPosts = [];

    // both stream values are present
    if (followingList != null && posts != null) {
      // make feed posts list
      posts.forEach((post) {
        // if list contains this post's uni id then show this post
        if (followingList.contains(post.uniProfileId)) {
          // add this post in the list
          feedPosts.add(post);
        }
      });
      // print(feedPosts); correct
      // check for each post
      return SingleChildScrollView(
        child: Column(
          children: feedPosts.map((feedPost) {
            // post card
            return PostCard(post: feedPost, stdProfileId: widget.stdProfileId);
          }).toList(),
        ),
      );
    } else {
      return WithinScreenProgress(text: "");
    }
  }
}
