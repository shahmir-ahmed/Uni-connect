import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_connect/screens/authenticate_university/authenticate_university.dart';
import 'package:uni_connect/screens/main_screen.dart';
import 'package:uni_connect/screens/progress_screen.dart';

class SettingsScreen extends StatelessWidget {
  // const SettingsScreen({super.key});

  // logout function
  Future<void> _logoutUser() async {
    // clear shared pref data for app
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Uni-connect'),
            centerTitle: true,
            backgroundColor: Colors.blue[600],
            actions: [
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
                foregroundColor: MaterialStatePropertyAll(Colors.white),
              ),
              onPressed: () async {
                // ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(content: Text('Logging out...')));

                // show progress screen (in case slow logging out)
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProgressScreen(text: 'Logging out...')));

                // logout user
                await _logoutUser();

                // ScaffoldMessenger.of(context).hideCurrentSnackBar();

                Navigator.pop(context); // pop progress screen
                Navigator.pop(context); // pop settings screen screen
                Navigator.pop(context); // pop home wrapper
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
        ]));
  }
}
