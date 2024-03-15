import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uni_connect/screens/progress_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:uni_connect/classes/post.dart';

class CreatePost extends StatefulWidget {
  // const CreatePost({super.key});

  // uni profile doc id var for creating profile
  String uniProfileDocId;

  // constructor
  CreatePost({required this.uniProfileDocId});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  // firebase messaging object
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // form key
  final _formKey = GlobalKey<FormState>();

  // post image file object
  File? pickedImage;

  // post video file object
  File? pickedVideo;

  // image error text
  String fileError = '';

  // post description
  String postDescription = '';

  // image identification that it is 360 or not
  bool isImage360 = false;

  // Video player controller object
  VideoPlayerController? _controller;

  // bottom sheet to choose method to uplaod image
  void mediaPickerOptions(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          child: Container(
            color: Colors.white,
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // set value of variable isImage360
                      isImage360 = false;
                      // pop this modal bottom sheet
                      Navigator.pop(context);
                      // show second bottom sheet
                      pickerOptions(context, "Image");
                    },
                    icon: const Icon(Icons.image),
                    label: const Text("Upload Image"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // set value of variable isImage360
                      isImage360 = true;
                      // pop this modal bottom sheet
                      Navigator.pop(context);
                      // show second bottom sheet
                      pickerOptions(context, "360° Image");
                    },
                    icon: const Icon(Icons.image_outlined),
                    label: const Text("Upload 360° Image"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // set value of variable isImage360
                      isImage360 = false;
                      // pop this modal bottom sheet
                      Navigator.pop(context);
                      // show second bottom sheet
                      pickerOptions(context, "Video");
                    },
                    icon: const Icon(Icons.video_file),
                    label: const Text("Upload Video"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // bottom sheet to choose method to upload image/360 image/video
  void pickerOptions(context, String type) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          child: Container(
            color: Colors.white,
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Pic $type From",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // if selected media type is video then call pick video otherwise image
                      type == "Video"
                          ? pickVideo(ImageSource.camera)
                          : pickImage(ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera),
                    label: const Text("Camera"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // if selected media type is video then call pick video otherwise image
                      type == "Video"
                          ? pickVideo(ImageSource.gallery)
                          : pickImage(ImageSource.gallery);
                    },
                    icon: const Icon(Icons.image),
                    label: const Text("Gallery"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Pick image
  void pickImage(ImageSource imageType) async {
    try {
      // app crashes if heavy image is selected
      final photo = await ImagePicker().pickImage(source: imageType);
      if (photo == null) return;
      final tempImage = File(photo.path);
      // print(photo.path); // jpg file
      // update the image and error variable and notify the widget to update its state using setState
      setState(() {
        pickedImage = tempImage;
        fileError = '';
        pickedVideo =
            null; // set picked video as null if user already picked a video first which is being shown at the preview
      });

      // Close the image picker screen
      Navigator.pop(context);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  // Pick video
  void pickVideo(ImageSource videoType) async {
    try {
      final video = await ImagePicker().pickVideo(source: videoType);
      if (video == null) return;
      final tempVideo = File(video.path);
      // update the preview by the selected video and error variable and notify the widget to update its state using setState
      setState(() {
        pickedVideo = tempVideo;
        // print(pickedVideo!.path); // mp4 file
        // set video player controller object
        _controller = VideoPlayerController.file(pickedVideo!) // plays mp4 file
          ..initialize().then((_) {
            setState(() {});
            _controller!.play();
            // _controller!.setLooping(true); // loop
            _controller!.setVolume(0.0); // muted
          });
        fileError = '';
        pickedImage =
            null; // set picked image as null if user already picked an image first which is being shown at the preview
      });

      // Close the video picker screen
      Navigator.pop(context);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  // send notification to followers
  void _sendNotification() async {
    try {
      // Sending message payload
      Map<String, dynamic> message = {
        "notification": {
          "title": "New Post Uploaded",
          "body": "Check out the latest post!"
        },
        "topic": "followers" // Topic to which the notification will be sent
      };

      // Send the notification
      // await _firebaseMessaging.

      print("Notification sent successfully!");
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  // build method
  @override
  Widget build(BuildContext context) {
    // consume the university profile stream here also (for uni post creation with uni profile id)
    // final uniProfile = Provider.of<UniveristyProfile?>(context);

    // if (uniProfile != null) {
    //   uniProfileDocId = uniProfile.profileDocId;
    // } // cannot be consumed because create post widget is not child widget of home wrappaer which is providing the stream of uni profile object which is only avalaible to descendants i.e. child widgets

    // print("uni profile doc id: ${widget.uniProfileDocId}");

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue[500],
          title: Text('Create new post'),
        ),
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(10.0),
              // body widgets in a column
              child: Column(children: [
                // main form
                Form(
                    key: _formKey,
                    // form fields in a column
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // show post image/video here
                          Container(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(
                                height: 50,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Stack(
                                  children: [
                                    Container(
                                      // color: Colors.pink,
                                      width: MediaQuery.of(context).size.width -
                                          40,
                                      child:
                                          // if video is picked by user then play the video
                                          pickedVideo != null
                                              ? AspectRatio(
                                                  aspectRatio: _controller!
                                                      .value.aspectRatio,
                                                  child:
                                                      VideoPlayer(_controller!),
                                                )
                                              :
                                              // if image is picked by user the show the image preview
                                              pickedImage != null
                                                  ? Image.file(
                                                      pickedImage!,
                                                      width: 170,
                                                      height: 170,
                                                      fit: BoxFit.contain,
                                                    )
                                                  // by default image (if both image and video is not picked by user initially)
                                                  : Image(
                                                      image: AssetImage(
                                                          'assets/camera.jpg'),
                                                      width: 170,
                                                      height: 170,
                                                      fit: BoxFit.contain,
                                                    ),
                                    ),
                                  ],
                                ),
                              ),
                              // image error
                              Text(fileError,
                                  style: TextStyle(color: Colors.red)),
                              // space
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton.icon(
                                    onPressed: () {
                                      mediaPickerOptions(context);
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStatePropertyAll(Colors.blue),
                                      foregroundColor: MaterialStatePropertyAll(
                                          Colors.white),
                                    ),
                                    icon: const Icon(Icons.add_a_photo_sharp),
                                    label: const Text('Upload Photo/Video')),
                              )
                            ],
                          )),

                          // line break
                          SizedBox(
                            height: 20.0,
                          ),

                          // post description field label
                          Text(
                            'Description',
                            style: TextStyle(fontSize: 16.0),
                          ),

                          // line break
                          SizedBox(
                            height: 5.0,
                          ),

                          // text field for post description
                          SizedBox(
                            height: 180.0,
                            child: TextFormField(
                              maxLines: null,
                              expands: true,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                  errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                      borderSide: BorderSide(
                                          color:
                                              Color.fromARGB(255, 88, 88, 88))),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)))),
                              onChanged: (value) {
                                setState(() {
                                  postDescription = value.trim();
                                });
                              },
                              validator: (value) => value!.trim().isEmpty
                                  ? 'Please enter description'
                                  : null,
                            ),
                          ),
                          // space
                          SizedBox(height: 10.0),

                          // post button
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton.icon(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStatePropertyAll(Colors.blue),
                                    foregroundColor:
                                        MaterialStatePropertyAll(Colors.white),
                                  ),
                                  onPressed: () async {
                                    // if image and video is not picked
                                    if (pickedImage == null &&
                                        pickedVideo == null) {
                                      setState(() {
                                        fileError =
                                            'Please select an image/video';
                                      });
                                    }
                                    // if form is valid and image/video is picked
                                    if (_formKey.currentState!.validate() &&
                                        (pickedImage != null ||
                                            pickedVideo != null)) {
                                      Post post; // post class object
                                      // upload post
                                      // check type of file uploaded
                                      // if image is picked
                                      if (pickedImage != null) {
                                        // check is image 360 i.e picked
                                        if (isImage360) {
                                          // create post object as media type 360 image
                                          post = Post.withUniId(
                                              mediaType: '360_image',
                                              mediaPath: pickedImage!.path,
                                              description: postDescription,
                                              uniProfileId:
                                                  widget.uniProfileDocId);
                                        }
                                        // simple image
                                        else {
                                          // create post object as media type simple image
                                          post = Post.withUniId(
                                              mediaType: 'simple_image',
                                              mediaPath: pickedImage!.path,
                                              description: postDescription,
                                              uniProfileId:
                                                  widget.uniProfileDocId);
                                        }
                                      }
                                      // video is picked
                                      else {
                                        // create post object as media type 360 image
                                        post = Post.withUniId(
                                            mediaType: 'video',
                                            mediaPath: pickedVideo!.path,
                                            description: postDescription,
                                            uniProfileId:
                                                widget.uniProfileDocId);
                                      }

                                      // show progress screen
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProgressScreen(
                                                      text:
                                                          'Publishing post...')));

                                      // create new post document with media in db
                                      // String? result;
                                      String? result = await post.createPost();

                                      // if error occured creating document/ saving media in db
                                      if (result == 'error') {
                                        print('Error creating new post');
                                        Navigator.pop(
                                            context); // close progress screen
                                        // show snack bar
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Something went wrong! Please try again later.')),
                                        );
                                      }
                                      // post doc and image/video saved in db
                                      else {
                                        // send notifications to all the users who are subscribed to profileId_followers topic


                                        Navigator.pop(
                                            context); // close progress screen
                                        // close the current create post screen
                                        Navigator.pop(context);
                                        // show snack bar
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Post published successfully!')),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.upload),
                                  label: const Text('Publish Post')),
                            ),
                          )
                        ]))
              ])),
        ));
  }
}
