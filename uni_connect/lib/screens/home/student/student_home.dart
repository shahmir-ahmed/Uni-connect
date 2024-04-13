// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/post.dart';
import 'package:uni_connect/classes/student.dart';
import 'package:uni_connect/screens/authenticate_student/authenticate_student.dart';
import 'package:uni_connect/screens/home/student/news_feed/news_feed.dart';
import 'package:uni_connect/screens/home/student/profile/student_profile.dart';
import 'package:uni_connect/screens/home/student/search/search_screen.dart';
import 'package:uni_connect/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';

class StudentHome extends StatefulWidget {
  // String email; // student email

  // // const StudentHome({super.key});
  // StudentHome({required this.email}); // set email

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  // student profile doc id from shared pref.
  String? stdProfileDocId;

  // Color color = Colors.white;

  // student name
  String stdName = '';

  // student profile image url
  String stdProfileImageUrl = '';

  // logout student function
  Future<void> _logoutUser() async {
    // clear shared pref data for app
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();

    // print('cleared: $cleared'); // true
  }

  // show snack bar
  // void _showSnackBar(context){
  //   // show welcome message to student
  //   ScaffoldMessenger.of(context)
  //       .showSnackBar(
  //     SnackBar(
  //         content: Text('Welcome $widget.email!')),
  //   );
  // }

  // show alert dialog for logout button in drawer menu
  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("No"),
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

        // show snackbar
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Logging out...')));

        // logout user
        await _logoutUser();

        // hide logging out snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        Navigator.pop(context); // pop home screen

