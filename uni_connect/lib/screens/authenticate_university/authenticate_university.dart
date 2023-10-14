import 'package:flutter/material.dart';
import 'package:uni_connect/screens/authenticate_university/login_university.dart';
import 'package:uni_connect/screens/authenticate_university/register_university.dart';

class AuthenticateUniversity extends StatefulWidget {
  // variable to display either login/register widget
  late bool
      showSignIn; // value set based on passed from the main screen widget in constrcutor i.e. either selected signin/register by user

  // const AuthenticateStudent({super.key});
  AuthenticateUniversity({required this.showSignIn});

  @override
  State<AuthenticateUniversity> createState() => _AuthenticateUniversityState();
}

class _AuthenticateUniversityState extends State<AuthenticateUniversity> {
  // function toggle between signin and register widget
  void toggleView() {
    setState(() {
      widget.showSignIn = !widget.showSignIn; // set value opposite of current showSignIn value
    });
  }

  @override
  Widget build(BuildContext context) {
    // show signin/register widget based on the showSignIn variable value
    if (widget.showSignIn) {
      // show login university if true
      return LoginUniversity(toggleFunc: toggleView);
    } else {
      // show register university if false
      return RegisterUniversity(toggleFunc: toggleView);
    }
  }
}
