import 'package:flutter/material.dart';
import 'package:uni_connect/screens/authenticate_student/login_student.dart';
import 'package:uni_connect/screens/authenticate_student/register_student.dart';

class AuthenticateStudent extends StatefulWidget {
  // variable to display either login/register widget
  late bool
      showSignIn; // value set based on passed from the main screen widget in constrcutor i.e. either selected signin/register by user

  // const AuthenticateStudent({super.key});
  AuthenticateStudent({required this.showSignIn});

  @override
  State<AuthenticateStudent> createState() => _AuthenticateStudentState();
}

class _AuthenticateStudentState extends State<AuthenticateStudent> {
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
      // show login student if true
      return LoginStudent(toggleFunc: toggleView);
    } else {
      // show register student if false
      return RegisterStudent(toggleFunc: toggleView);
    }
  }
}
