import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_connect/classes/university.dart';
import 'package:uni_connect/screens/home/university/university_home.dart';
import 'package:uni_connect/screens/progress_screen.dart';
import 'package:uni_connect/shared/constants.dart';

class LoginUniversity extends StatefulWidget {
  // toggle function
  late VoidCallback toggleFunc;

  LoginUniversity({required this.toggleFunc});

  @override
  State<LoginUniversity> createState() => _LoginUniversityState();
}

class _LoginUniversityState extends State<LoginUniversity> {
  // form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // form values
  late String email;
  late String password;

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
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(20.0),
              // main column
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // row for icon and heading
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // column for vertical widgets
                        Column(
                          children: [
                            // university icon
                            CircleAvatar(
                              backgroundImage: AssetImage('assets/uni.jpg'),
                              radius: 45.0,
                            ),

                            // space
                            SizedBox(
                              height: 10.0,
                            ),

                            // heading
                            Text(
                              'Sign in as University',
                              style: TextStyle(
                                  fontSize: 22.0, fontWeight: FontWeight.bold),
                            )
                          ],
                        )
                      ],
                    ),

                    // space
                    SizedBox(
                      height: 50.0,
                    ),

                    // Login Form
                    Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // email field label
                            Text(
                              'Email',
                              style: fieldLabelStyle,
                            ),

                            // space
                            SizedBox(
                              height: 5.0,
                            ),

                            // email field
                            TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  email = value.trim();
                                });
                              },
                              style: TextStyle(fontSize: 17.0),
                              decoration: formInputDecoration,
                              validator: (value) {
                                // if email is empty at the time of validation return helper text otherwise null
                                if (value!.trim().isEmpty) {
                                  return 'Please enter email';
                                }
                                // not contains @ & . in email
                                else if (!value.contains('@') ||
                                    !value.contains('.')) {
                                  return 'Email must contain @ and .';
                                }
                                // valid email
                                else {
                                  return null;
                                }
                              },
                            ),

                            // space
                            SizedBox(
                              height: 27.0,
                            ),

                            // Password field label
                            Text(
                              'Password',
                              style: fieldLabelStyle,
                            ),

                            // space
                            SizedBox(
                              height: 5.0,
                            ),

                            // password field
                            TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  password = value.trim();
                                });
                              },
                              obscureText: true,
                              style: TextStyle(fontSize: 17.0),
                              decoration: formInputDecoration,
                              validator: (value) {
                                // if password is less than 6 characters return helper text otherwise null
                                if (value!.trim().length < 6) {
                                  return 'Password must be 6 characters long';
                                }
                                // password does not contain special chars and numbers
                                // elseif(!value.contains('1-10')) {

                                // }
                                // valid password
                                else {
                                  return null;
                                }
                              },
                            ),

                            // space
                            SizedBox(
                              height: 10.0,
                            ),

                            // row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // register text
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(fontSize: 17.0),
                                ),
                                ElevatedButton(
                                  // change auth student widget's state
                                  onPressed: widget.toggleFunc,

                                  child: Text('Sign up',
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 17.0)),
                                  style: formButtonDecoration,
                                )
                              ],
                            ),

                            // space
                            SizedBox(
                              height: 10.0,
                            ),

                            // submit button
                            MaterialButton(
                                onPressed: () async {
                                  // validate form
                                  if (_formKey.currentState!.validate()) {
                                    // if form is valid
                                    // create Student class object and pass to the login function to login the student
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   const SnackBar(
                                    //       content: Text('Signing in...')),
                                    // );
                                    // show progress screen
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProgressScreen(text: 'Signing in...')));
                                    // print(email);
                                    // print(password);

                                    // University class object
                                    University uni = University(
                                        username: email, password: password);

                                    // login account
                                    String? result =
                                        await uni.login(); // wait here

                                    // print("result: $result");

                                    // error occured
                                    if (result == null) {
                                      // ScaffoldMessenger.of(context)
                                      //     .hideCurrentSnackBar();
                                      // pop splash screen
                                      Navigator.pop(context);

                                      // show error snackbar
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Error occured')),
                                      );
                                    }
                                    // account exists
                                    else if (result == 'Valid') {
                                      // save user data in shared pref.
                                      SharedPreferences pref =
                                          await SharedPreferences.getInstance();
                                      pref.setString(
                                          'userEmail', email); // set user email
                                      pref.setString('userType',
                                          'university'); // set user type

                                      // hide snack bar
                                      // ScaffoldMessenger.of(context)
                                      //     .hideCurrentSnackBar();
                                      // pop splash screen
                                      Navigator.pop(context);
                                      // pop the bottom two widgets from route stack
                                      Navigator.pop(context);
                                      Navigator.pop(context);

                                      // push home screen of uni
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  UniversityHome()));

                                      // show welcome message
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('Welcome $email!')),
                                      );
                                    }
                                    // account not exists
                                    else {
                                      // pop splash screen
                                      Navigator.pop(context);
                                      // hide current snack bar
                                      // ScaffoldMessenger.of(context)
                                      //     .hideCurrentSnackBar();

                                      // show snack bar
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Invalid email or password!')),
                                      );
                                    }
                                  }
                                },
                                child: Text(
                                  'Sign in',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                color: Colors.blue[500],
                                textColor: Colors.white,
                                height: 50.0,
                                minWidth:
                                    MediaQuery.of(context).size.width - 40)
                          ],
                        ))
                  ])),
        ));
  }
}
