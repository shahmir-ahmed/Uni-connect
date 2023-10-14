import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_connect/screens/splash_screen.dart';

// Purpose: to check user is already logged in the app or not and, if yes then which type of user then accordingly show home screen, if not then show main screen
class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  // user signed in already or not
  bool? userSignedIn;
  // email of user signed in already
  String? userEmail;
  // type of user signed in already (student/university)
  String? userType;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser(); // not wait, it will be completed in future, go ahead
  }

  @override
  Widget build(BuildContext context) {
    // if user signed in is null (in start)
    return userSignedIn == null
        // checking
        ? SplashScreen(
            nextScreen: 'none',
          )
        // if user is not signed in
        // wait and keep showing splash screen and after 4 seconds show main screen
        : userSignedIn == false
            ? SplashScreen(nextScreen: 'mainScreen')
            // if user is signed in
            // if user type is still null (in case) when user signed in set to to true
            // : userType == null
            //     ? SplashScreen()
            // if user is signed in
            // check user type then show home screen
            : userType == 'student'
                // wait and keep showing splash screen and after 4 seconds show student home
                ? SplashScreen(nextScreen: 'studentHome')
                : SplashScreen(nextScreen: 'universityHome');
  }

  Future<void> checkUser() async {
    // get the shared preferences instance
    SharedPreferences pref = await SharedPreferences.getInstance();
    // get the shared preferences data
    String? email = pref.getString('userEmail'); // user email
    String? type = pref.getString('userType'); // user type

    // if there is no user already logged in
    if (email == null) {
      setState(() {
        userSignedIn = false;
      });
    }
    // if user is already signed in
    else {
      // set user signed in value and user type to show widget accordingly
      setState(() {
        userSignedIn = true;
        userEmail = email;
        userType = type!;
      });
      // show welcome message to student/uni (after 4 seconds i.e. after splash screen ends)
      Future.delayed(Duration(seconds: 4), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome back $userEmail!')),
        );
      });
    }
  }
}
