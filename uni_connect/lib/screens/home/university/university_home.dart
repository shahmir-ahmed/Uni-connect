import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_connect/classes/post.dart';
import 'package:uni_connect/classes/university.dart';
import 'package:uni_connect/screens/home/university/about/edit_profile.dart';
import 'package:uni_connect/screens/home/university/post/create_post.dart';
// import 'package:uni_connect/screens/home/university/post_card.dart';
import 'package:uni_connect/screens/home/university/post/university_posts.dart';
import 'package:uni_connect/screens/home/university/settings/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/screens/home/university/virtual_event/create_virtual_event.dart';
import 'package:uni_connect/screens/progress_screen.dart';
import 'package:uni_connect/shared/constants.dart';
import 'package:permission_handler/permission_handler.dart';

class UniversityHome extends StatefulWidget {
  // String email; // university email

  // const StudentHome({super.key});
  // UniversityHome({required this.email}); // set email

  @override
  State<UniversityHome> createState() => _UniversityHomeState();
}

class _UniversityHomeState extends State<UniversityHome> {
  // selected index of bottom navigation bar
  int _selectedIndex = 1;

  // university profile object
  UniveristyProfile? uniProfile;

  // fields offered count
  int fOcount = 1;

  // uni posts stream
  // Stream<List<Post>?>? postsStream;

