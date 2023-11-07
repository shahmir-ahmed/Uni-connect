import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uni_connect/screens/home/student/student_home.dart';
import 'package:uni_connect/screens/home/university/university_home.dart';
import 'package:uni_connect/screens/main_screen.dart';
import 'package:uni_connect/screens/home/university/home_wrapper.dart';


class SplashScreen extends StatelessWidget {
  // const SplashScreen({super.key});
  // next screen to show
  late String nextScreen;

  // take next screen value that needs to show
  SplashScreen({required this.nextScreen});

  @override
  Widget build(BuildContext context) {
    // after 4 seconds pop the current widget and push main screen
    // Future.delayed(Duration(seconds: 4), () {
    //   Navigator.pop(context);
    //   Navigator.push(
    //       context, MaterialPageRoute(builder: (context) => MainScreen()));
    // });

    // after 4 seconds pop the current widget and push screen according to next screen to show, if empty then not pop
    if (nextScreen != 'none') {
      Future.delayed(Duration(seconds: 4), () {
        // pop splash screen
        Navigator.pop(context);
        // push next screen
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          if (nextScreen == 'mainScreen') {
            return MainScreen();
          } else if (nextScreen == 'studentHome') {
            return StudentHome();
          } else{
            return HomeWrapper(); // show wrapper of uni home
          }
        }));
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(top: 250.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // app logo
            Image(image: AssetImage('assets/logo.png')),

            // space
            SizedBox(
              height: 5.0,
            ),

            // app name
            // Text(
            //   'Uni-connect',
            //   style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            // )
            // spin kit
            SpinKitFadingFour(
              color: Colors.blue,
              size: 50.0,
            )
          ],
        ),
      ),
    );
  }
}
