import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/post.dart';
import 'package:uni_connect/screens/home/university/post/university_post_card.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';

// widget to contain/show all university posts
class UniversityPosts extends StatefulWidget {
  // uni profile id
  String? uniProfileDocId;

  // student profile id
  String? stdProfileId;

  // uni profile image path
  String uniProfileImage;

  // uni name
  String uniName;

  BuildContext?
      homeScreenContext; // Accept context as a parameter // home screen widget context

  // const to get the uni profile id
  UniversityPosts(
      {required this.uniProfileDocId,
      required this.uniProfileImage,
      required this.uniName,
      required this.homeScreenContext});

  UniversityPosts.ForStudent({
    required this.stdProfileId,
    required this.uniProfileDocId,
    required this.uniProfileImage,
    required this.uniName,
  });

  @override
  State<UniversityPosts> createState() => _UniversityPostsState();
}

class _UniversityPostsState extends State<UniversityPosts> {
  // all posts
  List<Post>? posts;

  // all uni posts
  // List<Post>? uniPosts;

  // method to set uni posts as null so that when deleting, updating post, posts shoudl refresh
  /*
  refreshPosts() {
    setState(() {
      uniPosts = null;
    });
    // print('refreshing');
  }
  */

  // build method
  @override
  Widget build(BuildContext context) {
    // consume the stream of all posts and filter out the uni posts using the uni profile id stored in widget
    posts = Provider.of<List<Post>?>(context);

    // print('new posts list: $posts');

    // get the posts of this uni based on the uni profile doc id (only if posts are passed down the stream and not initial data null is there)
    /*
    if (posts != null && uniPosts == null) {
      setState(() {
        uniPosts = posts!
            .where((post) => post.uniProfileId == widget.uniProfileDocId)
            .toList();
      });
    }
    */

    // print('value in posts stream: $posts');

    // print(uniPosts);

    // // get media file of each uni post (not getting here b/c widget not runs again when post media file is set so stays null throughout widget is active until widget is rebuilt so instead of rebuilding all posts only that widget is rebuild in indivdual widget card)
    // for (var uniPost in uniPosts!) {
    //   uniPost.getPostMediaPath();
    //   setState({uniPost.mediaPath = Post.empty().getPostMediaPath() as String});
    // }

    /* Done
    if (posts != null) {
      // add liked by and comments list in each post speed up addition manually
      posts!.forEach((post) {
        post.postsCollection.doc(post.postId).update({
          'post_likes': [],
          'post_comments': [],
        });
      });
    }
    */

    // posts card widget for each post of uni
    return posts == null
        ? WithinScreenProgress(
            text: 'Loading posts',
          )
        // if there are no posts in the list
        // : posts!.isEmpty
        //     ? Container(
        //         // color: Colors.red,
        //         child: Center(
        //           child: Text(
        //             'You have not created any posts yet!',
        //           ),
        //         ),
        //       )
        // university posts
        : SingleChildScrollView(
            child: widget.homeScreenContext != null
                ? Column(
                    children:
                        // University side posts
                        // posts to show, mapping to individual container widget to display
                        posts!
                            .where((post) =>
                                post.uniProfileId == widget.uniProfileDocId)
                            .map((uniPost) => UniPostCard(
                                  key:
                                      UniqueKey(), // because post widget child widgets should be attached
                                  post: uniPost,
                                  profileImage: widget.uniProfileImage,
                                  uniName: widget.uniName,
                                  uniProfileDocId: widget.uniProfileDocId,
                                  homeScreenContext: widget.homeScreenContext,
                                  // refreshPosts: () {
                                  //   setState(() {
                                  //     uniPosts!.remove(uniPost);
                                  //   });
                                  // }
                                ))
                            .toList()
                          // Sort the posts based on postCreatedAt
                          ..sort((a, b) => b.post.postCreatedAt!
                              .compareTo(a.post.postCreatedAt!)))
                : Column(
                    children: posts!
                        .where((post) =>
                            post.uniProfileId == widget.uniProfileDocId)
                        .map((uniPost) => UniPostCard.ForStudent(
                              key:
                                  UniqueKey(),
                              post: uniPost,
                              profileImage: widget.uniProfileImage,
                              uniName: widget.uniName,
                              stdProfileDocId: widget.stdProfileId,
                            ))
                        .toList()
                      // Sort the posts based on postCreatedAt
                      ..sort((a, b) => b.post.postCreatedAt!
                          .compareTo(a.post.postCreatedAt!))),
          );
  }
}
