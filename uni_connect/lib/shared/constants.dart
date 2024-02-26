import 'package:flutter/material.dart';

// form input field decoration
const formInputDecoration = InputDecoration(
    border: OutlineInputBorder(
        borderSide: BorderSide(width: 10.0, color: Colors.black)));

// button decoration sign in and register form
const formButtonDecoration = ButtonStyle(
    backgroundColor: MaterialStatePropertyAll(Colors.white),
    fixedSize: MaterialStatePropertyAll(Size(110.0, 10.0)),
    elevation: MaterialStatePropertyAll(0.0));

// main screen buttons style
const mainScreenButtonStyle = ButtonStyle(
    backgroundColor: MaterialStatePropertyAll(Colors.blue),
    foregroundColor: MaterialStatePropertyAll(Colors.white));

// form field label style
const fieldLabelStyle = TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500);

// progress loading
// const progress = Container(
//       padding: EdgeInsets.only(top: 150.0),
//       width: 100,
//       height: 100,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // text
//           Text(
//             text,
//             style: TextStyle(fontSize: 14.0),
//           ),

//           // space
//           SizedBox(
//             height: 7.0,
//           ),

//           // spin kit
//           SpinKitFadingFour(
//             color: Colors.blue,
//             size: 35.0,
//           )
//         ],
//       ),
//     );
