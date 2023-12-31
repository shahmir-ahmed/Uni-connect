import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/post.dart';
import 'package:uni_connect/screens/home/university/post/university_post_card.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';

// widget to contain/show all university posts
class UniversityPosts extends StatefulWidget {
  // uni profile id
  String uniProfileDocId;

  // uni profile image path
  String uniProfileImage;

  // uni name
  String uniName;

  // const to get the uni profile id
  UniversityPosts(
      {required this.uniProfileDocId,
      required this.uniProfileImage,
      required this.uniName});

  @override
  State<UniversityPosts> createState() => _UniversityPostsState();
}

class _UniversityPostsState extends State<UniversityPosts> {
  // all posts
  List<Post>? posts;

  // all uni posts
  List<Post>? uniPosts;

  // build method
  @override
  Widget build(BuildContext context) {
    // consume the stream of all posts and filter out the uni posts using the uni profile id stored in widget
    posts = Provider.of<List<Post>?>(context);

    // print('new posts list: $posts');

    // get the posts of this uni based on the uni profile doc id (only if posts are passed down the stream and not initial data null is there)
    if (posts != null && uniPosts == null) {
      setState(() {
        uniPosts = posts!
            .where((post) => post.uniProfileId == widget.uniProfileDocId)
            .toList();
      });
    }

    // print('value in posts stream: $posts');

    // print(uniPosts);

    // // get media file of each uni post (not getting here b/c widget not runs again when post media file is set so stays null throughout widget is active until widget is rebuilt so instead of rebuilding all posts only that widget is rebuild in indivdual widget card)
    // for (var uniPost in uniPosts!) {
    //   uniPost.getPostMediaPath();
    //   setState({uniPost.mediaPath = Post.empty().getPostMediaPath() as String});
    // }

    // posts card widget for each post of uni
    return uniPosts == null
        ? WithinScreenProgress(
            text: 'Loading posts',
          )
        // if there are no university posts in the list
        : uniPosts!.isEmpty
            ? Container(
                // color: Colors.red,
                child: Center(
                  child: Text(
                    'You have not created any posts yet!',
                  ),
                ),
              )
            // university posts
            : SingleChildScrollView(
                child: Column(
                    children:
                        // posts to show, mapping to individual container widget to display
                        uniPosts!
                            .map((uniPost) => UniPostCard(
                                post: uniPost,
                                profileImage: widget.uniProfileImage,
                                uniName: widget.uniName,
                                uniProfileDocId: widget.uniProfileDocId,
                                ))
                            .toList()),
              );
  }
}
