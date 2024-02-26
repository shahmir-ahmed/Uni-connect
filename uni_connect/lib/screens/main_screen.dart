import 'package:flutter/material.dart';
import 'package:uni_connect/screens/authenticate_student/authenticate_student.dart';
import 'package:uni_connect/screens/authenticate_university/authenticate_university.dart';
import 'package:uni_connect/shared/constants.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Appbar
      appBar: AppBar(
        title: Text('Uni-connect'),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      // Body
      body: Container(
        // padding: EdgeInsets.all(20.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // main column
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // container for row
            Container(
              height: 330.0,
              // row
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // first column for student options
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // student image avatar
                      CircleAvatar(
                        backgroundImage: AssetImage("assets/student.jpg"),
                        radius: 50.0,
                      ),

                      // space
                      SizedBox(
                        height: 10.0,
                      ),

                      // sign in button
                      ElevatedButton(
                        onPressed: () {
                          // push authenticate studnet widget with sign in true i.e. to show sign in widget
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AuthenticateStudent(showSignIn: true)));
                        },
                        style: mainScreenButtonStyle,
                        child: Text(
                          'Sign in',
                          style: TextStyle(fontSize: 14.5),
                        ),
                      ),

                      // space
                      SizedBox(
                        height: 10.0,
                      ),

                      // text
                      Text(
                        'or',
                        style: TextStyle(fontSize: 16.0),
                      ),

                      // space
                      SizedBox(
                        height: 10.0,
                      ),

                      // regsiter button
                      ElevatedButton(
                          onPressed: () {
                            // push authenticate studnet widget with sign in false i.e. to show register widget
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AuthenticateStudent(
                                        showSignIn: false)));
                          },
                          style: mainScreenButtonStyle,
                          child: Text(
                            'Register',
                            style: TextStyle(fontSize: 14.5),
                          )),

                      // space
                      SizedBox(
                        height: 10.0,
                      ),

                      // text
                      Text(
                        'as Student',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),

                  // // gap
                  // SizedBox(
                  //   width: 10.0,
                  // ),

                  // divider
                  VerticalDivider(
                    thickness: 1.0,
                    color: Colors.black,
                  ),

                  // // gap
                  // SizedBox(
                  //   width: 10.0,
                  // ),

                  // second column for university options
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // student image avatar
                      CircleAvatar(
                        backgroundImage: AssetImage("assets/uni.jpg"),
                        radius: 50.0,
                      ),

                      // space
                      SizedBox(
                        height: 10.0,
                      ),

                      // sign in button
                      ElevatedButton(
                          onPressed: () {
                            // push authenticate university widget with sign in true i.e. to show sign in widget
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AuthenticateUniversity(
                                            showSignIn: true)));
                          },
                          style: mainScreenButtonStyle,
                          child: Text(
                            'Sign in',
                            style: TextStyle(fontSize: 14.5),
                          )),

                      // space
                      SizedBox(
                        height: 10.0,
                      ),

                      // text
                      Text(
                        'or',
                        style: TextStyle(fontSize: 16.0),
                      ),

                      // space
                      SizedBox(
                        height: 10.0,
                      ),

                      // regsiter button
                      ElevatedButton(
                          onPressed: () {
                            // push authenticate university widget with sign in false i.e. to show register widget
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AuthenticateUniversity(
                                            showSignIn: false)));
                          },
                          style: mainScreenButtonStyle,
                          child: Text(
                            'Register',
                            style: TextStyle(fontSize: 14.5),
                          )),

                      // space
                      SizedBox(
                        height: 10.0,
                      ),

                      // text
                      Text(
                        'as University',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
