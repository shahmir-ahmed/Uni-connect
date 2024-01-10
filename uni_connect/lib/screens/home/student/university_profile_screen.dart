import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_connect/classes/student.dart';
import 'package:uni_connect/classes/university.dart';
import 'package:uni_connect/screens/home/student/follow_unfollow_button.dart';

class UniProfileScreen extends StatefulWidget {
  // const UniversityProfileScreen({super.key});

  UniProfileScreen({required this.uniProfile});

  // university profile object
  UniveristyProfile? uniProfile;

  @override
  State<UniProfileScreen> createState() => _UniProfileState();
}

class _UniProfileState extends State<UniProfileScreen> {
  // uni posts stream
  // Stream<List<Post>?>? postsStream;

  // student profile doc id from shared pref.
  String? stdProfileDocId;

  // tabs for top navigation bar
  TabBar tabBar = TabBar(
      unselectedLabelColor: Colors.black,
      labelColor: Colors.blue[500],
      indicatorColor: Colors.blue[500],
      tabs: <Tab>[
        Tab(
            icon: Text(
          'Posts',
          style: TextStyle(fontSize: 16.0),
        )),
        Tab(
            icon: Text(
          'Live Videos',
          style: TextStyle(fontSize: 16.0),
        )),
        Tab(
            icon: Text(
          'About',
          style: TextStyle(fontSize: 16.0),
        )),
      ]);

  // get the student's profile doc id from shared pref. and save
  _getStudentProfileDocId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // set state to let the widget tree know and refresh itself that something (data att.) has changed taht it needs to reflect in its tree/view
    setState(() {
      stdProfileDocId = pref.getString("userProfileId");
    });
    print("student profile id: $stdProfileDocId");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // get and save the student profile doc id
    _getStudentProfileDocId();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('University Profile'),
        ),
        body: Container(
          // main body column
          child: Column(children: [
            // top uni details header
            // container for row
            Container(
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.symmetric(vertical: 10.0),
              // width: MediaQuery.of(context).size.width,
              // height: MediaQuery.of(context).size.height /4, // not set this b/c auto height based on the childs content
              // color: Colors.amber,
              // row 1
              // header row
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // column 1 inside row 1
                  // dp and name expanded widget to take the avalaible width i.e. 50% b/c column 2 is also inside expanded width so it also takes up the avalible which is 50%
                  Expanded(
                    // dp and name column
                    child: Container(
                      // color: Colors.blue,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          // uni profile picture
                          // if there is no profiel picture path
                          widget.uniProfile!.profileImage == ''
                              ? CircleAvatar(
                                  backgroundImage: AssetImage('assets/uni.jpg'),
                                  radius: 45,
                                )
                              :
                              // if there is profile picture path
                              Image.file(
                                  File(widget.uniProfile!.profileImage),
                                  width: 100,
                                  height: 100,
                                ),

                          // space
                          SizedBox(
                            height: 8.0,
                          ),

                          // uni name
                          Text(
                            '${widget.uniProfile!.name}',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16.0),
                          ),

                          // location row
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 18.0),
                            // color: Colors.pink,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                // location icon
                                Icon(
                                  Icons.location_on,
                                  size: 20.0,
                                ),
                                // uni location
                                Expanded(
                                  // to wrap location text
                                  child: Container(
                                    margin:
                                        EdgeInsets.only(top: 10.0, right: 10.0),
                                    child: Text(
                                      '${widget.uniProfile!.location}',
                                      // 'Islamabad',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  // column 2 inside row 1
                  // column 2 for followers and location
                  Expanded(
                    // container to give height to expanded widget
                    child: Container(
                      // color: Colors.pink,
                      height: 170.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // space
                          SizedBox(
                            height: 15.0,
                          ),
                          // folowers column
                          Column(
                            children: <Widget>[
                              // uni followers count
                              Text(
                                'Followers',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              // space
                              SizedBox(
                                height: 8.0,
                              ),
                              // followers count
                              Text(
                                '180',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),

                          // space
                          SizedBox(
                            height: 20.0,
                          ),

                          // follow/unfollow button row
                          // not call the get stream function if there is no student profile id valeu
                          stdProfileDocId != null
                              ? StreamProvider.value(
                                  initialData: null,
                                  value: StudentProfile.empty()
                                      .getFollowingUnisStream(stdProfileDocId),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 18.0),
                                    // color: Colors.pink,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        // follow/unfollow button widget
                                        FollowUnFollowButton(
                                            uniProfileId:
                                                widget.uniProfile!.profileDocId,
                                            stdProfileDocId: stdProfileDocId)
                                      ],
                                    ),
                                  ),
                                )
                              :
                              // show empty container if no student profile doc has been fetched from shared pref. yet
                              Container()
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // container for navigation bar and its content
            /*
                                Container(
                    // margin: EdgeInsets.only(top: 80.0),
                    child: DefaultTabController(
                      length: 3,
                      // column to contain tab bar and tab bar views
                      child: Column(
                        children: [
                          // tab bar container
                          Container(
                            color: Colors.grey[300],
                            // top navigation bar (posts - live videos - about)
                            child: tabBar,
                          ),
                          // tab bar view container
                          Container(
                            // Tab bar views
                            child: TabBarView(children: [
                              // posts widget
                              MaterialApp(home: Center(child: Text('Posts'))),
                        
                              // live videos widget
                              MaterialApp(home: Center(child: Text('Live videos'))),
                        
                              // about widget
                              MaterialApp(home: Center(child: Text('About')))
                            ]),
                          )
                        ],
                      ),
                    ),
                                )
                                */

            // the tab bar with the items
            SizedBox(
              height: 50,
              child: AppBar(backgroundColor: Colors.grey[300], bottom: tabBar),
            ),

            // create widgets for each tab bar here
            Expanded(
              child: TabBarView(
                // tab bar views
                children: [
                  // first tab bar view widget
                  // Container(
                  //   color: Colors.red,
                  //   child: Center(
                  //     child: Text(
                  //       'Posts',
                  //     ),
                  //   ),
                  // ),

                  // all uni posts widget
                  // setting the stream here so that posts updation is refkected which was earlier not reflecting due to university posts widget inside tabbarview (no difference)
                  // UniversityPosts(
                  //     uniProfileImage: uniProfile!.profileImage,
                  //     uniName: uniProfile!.name,
                  //     uniProfileDocId: uniProfile!.profileDocId),

                  // first tab bar viiew widget
                  Container(
                    height: 100.0,
                    // color: Colors.pink,
                    child: Center(
                      child: Text(
                        'Posts',
                      ),
                    ),
                  ),

                  // second tab bar viiew widget
                  Container(
                    height: 100.0,
                    // color: Colors.pink,
                    child: Center(
                      child: Text(
                        'Live videos',
                      ),
                    ),
                  ),

                  // third tab bar view widget
                  Container(
                    height: 100.0,
                    // color: Colors.orange,
                    child: Center(
                      child: Text(
                        'About',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
