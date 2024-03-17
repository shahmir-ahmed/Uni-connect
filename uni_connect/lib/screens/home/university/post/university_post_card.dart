import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/comment.dart';
import 'package:uni_connect/classes/like.dart';
import 'package:uni_connect/classes/post.dart';
import 'package:uni_connect/screens/home/university/post/post_comments.dart';
import 'package:uni_connect/screens/home/university/post/update_post.dart';
import 'package:uni_connect/screens/progress_screen.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';
import 'package:uni_connect/shared/image_view.dart';
import 'package:uni_connect/shared/video_player.dart';

// single university post widget
class UniPostCard extends StatefulWidget {
  late Post post; // post

  // uni profile image
  late String? profileImage;

  // uni name
  late String? uniName;

  // uni profile doc id
  late String? uniProfileDocId;

  UniPostCard(
      {required this.post,
      required this.profileImage,
      required this.uniName,
      required this.uniProfileDocId}); // constructor

  @override
  State<UniPostCard> createState() => _UniPostCardState();
}

class _UniPostCardState extends State<UniPostCard> {
  // build method (check: when new post is created and comes back here then posts images are shuffled i.e. agay peche)
  @override
  Widget build(BuildContext context) {
    // print('inside build');
    // if (mediaPath == null) {
    //   // Load the mediaPath when the widget is displayed.
    //   _loadMediaPath();
    // }

    // container of card widget
    // double stream setup
    // likes stream setup
    return StreamProvider.value(
      value: Like.id(docId: widget.post.postId).getLikesStream(),
      initialData: null,
      // comment stream setup
      child: StreamProvider.value(
        value: Comment.id(docId: widget.post.postId).getCommentsStream(),
        initialData: null,
        child: Container(
          // width: MediaQuery.of(context).size.width - 10,
          // height: MediaQuery.of(context).size.height - 380,
          // width: 380.0,
          // height: 380.0,
          padding: const EdgeInsets.all(8.0),
          // main card
          child: Card(
              elevation: 8.0,
              color: Colors.lightBlue,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              // container inside card
              child: PostContent(
                post: widget.post,
                profileImage: widget.profileImage,
                uniName: widget.uniName,
                uniProfileDocId: widget.uniProfileDocId,
              )),
        ),
      ),
    );
  }
}

// Post content class
class PostContent extends StatefulWidget {
  // const PostContent({super.key});
  late Post post; // post

  // uni profile image
  late String? profileImage;

  // uni name
  late String? uniName;

  // uni name
  late String? uniProfileDocId;

  PostContent(
      {required this.post,
      required this.profileImage,
      required this.uniName,
      required this.uniProfileDocId}); // constructor

  @override
  State<PostContent> createState() => _PostContentState();
}

class _PostContentState extends State<PostContent> {
  // Declare a variable to hold the mediaPath.
  String? mediaPath;

  @override
  void initState() {
    super.initState();

    // Load the mediaPath when the widget is initialized.
    _loadMediaPath();
    // print('inside initstate');
  }

  // method to load media path of the post and assign the path and rebuild the card widget when path is fetched
  Future<void> _loadMediaPath() async {
    final mediaPath = await widget.post.getPostMediaPath();
    setState(() {
      this.mediaPath = mediaPath;
    });
  }

  // handle click on three-dot menu of post
  void handleClick(String value) {
    switch (value) {
      case '📝 Edit post':
        // show update post widget populated with this post data
        // show update post screen

        widget.post.mediaPath =
            mediaPath; // set the media path then pass the object
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UpdatePost(post: widget.post)
                // UpdatePost(
                //   postId: widget.post.postId as String,
                //   postDescription: widget.post.description as String,
                //   postMediaType: widget.post.mediaType as String,
                //   postMedia: File(mediaPath!),
                //   uniProfileId: widget.post.uniProfileId as String,
                // )
                ));

