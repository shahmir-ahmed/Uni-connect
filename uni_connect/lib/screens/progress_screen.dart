import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProgressScreen extends StatelessWidget {
  // const ProgressScreen({super.key});

  // Text to show in progress screen
  late String text;

  // bg color of progress screen
  late bool bgColorBlack=false;

  // constructor to take the text
  ProgressScreen({required this.text});

  // constructor to take the text and make the bg color of container black
  ProgressScreen.withBgColorBlack({required this.text, this.bgColorBlack=true});

  @override
  Widget build(BuildContext context) {
    // on will pop scope prevents the page from being popped by the system. You'll still be able to use Navigator.of(context).pop()
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            color: bgColorBlack==false ? Colors.white : Colors.black,
            padding: EdgeInsets.only(top: 350.0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // text
                Text(
                  text,
                  style: TextStyle(fontSize: 20.0, color: bgColorBlack ? Colors.white : Colors.black),
                ),

                // space
                SizedBox(
                  height: 7.0,
                ),

                // spin kit
                SpinKitFadingFour(
                  color: Colors.blue,
                  size: 50.0,
                )
              ],
            ),
          ),
        ));
  }
}

class PoppableProgressScreen extends StatelessWidget {
  // const ProgressScreen({super.key});

  // Text to show in progress screen
  late String text;

  // bg color of progress screen
  late bool bgColorBlack=false;

  // constructor to take the text
  PoppableProgressScreen({required this.text});

  // constructor to take the text and make the bg color of container black
  PoppableProgressScreen.withBgColorBlack({required this.text, this.bgColorBlack=true});

  @override
  Widget build(BuildContext context) {
    // on will pop scope prevents the page from being popped by the system. You'll still be able to use Navigator.of(context).pop()
    return Scaffold(
      body: Container(
        color: bgColorBlack==false ? Colors.white : Colors.black,
        padding: EdgeInsets.only(top: 350.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // text
            Text(
              text,
              style: TextStyle(fontSize: 20.0, color: bgColorBlack ? Colors.white : Colors.black),
            ),

            // space
            SizedBox(
              height: 7.0,
            ),

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
