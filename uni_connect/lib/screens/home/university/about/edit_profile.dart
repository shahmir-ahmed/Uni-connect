import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uni_connect/classes/university.dart';
import 'package:uni_connect/screens/progress_screen.dart';
import 'package:uni_connect/shared/constants.dart';
import 'package:uni_connect/shared/image_view.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen({required this.uniProfile, required this.loadProfileImage});

  // uni profile object
  UniveristyProfile? uniProfile;

  // load profile image method
  Function loadProfileImage;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // fields offered multiple field controllers list
  // List<TextEditingController> listController = [];
  // List<DropdownButton> listController = [];

  // form attributes
  String name = '';
  String description = '';
  String location = '';
  String type = '';
  List<dynamic>? fieldsOffered = [];

  // profile image file object
  File? pickedImage;
  // image error text
  String fileError = '';

  // posssible fields offered list
  List<String> possibleFieldsOffered = [
    "Select field offered",
    "Medical Sciences",
    "Engineering",
    "Technical",
    "Computer Sciences & Information Technology",
    "Art & Design",
    "Management Sciences",
    "Social Sciences",
    "Biological & Life Sciences",
    "Chemical & Material Sciences",
    "Physics & Numerical Sciences",
    "Earth & Environmental Sciences",
    "Agricultural Sciences",
    "Religious Studies",
    "Media Studies",
    "Commerce / Finance & Accounting"
  ];

  // form key
  final _formKey = GlobalKey<FormState>();

  // reg exp variable for name field
  static final RegExp nameRegExp = RegExp(r'^[A-Za-z ]+$');

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

        // push loading screen
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProgressScreen(text: 'Updating profile...')));

        // result variable
        String result = '';

        // call update profile
        if (pickedImage == null) {
          // if new image is not selected then not update image
          result = await UniveristyProfile.updateProfile(
                  profileDocId: widget.uniProfile!.profileDocId,
                  profileImage: '',
                  name: name,
                  location: location,
                  type: type,
                  description: description,
                  fieldsOffered: fieldsOffered!)
              .updateProfile();
        } else {
          result = await UniveristyProfile.updateProfile(
                  profileDocId: widget.uniProfile!.profileDocId,
                  profileImage: pickedImage!.path,
                  name: name,
                  location: location,
                  type: type,
                  description: description,
                  fieldsOffered: fieldsOffered!)
              .updateProfile();
        }

        // updated
        if (result == 'success') {
          // if new image is picked
          if (pickedImage != null) {
            // call load profile image method of home screen (after 2 seconds because when this is called no image is present at the location in storage sow ait for the image to upload then call)
            await Future.delayed(Duration(seconds: 2), () {
              widget.loadProfileImage();
            });
            // print('update image');
          }
          // pop loading screen
          Navigator.pop(context);

          // pop edit profile screen
          Navigator.pop(context);

          // show snack bar
          // show succes snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated!')),
          );
        } else {
          // show error snackbar
          // show snack bar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Error updating profile. Please try again later!')),
          );
          // pop screen
          Navigator.pop(context);
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Confirm?"),
      content: Text("Are you sure you want to update profile?"),
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

  // select source to upload image i.e. gallery/camera
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
            height: 220,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Pic image from",
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
                    style: mainScreenButtonStyle,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      pickImage(ImageSource.gallery);
                    },
                    icon: const Icon(Icons.image),
                    label: const Text("Gallery"),
                    style: mainScreenButtonStyle,
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
/*
  // Pick image
  void pickImage(ImageSource imageType) async {
    try {
      // app crashes if heavy image is selected
      final photo = await ImagePicker().pickImage(source: imageType);
      if (photo == null) return;
      final tempImage = File(photo.path);
      print(photo.path); // jpg file
      // compress image and then set path
      // update the image and error variable and notify the widget to update its state using setState
      setState(() {
        pickedImage = tempImage;
        fileError = '';
      });

      // Close the image picker screen
      Navigator.pop(context);
    } catch (error) {
      debugPrint(error.toString());
    }
  }
  */

  // flutter_image_compress
  // The flutter_image_compress package is fairly simple to use and it appears to be much better at actually reducing the file size.
  Future<File?> compressFile(File file) async {
    try {
      final filePath = file.absolute.path;

      // Create output file path with .jpg extension
      final outPath =
          "${filePath.substring(0, filePath.lastIndexOf('.'))}_out.jpg";

      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        format: CompressFormat.jpeg, // Ensure the format is set to JPEG
        quality: 25,
      );

      if (result == null) {
        print("Compression failed");
        return null;
      }

      print('Original file size: ${file.lengthSync()} bytes');
      result
          .length()
          .then((value) => print('Compressed file size: ${value} bytes'));

      return File(result.path);
    } catch (e) {
      print("Error in compressing image: $e");
      return null;
    }
  }

  // Pick image
  void pickImage(ImageSource imageType) async {
    try {
      // app crashes if heavy image is selected
      final photo = await ImagePicker().pickImage(source: imageType);
      if (photo == null) return;
      // final tempImage = File(photo.path);
      print('photo.path: ${photo.path}'); // jpg file
      // compress photo using flutter image compress package
      File? tempImage = await compressFile(File(photo.path));
      // if error compressing
      if (tempImage == null) tempImage = File(photo.path);
      // print(photo.path); // jpg file
      print('tempImage.path: ${tempImage.path}');
      // update the image and error variable and notify the widget to update its state using setState
      setState(() {
        pickedImage = tempImage;
        fileError = '';
      });

      // Close the image picker screen
      Navigator.pop(context);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  // show alert dialog for leaving screen
  showAlertDialog2(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Discard"),
      onPressed: () {
        // close the alert dialog
        Navigator.of(context).pop();
        // close the screen
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        "Cancel",
      ),
      onPressed: () async {
        // close the alert dialog
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Discard changes?"),
      content: Text("All changes will be lost"),
      actions: [
        cancelButton,
        continueButton,
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

  // called when back is pressed on the screen
  Future<bool> _onWillPop() async {
    return (await showAlertDialog2(context)) ?? false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initialize list
    // listController. = List.filled(
    //     widget.uniProfile!.fieldsOffered.length, TextEditingController(),
    //     growable: true);
    /*
    // set text in each fields according to current fields offered list
    for (var i = 0; i < widget.uniProfile!.fieldsOffered.length; i++) {
      // listController[i].text = widget.uniProfile!.fieldsOffered[i];
      // listController.add(
      //     TextEditingController(text: widget.uniProfile!.fieldsOffered[i]));
      // listController.add(
      //     DropdownButton());
      // print('here');
    }
    */
    // if fields offered are initially empty then set a single text field in
    /*
    if (widget.uniProfile!.fieldsOffered.isEmpty) {
      // listController.add(TextEditingController());
      fieldsOffered!.add("");
    }
    */
    // print(widget.uniProfile!.fieldsOffered);
    // set field offering text list
    // fieldsOffered = widget.uniProfile!.fieldsOffered;

    // print(fieldsOffered); [Computer Science, Botany, DVM]

    // print('profile pic: ${widget.uniProfile!.profileImage}'); ''

    // print(listController);

    // initially set all form values (in case user not changes that field that field is not saved as empty in the database)
    name = widget.uniProfile!.name;
    description = widget.uniProfile!.description;
    location = widget.uniProfile!.location;
    type = widget.uniProfile!.type;
    // fieldsOffered = widget.uniProfile!.fieldsOffered;
    fieldsOffered = List<String>.from(widget.uniProfile!.fieldsOffered);

    // if initially empty list then add a dummy field
    if (widget.uniProfile!.fieldsOffered.isEmpty) {
      // listController.add(TextEditingController());
      fieldsOffered!.add("Select field offered");
    }

    // print('init');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Edit Profile'),
          backgroundColor: Colors.blue[400],
        ),
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(20.0),
              // form
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // space
                    SizedBox(
                      height: 7.0,
                    ),
                    // profile pic label
                    Text(
                      'Profile picture:',
                      style: fieldLabelStyle,
                    ),
                    // space
                    SizedBox(
                      height: 7.0,
                    ),

                    // space

                    // profile pic and upload button row
                    Container(
                      // color: Colors.orange,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // profile photo upload, preview
                              // if image is not present and no image is picked
                              (widget.uniProfile!.profileImage == '' &&
                                      pickedImage == null)
                                  // then show dummy uni image
                                  ? CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/uni.jpg'),
                                      radius: 60.0,
                                    )
                                  // if image is picked
                                  : pickedImage != null
                                      ?
                                      // then show picked image
                                      GestureDetector(
                                          onTap: () {
                                            // show image in image view screen
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ImageView(
                                                          assetName: '',
                                                          isNetworkImage: false,
                                                          isPanorama: false,
                                                          file: pickedImage,
                                                        )));
                                          },
                                          child: CircleAvatar(
                                            backgroundImage:
                                                FileImage(pickedImage as File),
                                            radius: 60.0,
                                          ),
                                        )
                                      // otherwise show uni actual profile image
                                      : GestureDetector(
                                          onTap: () {
                                            // show image in image view screen
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ImageView(
                                                            assetName: widget
                                                                .uniProfile!
                                                                .profileImage,
                                                            isNetworkImage:
                                                                true,
                                                            isPanorama:
                                                                false)));
                                          },
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(widget
                                                .uniProfile!.profileImage),
                                            radius: 60.0,
                                          ),
                                        ),
                              // space
                              SizedBox(
                                height: 7.0,
                              ),

                              // error
                              Text(
                                fileError,
                                style: TextStyle(color: Colors.red),
                              ),

                              // space
                              SizedBox(
                                height: 7.0,
                              ),
                              // upload button
                              ElevatedButton.icon(
                                  style: mainScreenButtonStyle,
                                  onPressed: () {
                                    mediaPickerOptions(context);
                                  },
                                  icon: Icon(Icons.upload),
                                  label: Text('Upload new picture')),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // space
                    SizedBox(
                      height: 28.0,
                    ),

                    // name label
                    Text(
                      'Name:',
                      style: fieldLabelStyle,
                    ),
                    // space
                    SizedBox(
                      height: 7.0,
                    ),
                    // name field
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: formInputDecoration,
                      initialValue: widget.uniProfile!.name,
                      onChanged: (value) {
                        setState(() {
                          name = value.trim();
                        });
                      },
                      validator: (value) {
                        // if name is empty at the time of validation return helper text
                        if (value!.trim().isEmpty) {
                          return 'Please enter university name';
                        }
                        // contains characters other than alphabets
                        else if (!nameRegExp.hasMatch(value)) {
                          return 'Please enter valid university name';
                        }
                        // valid name
                        else {
                          return null;
                        }
                      },
                    ),

                    // space
                    SizedBox(
                      height: 28.0,
                    ),

                    // description label
                    Text(
                      'Description:',
                      style: fieldLabelStyle,
                    ),
                    // space
                    SizedBox(
                      height: 7.0,
                    ),
                    // description field
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 3,
                      maxLines: 999,
                      decoration: formInputDecoration,
                      initialValue: widget.uniProfile!.description,
                      onChanged: (value) {
                        setState(() {
                          description = value.trim();
                        });
                      },
                      validator: (value) {
                        // if description field is empty at the time of validation return helper text
                        if (value!.trim().isEmpty) {
                          return 'Please enter description';
                        }
                        // valid description
                        else {
                          return null;
                        }
                      },
                    ),

                    // space
                    SizedBox(
                      height: 28.0,
                    ),

                    // location label
                    Text(
                      'Location: ',
                      style: fieldLabelStyle,
                    ),
                    // space
                    SizedBox(
                      height: 7.0,
                    ),
                    // location field
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: formInputDecoration,
                      initialValue: widget.uniProfile!.location,
                      onChanged: (value) {
                        setState(() {
                          location = value.trim();
                        });
                      },
                      validator: (value) {
                        // if location field is empty at the time of validation return helper text
                        if (value!.trim().isEmpty) {
                          return 'Please enter location';
                        }
                        // valid location
                        else {
                          return null;
                        }
                      },
                    ),

                    // space
                    SizedBox(
                      height: 28.0,
                    ),

                    // Type label
                    Text(
                      'Type: ',
                      style: fieldLabelStyle,
                    ),
                    // space
                    SizedBox(
                      height: 7.0,
                    ),
                    // location field
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: formInputDecoration,
                      initialValue: widget.uniProfile!.type,
                      onChanged: (value) {
                        setState(() {
                          type = value.trim();
                        });
                      },
                      validator: (value) {
                        // if location field is empty at the time of validation return helper text
                        if (value!.trim().isEmpty) {
                          return 'Please enter type';
                        }
                        // valid location
                        else {
                          return null;
                        }
                      },
                    ),

                    // space
                    SizedBox(
                      height: 28.0,
                    ),

                    // fields offered label and add text field button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // fields offered label
                        Text(
                          'Fields offered: ',
                          style: fieldLabelStyle,
                        ),

                        // add text field button
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              // listController.add(TextEditingController());
                              // add new value as first index's value
                              fieldsOffered!.add("Select field offered");
                            });
                          },
                          icon: Icon(Icons.add),
                          label: Text("Add new field"),
                          style: mainScreenButtonStyle,
                        )
                      ],
                    ),
                    // fields offered fields
                    // crender when not null
                    fieldsOffered != null
                        // first item should not be empty i.e. when list is empty
                        // ? fieldsOffered![0].isNotEmpty
                        ? ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            shrinkWrap: true,
                            // itemCount: listController.length,
                            itemCount: fieldsOffered!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Row(
                                  children: [
                                    // serial number
                                    Container(
                                      child: Text(
                                        '${index + 1}.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    // space
                                    SizedBox(
                                      width: 20.0,
                                    ),
                                    // field
                                    Container(
                                      width: MediaQuery.of(context).size.width -
                                          150,
                                      child: DropdownButtonFormField(
                                        dropdownColor: Colors.white,
                                        decoration: formInputDecoration,
                                        // padding: EdgeInsets.all(10.0),
                                        isExpanded: true,
                                        // icon: Icon(Icons.arrow_drop_down),
                                        // iconSize: 30,
                                        // underline: SizedBox(),
                                        // hint: Text(
                                        //     'Please select field offered ${index + 1}'), // Not necessary for Option 1
                                        value: fieldsOffered![index],
                                        onChanged: (newValue) {
                                          setState(() {
                                            fieldsOffered![index] = newValue;
                                          });
                                        },
                                        // show all possible field offered
                                        items: possibleFieldsOffered
                                            .map((possibleFieldOffered) {
                                          return DropdownMenuItem(
                                            child:
                                                new Text(possibleFieldOffered),
                                            value: possibleFieldOffered,
                                          );
                                        }).toList(),
                                        validator: (value) {
                                          // if 0 index is selected show error
                                          if (value == "Select field offered") {
                                            return "Please select field offered ${index + 1}";
                                          }
                                          // if this field offered is already present in fields offered list then show error on both fields
                                          else if (fieldsOffered!
                                                  .where((fieldOffered) =>
                                                      fieldOffered == value)
                                                  .length >
                                              1) {
                                            return 'Field offered already selected';
                                          }
                                          return null;
                                        },
                                      ),
                                      /*
                            child: TextFormField(
                              textCapitalization:
                                  TextCapitalization.sentences,
                              controller: listController[index],
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black))),
                              onChanged: (value) {
                                setState(() {
                                  fieldsOffered[index] = value.trim();
                                });
                              },
                              validator: (value) {
                                // if field offered field is empty at the time of validation return helper text
                                if (value!.trim().isEmpty) {
                                  return 'Please enter field offered';
                                }
                                // valid field offered
                                else {
                                  return null;
                                }
                              },
                            ),
                            */
                                    ),
                                    // space
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    // delete field button
                                    index != 0
                                        ? GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                // Clear the error message associated with the deleted field
                                                // _formKey.currentState!.validate();
                                                // listController[index].clear();
                                                // listController[index].dispose();
                                                // listController.removeAt(index);

                                                // remove this field offered from fields offered list also
                                                fieldsOffered!.removeAt(index);
                                              });
                                            },
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.blue,
                                              size: 35,
                                            ),
                                          )
                                        : const SizedBox()
                                  ],
                                ),
                              );
                            },
                          )
                        : SizedBox(),

                    // space
                    SizedBox(
                      height: 27.0,
                    ),

                    // update button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // update button
                        ElevatedButton.icon(
                          onPressed: () async {
                            // check image is empty and image is not selected
                            if (widget.uniProfile!.profileImage == '' &&
                                pickedImage == null) {
                              // set file error
                              setState(() {
                                fileError = 'Please select profile picture';
                              });
                            }
                            // if form is valid
                            if (_formKey.currentState!.validate()) {
                              // update uni profile details
                              // print(pickedImage);
                              // print(name);
                              // print(description);
                              // print(location);
                              // print(type);
                              // print(fieldsOffered);

                              // show alert for confirmation
                              showAlertDialog(context);
                            }
                          },
                          icon: Icon(Icons.done),
                          label: Text('Update profile'),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.blue),
                              foregroundColor:
                                  MaterialStatePropertyAll(Colors.white),
                              maximumSize: MaterialStatePropertyAll(Size(
                                  MediaQuery.of(context).size.width - 100,
                                  200))),
                        )
                      ],
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
