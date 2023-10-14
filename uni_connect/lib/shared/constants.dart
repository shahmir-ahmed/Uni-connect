import 'package:flutter/material.dart';

// form input field decoration
const formInputDecoration = InputDecoration(
    border: OutlineInputBorder(
        borderSide: BorderSide(width: 10.0, color: Colors.black)));

// button decoration sign in and register form
const formButtonDecoration = ButtonStyle(
    backgroundColor: MaterialStatePropertyAll(Colors.white),
    fixedSize: MaterialStatePropertyAll(Size(89.0, 10.0)),
    elevation: MaterialStatePropertyAll(0.0));

// form field label style
const fieldLabelStyle = TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500);
