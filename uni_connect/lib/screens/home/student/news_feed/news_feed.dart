import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/post.dart';
import 'package:uni_connect/screens/home/student/news_feed/post_card.dart';
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
      // print(feedPosts); // correct
      // show each feed post in post card
      return feedPosts.isNotEmpty
          ? SingleChildScrollView(
              child: Column(
                children: feedPosts.map((feedPost) {
                  // post card (key with every card so that flutter can identify each card when rebuilding the UI)
                  return PostCard(
                      key: ValueKey<String>(feedPost.postId as String),
                      post: feedPost,
                      stdProfileId: widget.stdProfileId);
                }).toList()
                  // Sort the posts based on postCreatedAt
                  ..sort((a, b) =>
                      b.post.postCreatedAt!.compareTo(a.post.postCreatedAt!)),
              ),
            )
          : followingList.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: Text(
                      "Follow universities to see posts in your news feed..."),
                )
              : Text('');
    } else {
      return WithinScreenProgress(text: "Loading news feed...");
    }
  }
}
