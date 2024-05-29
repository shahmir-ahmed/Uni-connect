import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uni_connect/screens/progress_screen.dart';
import 'package:uni_connect/shared/constants.dart';
import 'package:uni_connect/shared/image_view.dart';
import 'package:video_player/video_player.dart';
import 'package:uni_connect/classes/post.dart';

class EditPost extends StatefulWidget {
  /*
  // post doc id var for updating post
  late String postId;

  // initial post description
  late String postDescription;

  // initial post media type (image/360 image/video)
  late String postMediaType;

  // initial post media (image/360 image/video path)
  late File postMedia;

  // post uni profile doc id var for updating post
  late String uniProfileId;

  // constructor
  UpdatePost(
      {required this.postId,
      required this.postDescription,
      required this.postMediaType,
      required this.postMedia,
      required this.uniProfileId,
      });
      */

  // object of the post to update
  late Post post;

  // contrcuctor to take the post object
  EditPost({required this.post});

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  // form key
  final _formKey = GlobalKey<FormState>();

  // post image file object picked by use
  File? pickedImage;

  // post initial image file object
  File? initialImage;

  // post initial video Uri object
  Uri? initialVideo;

  // post video file object
  File? pickedVideo;

  // image error text
  String fileError = '';

  // post description
  String? postDescription = '';

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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // set value of variable isImage360 as false (in case it is true currently)
                      isImage360 = false;
                      // pop this modal bottom sheet
                      Navigator.pop(context);
                      // show second bottom sheet
                      pickerOptions(context, "Image");
                    },
                    icon: const Icon(Icons.image),
                    label: const Text("Upload Image"),
                    style: mainScreenButtonStyle,
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
                    style: mainScreenButtonStyle,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // pop this modal bottom sheet
                      Navigator.pop(context);
                      // show second bottom sheet
                      pickerOptions(context, "Video");
                    },
                    icon: const Icon(Icons.video_file),
                    label: const Text("Upload Video"),
                    style: mainScreenButtonStyle,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Pic $type From",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
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
                    style: mainScreenButtonStyle,
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
                      style: mainScreenButtonStyle),
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
      final photo = await ImagePicker().pickImage(source: imageType);
      if (photo == null) return;
      final tempImage = File(photo.path);
      // update the image and error variable and notify the widget to update its state using setState
      setState(() {
        pickedImage = tempImage; // set picked image value

        fileError = ''; // clear file error

        // no other media type variable value should be present
        initialVideo =
            null; // set initial video as null which is being shown as current video of post (if there)
        pickedVideo =
            null; // set picked video as null if user already picked a video first which is being shown at the preview

        initialImage =
            null; // set initial image as null b/c new image has been selected now by user so no initial image now
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
        pickedVideo = tempVideo; // set picked video value
        // set video player controller object
        _controller = VideoPlayerController.file(pickedVideo!)
          ..initialize().then((_) {
            setState(() {});
            _controller!.play();
            // _controller!.setLooping(true); // loop
            _controller!.setVolume(0.0); // muted
          });
        fileError = '';
        initialVideo = null; // no initial video now as new video is picked
        pickedImage =
            null; // set picked image as null if user already picked an image first which is being shown at the preview
        initialImage =
            null; // set initial image as null b/c video has been selected now by user so no initial image now
      });

      // Close the video picker screen
      Navigator.pop(context);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /*
    // check what are the initial values of the post and set that to current form
    postDescription = widget.postDescription; // set description
    // check the initial post media type
    if (widget.postMediaType == "simple_image") {
      // simple image is the current media type of post
      initialImage = widget.postMedia;
    } else if (widget.postMediaType == "video") {
      // video is the current media type of post
      pickedVideo = widget.postMedia;
    } else {
      // 360 image is the current media type of post
      initialImage = widget.postMedia;
      isImage360 = true;
    }
    */
    // check what are the initial values of the post and set that to current form
    postDescription = widget.post.description as String; // set description
    // check the initial post media type
    if (widget.post.mediaType == "simple_image") {
      // simple image is the current media type of post
      initialImage = File(widget.post.mediaPath!); // network image file object
      // print(widget.post.mediaPath!); // url is path i.e. https
    } else if (widget.post.mediaType == "video") {
      // video is the current media type of post
      initialVideo =
          Uri.parse(widget.post.mediaPath!); // network video file object
      // set video player controller object
      _controller = VideoPlayerController.networkUrl(initialVideo!)
        ..initialize().then((_) {
          setState(() {});
          _controller!.play(); // play video
          // _controller!.setLooping(true); // loop
          _controller!.setVolume(0.0); // muted
        });
    } else {
      // 360 image is the current media type of post
      initialImage = File(widget.post.mediaPath!); // network image file object
      // print(widget.post.mediaPath!); // url form
      isImage360 = true; // 360 image check
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
          title: const Text('Edit post'),
        ),
        body: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.all(10.0),
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
                                        color: const Color.fromARGB(
                                            255, 218, 218, 218),
                                        width:
                                            MediaQuery.of(context).size.width -
                                                40,
                                        child:
                                            // if video is picked by user then play the video
                                            // pickedVideo != null
                                            // (initialVideo != null || pickedVideo != null)
                                            (_controller != null &&
                                                    (initialVideo != null ||
                                                        pickedVideo !=
                                                            null)) // from initial video and picked video anyone shoudl be present to display the videoplayer
                                                ? AspectRatio(
                                                    aspectRatio: _controller!
                                                        .value.aspectRatio,
                                                    child: VideoPlayer(
                                                        _controller!),
                                                  )
                                                : initialImage != null
                                                    // as initial image is network image so created a sperate object for it to display it
                                                    ? Image.network(
                                                        initialImage!.path,
                                                        width: 170,
                                                        height: 170,
                                                        fit: BoxFit.contain,
                                                      )
                                                    // otherwise if image is picked by user then show the image preview
                                                    : pickedImage != null
                                                        ? isImage360
                                                            ? GestureDetector(
                                                                onTap: () {
                                                                  // show image in image view screen
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => ImageView(
                                                                                assetName: '',
                                                                                isNetworkImage: false,
                                                                                isPanorama: true,
                                                                                file: pickedImage,
                                                                              )));
                                                                },
                                                                child:
                                                                    Image.file(
                                                                  pickedImage!,
                                                                  width: 170,
                                                                  height: 170,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              )
                                                            : GestureDetector(
                                                                onTap: () {
                                                                  // show image in image view screen
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => ImageView(
                                                                                assetName: '',
                                                                                isNetworkImage: false,
                                                                                isPanorama: false,
                                                                                file: pickedImage,
                                                                              )));
                                                                },
                                                                child:
                                                                    Image.file(
                                                                  pickedImage!,
                                                                  width: 170,
                                                                  height: 170,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              )
                                                        : Container() // empty container
                                        ),
                                  ],
                                ),
                              ),
                              // image error
                              Padding(
                                padding: const EdgeInsets.only(left: 9.0),
                                child: Text(fileError,
                                    style: const TextStyle(color: Colors.red)),
                              ),
                              // space
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton.icon(
                                    onPressed: () {
                                      // show options of 360, image, video
                                      mediaPickerOptions(context);
                                    },
                                    style: mainScreenButtonStyle,
                                    icon: const Icon(Icons.add_a_photo_sharp),
                                    label:
                                        const Text('Upload new photo/video')),
                              )
                            ],
                          )),

                          // line break
                          const SizedBox(
                            height: 20.0,
                          ),

                          // post description field label
                          const Text(
                            'Description',
                            style: TextStyle(fontSize: 16.0),
                          ),

                          // line break
                          const SizedBox(
                            height: 5.0,
                          ),

                          // text field for post description
                          TextFormField(
                            minLines: 6,
                            maxLines: 999,
                            initialValue: postDescription,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                                errorBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
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
                          // space
                          const SizedBox(height: 10.0),

                          // post button
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton.icon(
                                  onPressed: () async {
                                    // if image and video is not picked means none of them is chosen if one is chosen then that is not null and whole statement is false
                                    if ((initialImage == null &&
                                            pickedImage == null) &&
                                        (initialVideo == null &&
                                            pickedVideo == null)) {
                                      setState(() {
                                        fileError =
                                            'Please select an image/video';
                                      });
                                    }
                                    // if form is valid and initial image is there/new image / initial video/new video picked is there
                                    if (_formKey.currentState!.validate() &&
                                        ((initialImage != null ||
                                                pickedImage != null) ||
                                            (initialVideo != null ||
                                                pickedVideo != null))) {
                                      Post post; // post class object
                                      // update post
                                      // check type of file uploaded
                                      // if image is picked or initial image is present
                                      if (initialImage != null ||
                                          pickedImage != null) {
                                        // check is image 360 i.e picked
                                        if (isImage360) {
                                          // create post object as media type 360 image
                                          post = Post.withId(
                                              postId: widget.post.postId,
                                              mediaType: '360_image',
                                              mediaPath: initialImage == null
                                                  ? pickedImage!.path
                                                  : initialImage!.path,
                                              description: postDescription);
                                        }
                                        // simple image
                                        else {
                                          // create post object as media type simple image
                                          post = Post.withId(
                                              postId: widget.post.postId,
                                              mediaType: 'simple_image',
                                              mediaPath: initialImage == null
                                                  ? pickedImage!.path
                                                  : initialImage!.path,
                                              description: postDescription);
                                        }
                                      }
                                      // video is picked
                                      else {
                                        // create post object as media type video
                                        post = Post.withId(
                                          postId: widget.post.postId,
                                          mediaType: 'video',
                                          mediaPath: initialVideo == null
                                              ? pickedVideo!.path
                                              : initialVideo!.path,
                                          description: postDescription,
                                        );
                                      }

                                      // show progress screen
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProgressScreen(
                                                      text:
                                                          'Updating post...')));
                                      // update post document with media (if one is new or both is new or none is new) in db
                                      // if the image is not changed means initial image is there which is the same video so update only the post document i.e. description only
                                      // or the video is not changed means initial video is there which is the same video so update only the post document i.e. description only
                                      String? result1, result2;
                                      if (initialImage != null ||
                                          initialVideo != null) {
                                        result1 = post
                                            .updatePostDoc(); // update post document only
                                      } else {
                                        result2 = await post
                                            .updatePost(); // update document and media in storage also
                                      }

                                      // if error occured updating document in db or
                                      // if error occured updating document/ updating media in db
                                      if (result1 == 'error' ||
                                          result2 == 'error') {
                                        print('Error updating post');
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
                                        Navigator.pop(
                                            context); // close progress screen
                                        // close the current update post screen
                                        Navigator.pop(context);
                                        // show snack bar
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Post updated successfully!')),
                                        );
                                      }
                                    }
                                  },
                                  style: mainScreenButtonStyle,
                                  icon: const Icon(Icons.upload),
                                  label: const Text('Update Post')),
                            ),
                          )
                        ]))
              ])),
        ));
  }
}
