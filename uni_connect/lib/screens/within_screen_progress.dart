import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class WithinScreenProgress extends StatelessWidget {
  // Text to show in progress screen
  late String text;
  
  // padding from top
  double? paddingTop;

  // padding from top
  double? height;

  // constructor to take the text
  WithinScreenProgress({required this.text});

  // constructor to take the text
  WithinScreenProgress.withPadding({required this.text, required this.paddingTop});

  // height
  WithinScreenProgress.withHeight({required this.text, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: paddingTop==null ? 150.0 : paddingTop as double),
      width: MediaQuery.of(context).size.width,
      height: height == null ? MediaQuery.of(context).size.height : height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // text
          Text(
            text,
            style: TextStyle(fontSize: 14.0),
          ),

          // space
          SizedBox(
            height: 7.0,
          ),

          // spin kit
          SpinKitFadingFour(
            color: Colors.blue,
            size: 35.0,
          )
        ],
      ),
    );
  }
}
