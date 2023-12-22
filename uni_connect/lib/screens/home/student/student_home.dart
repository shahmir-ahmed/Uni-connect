import 'package:flutter/material.dart';
import 'package:uni_connect/screens/authenticate_student/authenticate_student.dart';
import 'package:uni_connect/screens/home/student/search_screen.dart';
import 'package:uni_connect/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentHome extends StatefulWidget {
  // String email; // student email

  // // const StudentHome({super.key});
  // StudentHome({required this.email}); // set email

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  // logout student function
  Future<void> _logoutUser() async {
    // clear shared pref data for app
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
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
      title: Text("Confirm?"),
      content: Text("Are you sure you want to logout?"),
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

  @override
  Widget build(BuildContext context) {
    // _showSnackBar(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uni-connect'),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
        actions: [
          /*
          ElevatedButton(
              onPressed: () async {
                // show snackbar
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Logging out...')));

                // logout user
                await _logoutUser();

                // hide logging out snackbar
                ScaffoldMessenger.of(context).hideCurrentSnackBar();

                Navigator.pop(context); // pop home screen

                // push main screen
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MainScreen()));
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
              child: Icon(Icons.logout))
              */
        ],
      ),
      body: Center(
        child: Text('News Feed - Student Home'),
      ),
      drawer: Drawer(
        width: 280.0,
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                MyHeaderDrawer(),
                MyDrawerList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget MyDrawerList() {
    return Container(
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
          menuItem("Notifications", Icons.notifications_outlined),
          menuItem("Settings", Icons.settings_outlined),
          menuItem("Logout", Icons.logout_outlined),
        ],
      ),
    );
  }

  // function to return a list item for drawer menu
  Widget menuItem(String title, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          // close the drawer menu
          Navigator.pop(context);

          // if search option is clicked
          if (title == "Search") {
            // show search screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          }
          // if logout option is clicked
          else if (title == "Logout") {
            showAlertDialog(context);
          }
        },
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  icon,
                  size: 20,
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
          Container(
            margin: EdgeInsets.only(bottom: 10),
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/student.jpg'),
              ),
            ),
          ),
          Text(
            "Student Name",
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
