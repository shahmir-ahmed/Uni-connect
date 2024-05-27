import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uni_connect/classes/student.dart';
import 'package:uni_connect/screens/progress_screen.dart';
import 'package:uni_connect/shared/constants.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uni_connect/shared/image_view.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen(
      {required this.studentProfile,
      required this.profileImageUrl,
      required this.loadName,
      required this.loadProfileImage});

  // student profile object
  StudentProfile studentProfile;

  // load name and profile image methods in home screen to call when student has updated the profile
  Function loadName;
  Function loadProfileImage;

  // student profile image path/url
  String profileImageUrl;

  // load profile image on previous screen method/return back new url to previous screen

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // fields offered multiple field controllers list
  // List<TextEditingController> listController1 = [];

  // uni locations preferred multiple field controllers list
  // List<TextEditingController> listController2 = [];

  // form attributes
  String stdName = '';
  String stdGender = '';
  String stdCollege = '';
  List<dynamic>? fieldsOfInterest = [];
  List<dynamic> uniLocationsPreferred = [];

  // posssible fields of interest list
  List<String> possibleFieldsOfInterest = [
    "Select field of interest",
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

  // gender list
  List<String> genderList = ["Select gender", "Male", "Female"];

  // profile image file object
  File? pickedImage;
  // image error text
  String fileError = '';

  // form key
  final _formKey = GlobalKey<FormState>();

  // reg exp variable for name, gender field
  static final RegExp nameRegExp = RegExp(r'^[A-Za-z ]+$');

  // show alert dialog for update profile
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
        // if image is not picked then send empty image url
        if (pickedImage == null) {
          result = await StudentProfile.forUpdateProfile(
            profileDocId: widget.studentProfile.profileDocId,
            profileImageUrl: '',
            name: stdName,
            gender: stdGender,
            college: stdCollege,
            fieldsOfInterest: fieldsOfInterest!,
          ).updateProfile();
          // otherwise send picked image path as new image url
        } else {
          result = await StudentProfile.forUpdateProfile(
            profileDocId: widget.studentProfile.profileDocId,
            profileImageUrl: pickedImage!.path,
            name: stdName,
            gender: stdGender,
            college: stdCollege,
            fieldsOfInterest: fieldsOfInterest!,
          ).updateProfile();
        }

        // print('result $result');

        // updated
        if (result == 'success') {
          // if new image is picked
          if (pickedImage != null) {
            // call load profile image method of home screen (after 2 seconds because when this is called no image is present at the location in storage sow ait for the image to upload then call)
            await Future.delayed(Duration(seconds: 2), () {
              widget.loadProfileImage();
            });
          }

          // call load name to load name in the home screen
          widget.loadName();

          // pop loading screen
          Navigator.pop(context);

          if (pickedImage != null) {
            // pop edit profile screen and return new image path
            Navigator.pop(context, 'updated');
          } else {
            // pop edit profile screen with empty image path i.e. image not changed
            Navigator.pop(context, 'not updated');
          }

          // pop profile screen
          // Navigator.pop(context);

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
          // pop edit profile screen
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
/*
    // Pick image
  void pickImage(ImageSource imageType) async {
    try {
      // app crashes if heavy image is selected
      final photo = await ImagePicker().pickImage(source: imageType);
      if (photo == null) return;
      final tempImage = File(photo.path);
      print(photo.path); // jpg file
      // update the image and error variable and notify the widget to update its state using setState
      setState(() {
        pickedImage = tempImage;
    }
  }

  */

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
    /*
    // initialize both lists
    // set text in each fields according to current fields of interest list
    for (var i = 0; i < widget.studentProfile.fieldsOfInterest.length; i++) {
      listController1.add(TextEditingController(
          text: widget.studentProfile.fieldsOfInterest[i]));
    }
    // if fields of interest are initially empty then set a single text field in
    if (widget.studentProfile.fieldsOfInterest.isEmpty) {
      listController1.add(TextEditingController());
    }

    // set text in each fields according to current uni locations pref. list
    for (var i = 0;
        i < widget.studentProfile.uniLocationsPreferred.length;
        i++) {
      listController2.add(TextEditingController(
          text: widget.studentProfile.uniLocationsPreferred[i]));
    }
    // if uni locations pref. are initially empty then set a single text field in
    if (widget.studentProfile.uniLocationsPreferred.isEmpty) {
      listController2.add(TextEditingController());
    }
    */

    // initially set all form values (in case user not changes that field then that field is not saved as empty in the database)
    stdName = widget.studentProfile.name;
    stdGender = widget.studentProfile.gender;
    // if gender is empty first time
    if (stdGender.isEmpty) {
      stdGender = "Select gender";
    }
    stdCollege = widget.studentProfile.college;
    // copy fields of interests list here
    fieldsOfInterest =
        List<String>.from(widget.studentProfile.fieldsOfInterest);

    // print(fieldsOfInterest);

    // if initially empty list then add a dummy field
    if (widget.studentProfile.fieldsOfInterest.isEmpty) {
      // listController.add(TextEditingController());
      fieldsOfInterest!.add("Select field of interest");
    }

    // copy uni locations pref. list here
    // uniLocationsPreferred =
    //     List<String>.from(widget.studentProfile.uniLocationsPreferred);
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.studentProfile.toString());
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
                              (widget.profileImageUrl == '' &&
                                      pickedImage == null)
                                  // then show dummy student image
                                  ? CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/student.jpg'),
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
                                                          assetName:
                                                              '',
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
                                      // otherwise show student actual profile image
                                      : GestureDetector(
                                          onTap: () {
                                            // show image in image view screen
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ImageView(
                                                            assetName: widget
                                                                .profileImageUrl,
                                                            isNetworkImage:
                                                                true,
                                                            isPanorama:
                                                                false)));
                                          },
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                widget.profileImageUrl),
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
                      'Name: ',
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
                      initialValue: widget.studentProfile.name,
                      onChanged: (value) {
                        setState(() {
                          stdName = value.trim();
                        });
                      },
                      validator: (value) {
                        // if name is empty at the time of validation return helper text
                        if (value!.trim().isEmpty) {
                          return 'Please enter name';
                        }
                        // contains characters other than alphabets
                        else if (!nameRegExp.hasMatch(value)) {
                          return 'Please enter valid name';
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

                    // Gender label
                    Text(
                      'Gender: ',
                      style: fieldLabelStyle,
                    ),
                    // space
                    SizedBox(
                      height: 7.0,
                    ),
                    // gender dropdown field
                    DropdownButtonFormField(
                      dropdownColor: Colors.white,
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          fontSize: 16.0),
                      decoration: formInputDecoration,
                      isExpanded: true,
                      value: stdGender,
                      onChanged: (newValue) {
                        setState(() {
                          stdGender = newValue!;
                        });
                      },
                      // show all possible field offered
                      items: genderList.map((gender) {
                        return DropdownMenuItem(
                          child: new Text(gender),
                          value: gender,
                        );
                      }).toList(),
                      validator: (value) {
                        // if 0 index is selected show error
                        if (value == "Select gender") {
                          return "Please select gender";
                        } else {
                          return null;
                        }
                      },
                    ),

                    // space
                    SizedBox(
                      height: 28.0,
                    ),

                    // college name label
                    Text(
                      'College/High School: ',
                      style: fieldLabelStyle,
                    ),
                    // space
                    SizedBox(
                      height: 7.0,
                    ),
                    // college name field
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: formInputDecoration,
                      initialValue: widget.studentProfile.college,
                      onChanged: (value) {
                        setState(() {
                          stdCollege = value.trim();
                        });
                      },
                      validator: (value) {
                        // if college field is empty at the time of validation return helper text
                        if (value!.trim().isEmpty) {
                          return 'Please enter college name';
                        }
                        // valid college name
                        else {
                          return null;
                        }
                      },
                    ),

                    // space
                    SizedBox(
                      height: 28.0,
                    ),

                    // pref. label
                    Text(
                      'Preferences: ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),

                    // space
                    SizedBox(
                      height: 28.0,
                    ),

                    // fields of interest label and add text field button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // fields of interest label
                        Text(
                          'Fields of interest: ',
                          style: fieldLabelStyle,
                        ),

                        // add text field button
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              // add new value as first index's value
                              fieldsOfInterest!.add("Select field of interest");
                            });
                          },
                          icon: Icon(Icons.add),
                          label: Text("Add new field"),
                          style: mainScreenButtonStyle,
                        )
                      ],
                    ),

                    // fields of interest dropdown fields
                    // render when not null
                    fieldsOfInterest != null
                        ? ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            shrinkWrap: true,
                            itemCount: fieldsOfInterest!.length,
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
                                        // style: TextStyle(
                                        //     fontWeight: FontWeight.normal,
                                        //     color: Colors.black,
                                        //     fontSize: 16.0),
                                        decoration: formInputDecoration,
                                        isExpanded: true,
                                        value: fieldsOfInterest![index],
                                        onChanged: (newValue) {
                                          setState(() {
                                            fieldsOfInterest![index] = newValue;
                                          });
                                        },
                                        // show all possible field offered
                                        items: possibleFieldsOfInterest
                                            .map((possibleFieldOffered) {
                                          return DropdownMenuItem(
                                            child:
                                                new Text(possibleFieldOffered),
                                            value: possibleFieldOffered,
                                          );
                                        }).toList(),
                                        validator: (value) {
                                          // if 0 index is selected show error
                                          if (value ==
                                              "Select field of interest") {
                                            return "Please select field of interest ${index + 1}";
                                          }
                                          // if this field offered is already present in fields offered list then show error on both fields
                                          else if (fieldsOfInterest!
                                                  .where((fieldOfInterest) =>
                                                      fieldOfInterest == value)
                                                  .length >
                                              1) {
                                            return 'Field of interest already selected';
                                          }
                                          return null;
                                        },
                                      ),
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
                                                // remove this field offered from fields offered list also
                                                fieldsOfInterest!
                                                    .removeAt(index);
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

                    /*
      
                    // fields of interest label and add text field button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // fields of interest label
                        Text(
                          'Fields of interest: ',
                          style: fieldLabelStyle,
                        ),
      
                        // add text field button
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              // add new input field in list
                              listController1.add(TextEditingController());
                              // add empty element in fields of interest list
                              fieldsOfInterest.add("");
                            });
                          },
                          icon: Icon(Icons.add),
                          label: Text("Add new field"),
                          style: mainScreenButtonStyle,
                        )
                      ],
                    ),
                    // fields of interest fields
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      shrinkWrap: true,
                      itemCount: listController1.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Row(
                            children: [
                              // serial number
                              Container(
                                child: Text(
                                  '${index + 1}.',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              // space
                              SizedBox(
                                width: 20.0,
                              ),
                              // field
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 150,
                                child: TextFormField(
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  controller: listController1[index],
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black))),
                                  onChanged: (value) {
                                    setState(() {
                                      fieldsOfInterest[index] = value.trim();
                                    });
                                  },
                                  validator: (value) {
                                    // if field of interest field is empty at the time of validation return helper text
                                    if (value!.trim().isEmpty) {
                                      return 'Please enter field of interest';
                                    }
                                    // valid field offered
                                    else {
                                      return null;
                                    }
                                  },
                                ),
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
                                          listController1[index].clear();
                                          listController1[index].dispose();
                                          listController1.removeAt(index);
      
                                          // remove this field of interest from fields of interest list also
                                          fieldsOfInterest.removeAt(index);
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
                    ),
                    */

                    /*
                    // space
                    SizedBox(
                      height: 28.0,
                    ),
      
                    // university locations preferred label and add text field button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // university locations preferred label
                        Text(
                          'University locations preferred: ',
                          style: fieldLabelStyle,
                        ),
      
                        // add text field button
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // add new input field in list
                              listController2.add(TextEditingController());
                              // add empty element in university locations preferred list
                              uniLocationsPreferred.add("");
                            });
                          },
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          style: mainScreenButtonStyle,
                        )
                      ],
                    ),
                    // university locations preferred fields
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      shrinkWrap: true,
                      itemCount: listController2.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Row(
                            children: [
                              // serial number
                              Container(
                                child: Text(
                                  '${index + 1}.',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              // space
                              SizedBox(
                                width: 20.0,
                              ),
                              // field
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 150,
                                child: TextFormField(
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  controller: listController2[index],
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black))),
                                  onChanged: (value) {
                                    setState(() {
                                      uniLocationsPreferred[index] = value.trim();
                                    });
                                  },
                                  validator: (value) {
                                    // if university location preferred field is empty at the time of validation return helper text
                                    if (value!.trim().isEmpty) {
                                      return 'Please enter preferred location';
                                    }
                                    // valid field offered
                                    else {
                                      return null;
                                    }
                                  },
                                ),
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
                                          listController2[index].clear();
                                          listController2[index].dispose();
                                          listController2.removeAt(index);
      
                                          // remove this field offered from university locations preferred list also
                                          uniLocationsPreferred.removeAt(index);
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
                    ),
                    */

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
                            if (widget.studentProfile.profileImageUrl == '' &&
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
                              // print(stdName);
                              // print(stdCollege);
                              // print(stdGender);
                              // print(fieldsOfInterest);

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
