import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/student.dart';
import 'package:uni_connect/screens/home/student/profile/edit_profile.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';
import 'package:uni_connect/shared/constants.dart';

class StudentProfileScreen extends StatefulWidget {
  StudentProfileScreen(
      {required this.profileImageUrl,
      required this.loadName,
      required this.loadProfileImage});

  // load name and profile image methods in home screen to call when student has updated the profile
  Function loadName;
  Function loadProfileImage;

  // student profile image path/url
  String profileImageUrl;

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  // student profile image path/url
  String profileImage = '';

  String studentProfileId = '';

  // get student profile pic path using profile id to display in the home screen
  loadNewProfileImage() async {
    try {
      final result =
          await StudentProfile.withId(profileDocId: studentProfileId!)
              .getProfileImage();

      if (result == 'error') {
        // if error occured means profile image not present
      } else {
        setState(() {
          profileImage = result;
        });
      }
    } catch (e) {
      print('Error in loadProfileImage: ${e.toString()}');
      return null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // print('inside initstate of student profile'); // called first time not again when something new arrives in strea
    profileImage = widget.profileImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    // consume stream
    final studentProfileObj = Provider.of<StudentProfile?>(context);

    // print('student profile obj: $studentProfileObj');
    // if (studentProfileObj != null) {
    //   print('student profile obj fields: ${studentProfileObj.fieldsOfInterest}');
    // }

    // get the student profile id if the object is present and student id is empty
    if (studentProfileObj != null && studentProfileId.isEmpty) {
      studentProfileId = studentProfileObj.profileDocId;
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: Colors.blue[400],
          actions: [
            // settings button
            // student profile button
            Container(
              margin: EdgeInsetsDirectional.only(end: 10.0),
              // color: Colors.amberAccent,
              // width: 50.0,
              child: MaterialButton(
                minWidth: 10.0,
                highlightElevation: 0.0,
                // splashColor: Colors.blue[400],
                onPressed: () async {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         // show student profile screen with stream supplied to the screen
                  //         builder: (context) => StreamProvider.value(
                  //               initialData: null,
                  //               value: StudentProfile.withId(
                  //                       profileDocId: stdProfileDocId!)
                  //                   .getStudentProfileStream(),
                  //               child: StudentProfileScreen(),
                  //             )));
                },
                child: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                color: Colors.blue[400],
                elevation: 0.0,
                // minWidth: 18.0,
              ),
            )
          ],
        ),
        body: studentProfileObj != null
            ? SingleChildScrollView(
                // main screen container
                child: Container(
                padding: EdgeInsets.all(20.0),
                // main column of screen
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // container
                    Container(
                      padding: EdgeInsets.all(15.0),
                      // student profile image and following count row
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // profile image
                          Container(
                              // padding: EdgeInsets.only(left: 15.0),
                              // if studnet has not set the profile image yet then this will be empty otherwise show image
                              child: profileImage == ""
                                  ? CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/student.jpg'),
                                      radius: 45.0,
                                    )
                                  : CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(profileImage),
                                      radius: 45.0,
                                    )),

                          // following count column
                          Container(
                            padding: EdgeInsets.only(right: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Following',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                // space
                                SizedBox(
                                  height: 12.0,
                                ),
                                // followers count
                                Text(
                                  studentProfileObj.followingUnis.length
                                      .toString(),
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    // space
                    SizedBox(
                      height: 12.0,
                    ),
                    // edit profile button row
                    Container(
                      // margin: EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              // push edit profile screen
                              final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditProfileScreen(
                                            studentProfile: studentProfileObj,
                                            profileImageUrl: profileImage,
                                            loadName: widget.loadName,
                                            loadProfileImage:
                                                widget.loadProfileImage,
                                          )));

                              // print('result $result');
                              if (result == 'not updated') {
                                // do nothing
                              } else {
                                // call method to fetch new profile image from storage
                                loadNewProfileImage();
                              }
                            },
                            label: Text(
                              'Edit Profile',
                              style: TextStyle(fontSize: 13.0),
                            ),
                            icon: Icon(
                              Icons.edit,
                              size: 18.0,
                            ),
                            style: mainScreenButtonStyle,
                          )
                        ],
                      ),
                    ),
                    // student about
                    // name text label
                    Text(
                      'Name: ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),

                    // name text
                    Text(
                      studentProfileObj.name,
                      style: TextStyle(fontSize: 16.0),
                    ),

                    // space
                    SizedBox(
                      height: 12.0,
                    ),

                    // gender label
                    Text(
                      'Gender:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),

                    // gender
                    Text(
                      studentProfileObj.gender == ''
                          ? 'Not set'
                          : studentProfileObj.gender,
                      style: TextStyle(fontSize: 16.0),
                    ),

                    // space
                    SizedBox(
                      height: 12.0,
                    ),

                    // college label
                    Text(
                      'College/High School:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),

                    // college
                    Text(
                      studentProfileObj.college,
                      style: TextStyle(fontSize: 16.0),
                    ),

                    // space
                    SizedBox(
                      height: 20.0,
                    ),

                    // preferences section

                    // pref. label
                    Text(
                      'Preferences:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),

                    // space
                    SizedBox(
                      height: 12.0,
                    ),

                    // Fields offered label
                    Text(
                      'Fields of interest:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),

                    // fields of interest
                    studentProfileObj.fieldsOfInterest.length > 0
                        ? ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount:
                                studentProfileObj.fieldsOfInterest.length,
                            itemBuilder: (context, index) {
                              return Text(
                                '${index + 1}. ${studentProfileObj.fieldsOfInterest[index]}',
                                style: TextStyle(fontSize: 16.0),
                              );
                            })
                        : Text(
                            'Not set',
                            style: TextStyle(fontSize: 16.0),
                          ),
/*
                    // space
                    SizedBox(
                      height: 12.0,
                    ),

                    // Uni locations preferred label
                    Text(
                      'University locations preferred:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),

                    // uni locations preferred
                    studentProfileObj.uniLocationsPreferred.length > 0
                        ? ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount:
                                studentProfileObj.uniLocationsPreferred.length,
                            itemBuilder: (context, index) {
                              return Text(
                                '${index + 1}. ${studentProfileObj.uniLocationsPreferred[index]}',
                                style: TextStyle(fontSize: 16.0),
                              );
                            })
                        : Text(
                            'Not set',
                            style: TextStyle(fontSize: 16.0),
                          ),
                  */
                  ],
                ),
              ))
            : WithinScreenProgress(text: 'Loading profile...'));
  }
}
