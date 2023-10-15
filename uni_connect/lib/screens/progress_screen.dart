import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProgressScreen extends StatelessWidget {
  // const ProgressScreen({super.key});

  late String text;

  ProgressScreen({required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 350.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // text
            Text(
              text,
              style: TextStyle(fontSize: 20.0),
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
