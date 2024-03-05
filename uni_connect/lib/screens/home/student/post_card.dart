import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/comment.dart';
import 'package:uni_connect/classes/like.dart';
import 'package:uni_connect/classes/post.dart';
import 'package:uni_connect/classes/university.dart';
import 'package:uni_connect/screens/home/university/post/post_comments.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';
import 'package:uni_connect/shared/image_view.dart';
import 'package:uni_connect/shared/video_player.dart';

class PostCard extends StatefulWidget {
  // constructor
  PostCard({super.key, required this.post, required this.stdProfileId});

  // post object
  Post post;

  // student profile id needed by post body
  String stdProfileId;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
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
                stdProfileId: widget.stdProfileId
              )),
        ),
      ),
    );
  }
}



// Post content class
class PostContent extends StatefulWidget {

  PostContent({required this.post, required this.stdProfileId}); // constructor

  // post type object for post data
  Post post; // post

  // student profile id for showing liked or not liked button and other things below see
  String stdProfileId;

  @override
  State<PostContent> createState() => _PostContentState();
}

class _PostContentState extends State<PostContent> {
  // Declare a variable to hold the mediaPath.
  String? mediaPath;

  // student profile id
  String stdProfileId = '';

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
            if (userId == widget.stdProfileId) {
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
      // column of whole post card
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // post header widget (seperated b/c it will fetch the uni dp and name and show that)
          PostHeader(uniProfileId: widget.post.uniProfileId as String),

          // media container
          Container(
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
                            like!.likedBy!.add(widget.stdProfileId);
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
                            like!.likedBy!.remove(widget.stdProfileId);
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
                              commenterProfileId: widget.stdProfileId,
                              commentByType: 'student',
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
        child: Image(image: NetworkImage(mediaPath!)),
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


// Post header widget
class PostHeader extends StatefulWidget {
  // constructor
  PostHeader({required this.uniProfileId});

  // uni profile id
  String uniProfileId;

  @override
  State<PostHeader> createState() => _PostHeaderState();
}

class _PostHeaderState extends State<PostHeader> {
  // uni profile image
  String profileImage = '';

  // uni name
  String uniName = '';

  // get the uni profile image and name
  _getUniImageAndName() {
    // get image from firebase storage

    // get name from firestore and set the value
    UniveristyProfile.empty()
        .profileCollection
        .doc(widget.uniProfileId)
        .get()
        .then((doc) => setState(() {
              uniName = doc.get("name");
            }));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // get uni image, name
    _getUniImageAndName();
  }

  @override
  Widget build(BuildContext context) {
    // post header row
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // uni name & logo row
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // if there is no profile picture path
            profileImage == ''
                ? CircleAvatar(
                    backgroundImage: AssetImage('assets/uni.jpg'),
                    radius: 20,
                  )
                :
                // if there is profile picture path
                CircleAvatar(
                    foregroundImage: FileImage(
                      File(profileImage),
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
            uniName.length > 33
                ? Text('${uniName.substring(0, 33)}...')
                : Text(uniName),
          ],
        ),
      ],
    );
  }
}