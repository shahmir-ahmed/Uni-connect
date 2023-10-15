import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_connect/screens/authenticate_university/authenticate_university.dart';
import 'package:uni_connect/screens/main_screen.dart';

class UniversityHome extends StatefulWidget {
  // String email; // university email

  // const StudentHome({super.key});
  // UniversityHome({required this.email}); // set email

  @override
  State<UniversityHome> createState() => _UniversityHomeState();
}

class _UniversityHomeState extends State<UniversityHome> {
  // logout function
  Future<void> _logoutUser() async {
    // clear shared pref data for app
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
  }

  @override
  Widget build(BuildContext context) {
    // show welcome message (cannot call in build function so called in wrapper widget's methods)
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(
    //   SnackBar(
    //       content: Text('Welcome $widget.email!')),
    // );

    return Scaffold(
      appBar: AppBar(
        title: Text('Uni-connect'),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
        actions: [
          ElevatedButton(
              onPressed: () async {

                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logging out...')));

                // logout user
                await _logoutUser();

                ScaffoldMessenger.of(context).hideCurrentSnackBar();

                Navigator.pop(context); // pop home screen
                // push main screen
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MainScreen()));
                // push authenticate university screen with signin true
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AuthenticateUniversity(
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
        child: Text('University Home'),
      ),
    );
  }
}
