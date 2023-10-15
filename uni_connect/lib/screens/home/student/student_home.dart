import 'package:flutter/material.dart';
import 'package:uni_connect/screens/authenticate_student/authenticate_student.dart';
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

  @override
  Widget build(BuildContext context) {
    // _showSnackBar(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Uni-connect'),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
        actions: [
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
        ],
      ),
      body: Center(
        child: Text('Student Home'),
      ),
    );
    ;
  }
}