  // uni profile image url
  // String? profileImagePath;

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
        // Tab(
        //     icon: Text(
        //   'Live Videos',
        //   style: TextStyle(fontSize: 16.0),
        // )),
        Tab(
            icon: Text(
          'About',
          style: TextStyle(fontSize: 16.0),
        )),
      ]);

  // bottom sheet to choose method to uplaod image
  void _showCreateOptions(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          color: Colors.white,
          height: 150,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // space above
                SizedBox(height: 12.0),
                // create post button
                ElevatedButton.icon(
                  onPressed: () {
                    // pop this create options bottom sheet
                    Navigator.pop(context);
                    // show create post widget
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreatePost(
                                  uniProfileDocId: uniProfile!.profileDocId,
                                  uniName: uniProfile!.name,
                                )));
                  },
                  style: buttonStyle,
                  icon: const Icon(Icons.post_add),
                  label: const Text("Create post"),
                ),
                // space b/w
                SizedBox(height: 5.0),
                // create virtual event button
                ElevatedButton.icon(
                  onPressed: () async {
                    // pop this create options bottom sheet
                    Navigator.pop(context);

                    // show create virtual event screen
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => CreateVirtualEvent(
                    //             )));

                    // check for camera permission
                    await _checkPermissions();
                  },
                  style: buttonStyle,
                  icon: const Icon(Icons.live_tv_outlined),
                  label: const Text("Create virtual event"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // check camera and microphone permission status
  Future<void> _checkPermissions() async {
    // get current status
    PermissionStatus status = await Permission.camera.status;

    // print(status);

    // if status is permanately denied it needs to be enable by user manaually from settings
    if (status.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Permission Required'),
          content: Text(
              'Please allow access to the camera to create virtual event.'),
          actions: [
            TextButton(
              onPressed: () async {
                // Open app settings to allow user to grant the permission manually
                await openAppSettings();
                Navigator.pop(context);
              },
              child: Text('Open Settings'),
            ),
          ],
        ),
      );
    }
    // camera status is denied
    else if (status.isDenied) {
      // Permission hasn't been granted
      // Grant permission
      PermissionStatus status2 = await Permission.camera.request();

      // print(status2);

      // if still denied
      if (!status2.isGranted) {
        // Permission still not granted, show an alert or take appropriate action
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Permission Required'),
            content: Text('Please allow access to the camera.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
      // Permission granted after request, proceed with camera usage
      else if (status2.isGranted) {
        // check microphone permission status
        PermissionStatus status = await Permission.microphone.status;

        // if status is permanately denied it needs to be enable by user manaually from settings
        if (status.isPermanentlyDenied) {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text('Permission Required'),
              content: Text(
                  'Please allow access to the microphone to create virtual event.'),
              actions: [
                TextButton(
                  onPressed: () async {
                    // Open app settings to allow user to grant the permission manually
                    await openAppSettings();
                    Navigator.pop(context);
                  },
                  child: Text('Open Settings'),
                ),
              ],
            ),
          );
        }

        // status is denied
        else if (status.isDenied) {
          // Permission hasn't been granted
          // Grant permission
          PermissionStatus status = await Permission.microphone.request();

          // if still denied
          if (!status.isGranted) {
            // Permission still not granted, show an alert or take appropriate action
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text('Permission Required'),
                content: Text('Please allow access to the microphone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
          // Permission to microphone granted after request
          else if (status.isGranted) {
            // Now show create virtual event widget
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateVirtualEvent(
                          uniProfileId: uniProfile!.profileDocId,
                          uniName: uniProfile!.name,
                        )));
          }
        }
        // Permission already granted, proceed with microphone usage
        else if (status.isGranted) {
          // Code to use the camera
          // show create virtual event screen
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateVirtualEvent(
                        uniProfileId: uniProfile!.profileDocId,
                        uniName: uniProfile!.name,
                      )));
        }
      }
    }
    // Permission already granted, proceed with camera usage
    else if (status.isGranted) {
      // check microphone permission status
      PermissionStatus status = await Permission.microphone.status;

      // if status is permanately denied it needs to be enable by user manaually from settings
      if (status.isPermanentlyDenied) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Permission Required'),
            content: Text(
                'Please allow access to the microphone to create virtual event.'),
            actions: [
              TextButton(
                onPressed: () async {
                  // Open app settings to allow user to grant the permission manually
                  await openAppSettings();
                  Navigator.pop(context);
                },
                child: Text('Open Settings'),
              ),
            ],
          ),
        );
      }

      // status is denied
      if (status.isDenied) {
        // Permission hasn't been granted
        // Grant permission
        PermissionStatus status = await Permission.microphone.request();

        // if still denied
        if (!status.isGranted) {
          // Permission still not granted, show an alert or take appropriate action
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text('Permission Required'),
              content: Text('Please allow access to the microphone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
        // Permission to microphone granted after request
        else if (status.isGranted) {
          // Now show create virtual event widget
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateVirtualEvent(
                        uniProfileId: uniProfile!.profileDocId,
                        uniName: uniProfile!.name,
                      )));
        }
      }
      // Permission already granted, proceed with microphone usage
      else if (status.isGranted) {
        // Code to use the camera
        // show create virtual event screen
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateVirtualEvent(
                      uniProfileId: uniProfile!.profileDocId,
                      uniName: uniProfile!.name,
                    )));
      }
    }
  }

  // load profile image (seperated because need to await for the method so this method will be async)
  _loadProfileImage(imagePath) async {
    var result = await UniveristyProfile.empty()
        .getProfileImagePath(uniProfile!.profileDocId);
    if (result == null) {
      return '';
    } else {
      return result;
    }
  }

  // build method
  @override
  Widget build(BuildContext context) {
    // show welcome message (cannot show error)
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(
    //   SnackBar(
    //       content: Text('Welcome $widget.email!')),
    // );

    // consume the user profile object stream (i.e. get the latest value in the stream from the provider)
    uniProfile = Provider.of<UniveristyProfile?>(context);

    // print(uniProfile!.name);

    // get all the posts stream
    // if posts stream is null
    // if (postsStream == null) {
    //   postsStream = Post.empty().getPostsStream();
    // }

    // print('posts stream: $postsStream'); // present

    // load uni profile id if object is got and image path is not empty
    if (uniProfile != null) {
      if (uniProfile!.profileImage != '') {
        setState(() {
          uniProfile!.profileImage =
              _loadProfileImage(uniProfile!.profileDocId);
        });
      }
    }

    // if stream is setup but theere is no value passed down in the stream yet then show loading
    return uniProfile == null
        ? ProgressScreen(text: 'Loading...')
        : StreamProvider.value(
            value: Post.empty().getPostsStream(),
            initialData: null,
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text('Uni-connect'),
                centerTitle: true,
                backgroundColor: Colors.blue[400],
                actions: [
                  // settings button
                  MaterialButton(
                      onPressed: () {
                        // show settings screen
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingsScreen()));
                      },
                      child: Icon(Icons.settings))
                ],
              ),
              body: DefaultTabController(
                length: 2,
                child: NestedScrollView(
                  scrollDirection: Axis.vertical,
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: Container(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        // uni profile picture
                                        // if there is no profiel picture path
                                        uniProfile!.profileImage == ''
                                            ? CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    'assets/uni.jpg'),
                                                radius: 45,
                                              )
                                            :
                                            // if there is profile picture path
                                            CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    uniProfile!.profileImage),
                                                radius: 45,
                                              ),

                                        // space
                                        SizedBox(
                                          height: 8.0,
                                        ),

                                        // uni name
                                        Text(
                                          '${uniProfile!.name}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Expanded(
                                  // container to give height to expanded widget
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10.0),
                                    // color: Colors.pink,
                                    // height: 120.0,
                                    // column 2 inside row 1
                                    // column 2 for followers and location
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        // space
                                        SizedBox(
                                          height: 15.0,
                                        ),
                                        // folowers column
                                        Container(
                                          margin: EdgeInsets.only(left: 5.0),
                                          // color: Colors.orange,
                                          child: Column(
                                            children: <Widget>[
                                              // uni followers count
                                              Text(
                                                'Followers',
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              // space
                                              SizedBox(
                                                height: 8.0,
                                              ),
                                              // followers count
                                              Text(
                                                uniProfile!.followers.length
                                                    .toString(),
                                                style:
                                                    TextStyle(fontSize: 16.0),
                                              )
                                            ],
                                          ),
                                        ),

                                        // space
                                        SizedBox(
                                          height: 20.0,
                                        ),

                                        // location row
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 18.0),
                                          // color: Colors.pink,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
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
                                                  margin: EdgeInsets.only(
                                                      top: 10.0),
                                                  child: Text(
                                                    '${uniProfile!.location}',
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
                            child: AppBar(
                                backgroundColor: Colors.grey[300],
                                bottom: tabBar),
                          ),

