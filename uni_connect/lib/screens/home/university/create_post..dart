import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  // form key
  final _formKey = GlobalKey<FormState>();

  // post image file object
  File? pickedImage;

  // image error text
  String imageError = '';

  // post description
  String postDescription = '';

  // image identification that it is 360 or not
  bool isImage360 = false;

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
            height: 250,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
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
                      // pop this modal bottom sheet
                      Navigator.pop(context);
                      // show second bottom sheet
                      pickerOptions(context, "Video");
                    },
                    icon: const Icon(Icons.video_file),
                    label: const Text("Upload Video"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text("Cancel"),
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
            height: 250,
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
                      pickImage(ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera),
                    label: const Text("Camera"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      pickImage(ImageSource.gallery);
                    },
                    icon: const Icon(Icons.image),
                    label: const Text("Gallery"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text("Cancel"),
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
        pickedImage = tempImage;
        imageError = '';
      });

      // Close the image picker screen
      Navigator.pop(context);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
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
                                      width: 400.0,
                                      child: pickedImage != null
                                          ? Image.file(
                                              pickedImage!,
                                              width: 170,
                                              height: 170,
                                              fit: BoxFit.contain,
                                            )
                                          // by default image
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
                              Text(imageError,
                                  style: TextStyle(color: Colors.red)),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton.icon(
                                    onPressed: () {
                                      mediaPickerOptions(context);
                                    },
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
                          Text('Description'),

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
                              onChanged: (value) => postDescription = value,
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter description'
                                  : null,
                            ),
                          ),
                        ]))
              ])),
        ));
  }
}