        // push main screen
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainScreen()));
        // push authenticate student screen with signin true
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AuthenticateStudent(
                      showSignIn: true,
                    )));
        // logout message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logged out successfully!')),
        );
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      // surfaceTintColor: Colors.white,
      // shadowColor: Colors.white, // elevation colour
      title: Text("Confirm?"),
      content: Text("Are you sure you want to logout?"),
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

  // get the student's profile doc id from shared pref. and save
  _getStudentProfileDocId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // set state to let the widget tree know and refresh itself that something (data att.) has changed that it needs to reflect in its tree/view
    setState(() {
      stdProfileDocId = pref.getString("userProfileId");
    });

    // call load name and profile image
    loadName();
    loadProfileImage();
    // print("student profile id: $stdProfileDocId");
  }

  // get student name using profile id to display in the home screen
  loadName() async {
    try {
      final result2 =
          await StudentProfile.withId(profileDocId: stdProfileDocId!).getName();

      // print('result2 $result2');

      // if name fetching error
      if (result2 == 'error') {
        // if error occured while fetching student name
      } else {
        setState(() {
          stdName = result2;
        });
      }
    } catch (e) {
      print('Error in loadName: ${e.toString()}');
      return null;
    }
  }

  // get student profile pic path using profile id to display in the home screen
  loadProfileImage() async {
    try {
      final result = await StudentProfile.withId(profileDocId: stdProfileDocId!)
          .getProfileImage();

      if (result == 'error') {
        // if error occured means profile image not present
      } else {
        setState(() {
          stdProfileImageUrl = result;
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
    // get and save the student profile doc id
    _getStudentProfileDocId();

    // when user comes back to the news feed it should refresh
    // WidgetsBinding.instance.addObserver(LifecycleEventHandler(
    //     resumeCallBack: () async => setState(() {
    //           print("here");
    //         })));

    // IT DOESNT MATTER WHERE YOU PUT THESE LISTENERS (beacuse notification was also sent when I was at main screen)
    // Moved from here to main because notification was being recived when user logs in and also after that checked where to put the code and main.dart was the correct place
  }

  // refresh the feed
  /*
  Future<void> _refresh() async {
    setState(() {
      print('here')
    });
  }
  */

  // get student profile image and name using profile doc id

  @override
  Widget build(BuildContext context) {
    // print('stdName $stdName');
    // _showSnackBar(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Uni-connect'),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
        actions: [
          // student profile id is present then show button
          stdProfileDocId != null
              ?
              // student profile button
              MaterialButton(
                  minWidth: 10.0,
                  highlightElevation: 0.0,
                  onPressed: () async {
                    // show student profile screen
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            // show student profile screen with stream supplied to the screen
                            builder: (context) => StreamProvider.value(
                                  initialData: null,
                                  value: StudentProfile.withId(
                                          profileDocId: stdProfileDocId!)
                                      .getStudentProfileStream(),
                                  child: StudentProfileScreen(
                                    loadName: loadName,
                                    loadProfileImage: loadProfileImage,
                                    profileImageUrl: stdProfileImageUrl,
                                  ),
                                )));
                  },
                  color: Colors.blue[400],
                  elevation: 0.0,
                  // minWidth: 18.0,
                  // if student image isnot fetched yet then show dummy image
                  child: stdProfileImageUrl == ""
                      ? CircleAvatar(
                          backgroundImage: AssetImage("assets/student.jpg"),
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(stdProfileImageUrl),
                        ))
              : SizedBox()
        ],
      ),
      // News Feed
      // student following unis list stream setup
      body: Center(
          // based on student profile id show news feed or loading screen
          // double stream setup
          child: stdProfileDocId != null
              // following list stream
              ? StreamProvider.value(
                  initialData: null,
                  value: StudentProfile.withId(
                          profileDocId: stdProfileDocId as String)
                      .getFollowingUnisStream(),
                  // all posts stream setup
                  child: StreamProvider.value(
                      value: Post.empty().getPostsStream(),
                      initialData: null,
                      child:
                          NewsFeed(stdProfileId: stdProfileDocId as String)))
              // if no student profile id fetched yet then show loading screen
              : WithinScreenProgress.withHeight(text: "", height: 500.0)),
      // Drawer Menu
      drawer: Drawer(
        width: 280.0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: SingleChildScrollView(
          child: Container(
            // color: Colors.white,
            child: Column(
              children: [
                MyHeaderDrawer(
                  stdName: stdName,
                  stdProfileImageUrl: stdProfileImageUrl,
                ),
                MyDrawerList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Drawer List for drawer menu
  Widget MyDrawerList() {
    return Container(
      // color: Colors.white,
      padding: EdgeInsets.only(
        top: 15,
      ),
      child: Column(
        // shows the list of menu drawer
        children: [
          menuItem("Profile", Icons.account_circle_outlined),
          menuItem("Search", Icons.search_outlined),
          menuItem("My List", Icons.list_alt_outlined),
          Divider(),
          // menuItem("Notifications", Icons.notifications_outlined),
          menuItem("Settings", Icons.settings_outlined),
          menuItem("Logout", Icons.logout_outlined),
        ],
      ),
    );
  }

  // function to return a list item for drawer menu
  Widget menuItem(String title, IconData icon) {
    return Material(
      // color: Colors.transparent,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: InkWell(
        onTap: () async {
          // close the drawer menu
          Navigator.pop(context);

          // if search option is clicked
          if (title == "Search") {
            // if student profile id is fetched then show search screen (for suggestions profile id needed)
            if (stdProfileDocId != null) {
              // show search screen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SearchScreen(
                          stdProfileId: stdProfileDocId!,
                        )),
              );
            }

            // print("result: $result");

            // Check if a result is returned from the search screen
            // if (result == true) {
            // If a result is returned, rebuild the previous screen
            // setState(() {});
            // }
            // pop home screen
            // Navigator.pop(context);
            // rerunning the build method when coming back from the other screen to rerun the descendant widgets i.e. news feed to not glitch and show correct news feed if following list updated or not by following a uni if updated
            // setState(() {
            //   color = Colors.grey;
            // });
          }
          // if logout option is clicked
          else if (title == "Logout") {
            showAlertDialog(context);
          }
          // if profile option is clicked
          else if (title == "Profile") {
            // show student profile screen
            Navigator.push(
                context,
                MaterialPageRoute(
                    // show student profile screen with stream supplied to the screen
                    builder: (context) => StreamProvider.value(
                          initialData: null,
                          value: StudentProfile.withId(
                                  profileDocId: stdProfileDocId!)
                              .getStudentProfileStream(),
                          child: StudentProfileScreen(
                            loadName: loadName,
                            loadProfileImage: loadProfileImage,
                            profileImageUrl: stdProfileImageUrl,
                          ),
                        )));
          }
        },
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  icon,
                  size: 27,
                  color: Colors.black,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Drawer Header i.e. Student Details
class MyHeaderDrawer extends StatefulWidget {
  MyHeaderDrawer({required this.stdName, required this.stdProfileImageUrl});

  // student name
  String stdName = '';

  // student profile image url
  String stdProfileImageUrl = '';

  @override
  _MyHeaderDrawerState createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[700],
      width: double.infinity,
      height: 200,
      padding: EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.stdProfileImageUrl == ""
              ? Container(
                  margin: EdgeInsets.only(bottom: 10),
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/student.jpg'),
                    ),
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(bottom: 10),
                  height: 70,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.stdProfileImageUrl),
                    radius: 40.0,
                  ),
                ),
          Text(
            widget.stdName,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          // Text(
          //   "info@rapidtech.dev",
          //   style: TextStyle(
          //     color: Colors.grey[200],
          //     fontSize: 14,
          //   ),
          // ),
        ],
      ),
    );
  }
}

/*
// for lifecycle call back check
class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback? resumeCallBack;
  final AsyncCallback? suspendingCallBack;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    print("state changed ${state.name}");
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          await resumeCallBack!();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        if (suspendingCallBack != null) {
          await suspendingCallBack!();
        }
        break;
    }
  }
}
*/