/*
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
                            UniversityPosts(
                                uniProfileImage: uniProfile!.profileImage,
                                uniName: uniProfile!.name,
                                uniProfileDocId: uniProfile!.profileDocId),

                            // second tab bar viiew widget
                            // Container(
                            //   height: 100.0,
                            //   // color: Colors.pink,
                            //   child: Center(
                            //     child: Text(
                            //       'Live videos',
                            //     ),
                            //   ),
                            // ),

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
                      */
                        ]),
                      ),
                    )
                  ],
                  body: TabBarView(
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
                      UniversityPosts(
                          uniProfileImage: uniProfile!.profileImage,
                          uniName: uniProfile!.name,
                          uniProfileDocId: uniProfile!.profileDocId),

                      // second tab bar viiew widget
                      /*
                          Container(
                            height: 100.0,
                            // color: Colors.pink,
                            child: Center(
                              child: Text(
                                'Live videos',
                              ),
                            ),
                          ),
                          */

                      // third tab bar view widget
                      // about tab bar
                      Container(
                        padding: EdgeInsets.all(15.0),
                        // height: 100.0,
                        // color: Colors.orange,
                        // child: Center(
                        //   child: Text(
                        //     'About',
                        //   ),
                        // ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // edit profile button row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // push edit profile screen
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditProfileScreen(
                                                    uniProfile: uniProfile)));
                                  },
                                  child: Text('Edit Profile'),
                                  style: mainScreenButtonStyle,
                                )
                              ],
                            ),

                            // space
                            // SizedBox(height: 4.0,),

                            // name text label
                            Text(
                              'Name:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            // name text
                            Text(uniProfile!.name),

                            // space
                            SizedBox(
                              height: 12.0,
                            ),

                            // decsription label
                            Text(
                              'Description:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            // description
                            Text(uniProfile!.description == ''
                                ? 'Not set'
                                : uniProfile!.description),

                            // space
                            SizedBox(
                              height: 12.0,
                            ),

                            // Location label
                            Text(
                              'Location:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            // location
                            Text(uniProfile!.location),

                            // space
                            SizedBox(
                              height: 12.0,
                            ),

                            // Fields offered label
                            Text(
                              'Fields offered:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            // fields offered
                            uniProfile!.fieldsOffered.length > 0
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: uniProfile!.fieldsOffered.length,
                                    itemBuilder: (context, index) {
                                      return Text(
                                          '${index + 1}. ${uniProfile!.fieldsOffered[index]}');
                                    })
                                : Text('Not set')
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // bottom navigation bar
              bottomNavigationBar: BottomNavigationBar(
                  iconSize: 30.0,
                  selectedFontSize: 16.0,
                  unselectedFontSize: 16.0,
                  backgroundColor: Colors.blue[200],
                  selectedItemColor: const Color.fromARGB(255, 30, 136, 229),
                  selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                  currentIndex: _selectedIndex,
                  onTap: (value) {
                    // setState(() {
                    //   _selectedIndex = value;
                    // });
                    // on create option clicked show create options modal
                    if (value == 0) {
                      _showCreateOptions(context);
                    }
                  },
                  items: [
                    // create button
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.add_circle_outline_sharp,
                        color: Colors.black87,
                      ),
                      label: 'Create',
                    ),

                    // profile button
                    BottomNavigationBarItem(
                      // icon: Image(
                      //   image: AssetImage('assets/arid-logo.jpg'),
                      //   width: 30,
                      //   height: 30,
                      // ),
                      // icon: Icon(
                      //   Icons.account_circle_sharp,
                      //   color: Colors.black87,
                      // ),
                      // based on uni profile image is there or not show avatar
                      icon: uniProfile!.profileImage == ''
                          ? Container(
                              child: CircleAvatar(
                                foregroundImage: AssetImage('assets/uni.jpg'),
                                radius: 15.0,
                              ),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2.0,
                                    color:
                                        const Color.fromARGB(255, 30, 136, 229),
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
                            )
                          : Container(
                              child: CircleAvatar(
                                  foregroundImage:
                                      NetworkImage(uniProfile!.profileImage)),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2.0,
                                    color:
                                        const Color.fromARGB(255, 30, 136, 229),
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
                            ),
                      label: 'Profile',
                      // activeIcon: Image(
                      //   image: AssetImage('assets/arid-logo.jpg'),
                      //   width: 30,
                      //   height: 30,
                      // )
                      // activeIcon: Icon(
                      //   Icons.account_circle_sharp,
                      //   color: Colors.blue[600],
                      // )
                      // activeIcon: uniProfile!.profileImage=='' ? Image.asset('assets/uni.jpg') : Image.network(uniProfile!.profileImage),
                    ),
                  ]),
            ));
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:uni_connect/classes/post.dart';
// import 'package:uni_connect/classes/university.dart';
// import 'package:uni_connect/screens/home/university/post/create_post.dart';
// import 'package:uni_connect/screens/home/university/post/university_posts.dart';
// import 'package:uni_connect/screens/home/university/settings/settings_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:uni_connect/screens/progress_screen.dart';