        break;
      case '🗑 Delete post':
        showAlertDialog(context); // show alert dialog
        break;
    }
  }

  // show alert dialog for delete post
  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        // close the alert dialog
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        "Yes",
      ),
      onPressed: () async {
        // close the alert dialog
        Navigator.of(context).pop();

        // show progress screen
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProgressScreen(text: 'Deleting post')));

        // call delete post method on this post object
        Post post = widget
            .post; // get the post object into another object here then call

        // call delete post method
        await post.deletePost();

        // pop progress screen
        Navigator.pop(context);

        // show snackbar of success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post deleted!')),
        );
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Confirm?"),
      content: Text("Are you sure you want to delete the post?"),
      actions: [
        continueButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // likes count
  int likesCount = 0;

  // comments count
  int commentsCount = 0;

  // flag to show either the post is liked by the uni or not
  bool liked = false;

  // all loaded flag to represent that the post likes and comments have been loaded or not
  // bool allLoaded = false; // check just to be safe from infinite loop

  @override
  Widget build(BuildContext context) {
    // consume the post likes stream here
    final like = Provider.of<Like?>(
        context); // get the like object from the provider passed down the stream for this post, the object has the list of the users who have liked the post

    final comment = Provider.of<Comment?>(
        context); // get the like object from the provider passed down the stream for this post, the object has the list of the users who have liked the post

    // print("${widget.post.postId}: $like");

    // check the likes exist in the stream provider
    if (like != null) {
      // then check like by list exist on the object
      if (like.likedBy != null) {
        // then count the liked by list items and set count to variable
        // print('here');
        setState(() {
          likesCount = like.likedBy!.length;
          // if the post is liked by the uni then set the flag as true
          like.likedBy!.forEach((userId) {
            if (userId == widget.post.uniProfileId) {
              // && the liked variable is still false
              liked = true;
            }
          });
          // allLoaded = true;
        });
      }
    }

    // check the comment object exist in the stream provider
    if (comment != null) {
      // then check comments list exist on the object
      if (comment.comments != null) {
        // then count the comments items and set count to variable
        // print('here');
        setState(() {
          commentsCount = comment.comments!.length;
        });
      }
    }

    // widget tree
    return Container(
      margin: const EdgeInsets.all(2.0),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          )),
      padding: EdgeInsets.all(15.0),
      // column
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 6.0),
            // color: Colors.pink,
          // post header row
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // uni name & logo row
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // if there is no profiel picture path
                    widget.profileImage == ''
                        ? CircleAvatar(
                            backgroundImage: AssetImage('assets/uni.jpg'),
                            radius: 20,
                          )
                        :
                        // if there is profile picture path
                        CircleAvatar(
                            foregroundImage: FileImage(
                              File(widget.profileImage!),
                              // width: 100,
                              // height: 100,
                            ),
                            radius: 20,
                          ),
                    // gap
                    SizedBox(
                      width: 10.0,
                    ),
                    // uni name text
                    widget.uniName!.length > 28
                        ? Text('${widget.uniName!.substring(0, 28)}...')
                        : Text('${widget.uniName!}'),
                  ],
                ),
                // row inside three dot menu for managing post
                // three dot menu
                PopupMenuButton<String>(
                  color: Colors.white,
                  onSelected: handleClick,
                  itemBuilder: (BuildContext context) {
                    return {'📝 Edit post', '🗑 Delete post'}
                        .map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ),
          // media container
          Container(
            // color: Colors.orange,
            // padding: EdgeInsets.symmetric(vertical: 10.0),
            width: MediaQuery.of(context).size.width - 60,
            height: 200.0,
            // decoration: BoxDecoration(border: Border.all(width: 1.0)),
            child: buildMediaButton(),
          ),
          // space
          SizedBox(
            height: 25.0,
          ),
          // post description
          Text(widget.post.description as String),
          // Text(widget.post.uniProfileId as String),
          // space
          SizedBox(
            height: 20.0,
          ),
          // post number of likes and comments row
          Row(
            children: [
              Expanded(child: Text('❤️ $likesCount')),
              Expanded(child: Text('💬 $commentsCount comments')),
            ],
          ),
          // space
          SizedBox(
            height: 20.0,
          ),
          // divider
          Divider(
            height: 5.0,
            color: Colors.grey,
          ),
          // like and comment row
          Row(
            children: [
              // like button
              Expanded(
                  // based on the post is liked or not by the uni show different button
                  child: liked == false
                      ? ElevatedButton(
                          onPressed: () async {
                            // add the uni profile id in the liked by list of the like object
                            like!.likedBy!.add(widget.post.uniProfileId);
                            // call the like method
                            await like.likePost();
                            // set liked as true
                            setState(() {
                              liked =
                                  true; // b/c liked is already set as true when previously post was liked and then unliked and in liked by list uni profile id does not exists then liked varaible is not set as false again so set here
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '♡',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 27.0),
                              ),
                              Text(
                                ' Like',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 15.0),
                              ),
                            ],
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.white),
                            elevation: MaterialStatePropertyAll(0.0),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            // call the unlike method
                            // remove the uni profile id from the liked by list of the like object of this post
                            like!.likedBy!.remove(widget.post.uniProfileId);
                            // call the ulike method
                            await like.unLikePost();
                            // set liked as false
                            setState(() {
                              liked = false;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '❤️',
                                style: TextStyle(
                                    color: Colors.red, fontSize: 17.0),
                              ),
                              Text(
                                ' Unlike',
                                style: TextStyle(
                                    color: Colors.red, fontSize: 15.0),
                              ),
                            ],
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.white),
                            elevation: MaterialStatePropertyAll(0.0),
                          ),
                        )),
              // comment button
              Expanded(
                  child: ElevatedButton.icon(
                onPressed: () {
                  // show all the comments of post in a comment screen
                  // by passing the comment list to the screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CommentsScreen(
                              commentDocId: widget.post.postId,
                              commenterProfileId: widget.uniProfileDocId,
                              commentByType: 'university',
                            )),
                  );
                },
                icon: Icon(
                  Icons.messenger_outline,
                  color: Colors.grey,
                ),
                label: Text(
                  'Comment',
                  style: TextStyle(color: Colors.grey),
                ),
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.white),
                    elevation: MaterialStatePropertyAll(0.0)),
              )),
            ],
          ),
          // divider
          Divider(
            height: 5.0,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  // Extracted a method for building the media button to improve readability.
  Widget buildMediaButton() {
    // if media path is being currently or error fetching path so '' stored in path
    if (mediaPath == null || mediaPath == '') {
      return WithinScreenProgress.withPadding(
        text: '',
        paddingTop: 50.0,
      );
    }
    // post with video
    else if (widget.post.mediaType == "video") {
      return ElevatedButton(
        onPressed: () {
          // show video player screen on post video clicko
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    VideoView(videoUri: Uri.parse(mediaPath!))),
          );
          // print(mediaPath!);
        },
        child: Image(image: AssetImage('assets/play_video.jpg')),
        style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.white),
            elevation: MaterialStatePropertyAll(0.0)),
      );
    }
    // 360 image post
    else if (widget.post.mediaType == '360_image') {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageView(
                assetName: mediaPath!,
                isNetworkImage: true,
                isPanorama: true,
              ),
            ),
          );
        },
        child: Container(
          child: Column(
            children: [
              // 360 image
              Image(
                image: NetworkImage(mediaPath!),
                width: 170.0,
                height: 170.0,
              ),
              // 360 icon
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Icon(
                  Icons.view_array_rounded,
                  color: Colors.grey,
                ),
              ])
            ],
          ),
        ),
        style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.white),
            elevation: MaterialStatePropertyAll(0.0)),
      );
    }
    // simple image
    else if (widget.post.mediaType == 'simple_image') {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageView(
                assetName: mediaPath!,
                isNetworkImage: true,
                isPanorama: false,
              ),
            ),
          );
        },
        child: Container(
            color: Colors.black, child: Image(image: NetworkImage(mediaPath!))),
        style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.white),
            elevation: MaterialStatePropertyAll(0.0)),
      );
    }
    // if no media type (worst case)
    else {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageView(
                assetName: '',
                isNetworkImage: false,
                isPanorama: false,
              ),
            ),
          );
        },
        child: WithinScreenProgress.withPadding(
          text: '',
          paddingTop: 50.0,
        ),
        style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.white),
            elevation: MaterialStatePropertyAll(0.0)),
      );
    }
  }
}