// class UniversityHome extends StatefulWidget {
//   @override
//   State<UniversityHome> createState() => _UniversityHomeState();
// }

// class _UniversityHomeState extends State<UniversityHome> {
//   int _selectedIndex = 1;
//   UniveristyProfile? uniProfile;
//   TabBar tabBar = TabBar(
//     unselectedLabelColor: Colors.black,
//     labelColor: Colors.blue[500],
//     indicatorColor: Colors.blue[500],
//     tabs: <Tab>[
//       Tab(
//         text: 'Posts',
//       ),
//       Tab(
//         text: 'Live Videos',
//       ),
//       Tab(
//         text: 'About',
//       ),
//     ],
//   );

//   void _showCreateOptions(context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => SingleChildScrollView(
//         child: Container(
//           color: Colors.white,
//           height: 150,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 SizedBox(height: 12.0),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => CreatePost(
//                           uniProfileDocId: uniProfile!.profileDocId,
//                         ),
//                       ),
//                     );
//                   },
//                   icon: const Icon(Icons.post_add),
//                   label: const Text("Create post"),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () {},
//                   icon: const Icon(Icons.event),
//                   label: const Text("Create virtual event"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     uniProfile = Provider.of<UniveristyProfile?>(context);

//     return uniProfile == null
//         ? ProgressScreen(text: 'Loading...')
//         : DefaultTabController(
//             length: 3,
//             child: Scaffold(
//               backgroundColor: Colors.white,
//               appBar: AppBar(
//                 title: Text('Uni-connect'),
//                 centerTitle: true,
//                 backgroundColor: Colors.blue[500],
//                 actions: [
//                   MaterialButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => SettingsScreen(),
//                         ),
//                       );
//                     },
//                     child: Icon(Icons.settings),
//                   )
//                 ],
//               ),
//               body: CustomScrollView(
//                 slivers: [
//                   SliverToBoxAdapter(
//                     child: Column(
//                       children: [
//                         Container(
//                           padding: EdgeInsets.all(10.0),
//                           margin: EdgeInsets.symmetric(vertical: 10.0),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               Expanded(
//                                 child: Container(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     children: <Widget>[
//                                       uniProfile!.profileImage == ''
//                                           ? CircleAvatar(
//                                               backgroundImage:
//                                                   AssetImage('assets/uni.jpg'),
//                                               radius: 45,
//                                             )
//                                           : Image.file(
//                                               File(uniProfile!.profileImage),
//                                               width: 100,
//                                               height: 100,
//                                             ),
//                                       SizedBox(
//                                         height: 8.0,
//                                       ),
//                                       Text(
//                                         '${uniProfile!.name}',
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(fontSize: 16.0),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Container(
//                                   child: Column(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: <Widget>[
//                                       SizedBox(
//                                         height: 15.0,
//                                       ),
//                                       Column(
//                                         children: <Widget>[
//                                           Text(
//                                             'Followers',
//                                             style: TextStyle(
//                                               fontSize: 18.0,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             height: 8.0,
//                                           ),
//                                           Text(
//                                             '260',
//                                             style: TextStyle(fontSize: 16.0),
//                                           ),
//                                         ],
//                                       ),
//                                       SizedBox(
//                                         height: 20.0,
//                                       ),
//                                       Container(
//                                         padding: EdgeInsets.symmetric(
//                                             horizontal: 18.0),
//                                         child: Row(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.center,
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           children: <Widget>[
//                                             Icon(
//                                               Icons.location_on,
//                                               size: 20.0,
//                                             ),
//                                             Expanded(
//                                               child: Container(
//                                                 margin:
//                                                     EdgeInsets.only(top: 10.0),
//                                                 child: Text(
//                                                   '${uniProfile!.location}',
//                                                 ),
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(
//                           height: 50,
//                           child: AppBar(
//                             backgroundColor: Colors.grey[300],
//                             bottom: tabBar,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SliverToBoxAdapter(
//                     child: TabBarView(
//                       children: [
//                         UniversityPosts(
//                           uniProfileImage: uniProfile!.profileImage,
//                           uniName: uniProfile!.name,
//                           uniProfileDocId: uniProfile!.profileDocId,
//                         ),
//                         Center(
//                           child: Text(
//                             'Live videos',
//                           ),
//                         ),
//                         Center(
//                           child: Text(
//                             'About',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               bottomNavigationBar: BottomNavigationBar(
//                 iconSize: 30.0,
//                 selectedFontSize: 16.0,
//                 unselectedFontSize: 16.0,
//                 backgroundColor: Colors.blue[200],
//                 selectedLabelStyle: TextStyle(
//                   color: Colors.blue[900],
//                   fontWeight: FontWeight.bold,
//                 ),
//                 unselectedLabelStyle: TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 currentIndex: _selectedIndex,
//                 onTap: (value) {
//                   if (value == 0) {
//                     _showCreateOptions(context);
//                   }
//                 },
//                 items: [
//                   BottomNavigationBarItem(
//                     icon: Icon(
//                       Icons.add_circle_outline_sharp,
//                       color: Colors.black87,
//                     ),
//                     label: 'Create',
//                     activeIcon: Icon(
//                       Icons.add_circle_outline_sharp,
//                       color: Colors.blue[600],
//                     ),
//                   ),
//                   BottomNavigationBarItem(
//                     icon: uniProfile!.profileImage == ''
//                         ? Container(
//                             child: CircleAvatar(
//                               foregroundImage: AssetImage('assets/uni.jpg'),
//                               radius: 15.0,
//                             ),
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: const Color.fromARGB(255, 30, 136, 229),
//                               ),
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(20.0),
//                               ),
//                             ),
//                           )
//                         : Container(
//                             child: CircleAvatar(
//                               foregroundImage:
//                                   NetworkImage(uniProfile!.profileImage),
//                             ),
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: const Color.fromARGB(255, 30, 136, 229),
//                               ),
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(20.0),
//                               ),
//                             ),
//                           ),
//                     label: 'Profile',
//                   ),
//                 ],
//               ),
//             ),
//           );
//   }
// }
