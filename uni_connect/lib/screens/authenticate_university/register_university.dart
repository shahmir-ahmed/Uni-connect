import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_connect/classes/university.dart';
import 'package:uni_connect/screens/home/university/university_home.dart';
import 'package:uni_connect/screens/progress_screen.dart';
import 'package:uni_connect/shared/constants.dart';
import 'package:uni_connect/screens/home/university/home_wrapper.dart';

class RegisterUniversity extends StatefulWidget {
  // toggle function
  late VoidCallback toggleFunc;

  RegisterUniversity({required this.toggleFunc});

  @override
  State<RegisterUniversity> createState() => _RegisterUniversityState();
}

class _RegisterUniversityState extends State<RegisterUniversity> {
  // form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // form values
  late String name;
  late String location;
  late String type;
  late String email;
  late String password;
  late String confirmPassword;

  // reg exp variable for name field
  static final RegExp nameRegExp = RegExp(r'^[A-Za-z ]+$');

  // password visible or not flag
  late bool _passwordVisible;

  // confirm password visible or not flag
  late bool _confirmPasswordVisible;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Initiating _passwordVisible to false
    _passwordVisible = false;
    // Initiating _confirmPasswordVisible to false
    _confirmPasswordVisible = false;
  }

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
                            // student icon
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
                              'Create account as University',
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

                    // Register Form
                    Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name field label
                            Text(
                              'Name',
                              style: fieldLabelStyle,
                            ),

                            // space
                            SizedBox(
                              height: 5.0,
                            ),

                            // name field
                            TextFormField(
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                setState(() {
                                  name = value.trim();
                                });
                              },
                              style: TextStyle(fontSize: 17.0),
                              decoration: formInputDecoration,
                              validator: (value) {
                                // validate field

                                // if name is empty at the time of validation return helper text
                                if (value!.trim().isEmpty) {
                                  return 'Please enter university name';
                                }
                                // contains numbers
                                // else if (value.contains('')) {
                                //   return 'Name must not numbers';
                                // }
                                // contains characters other than alphabets
                                else if (!nameRegExp.hasMatch(value)) {
                                  return 'Please enter valid university name';
                                }
                                // valid name
                                else {
                                  return null;
                                }
                              },
                            ),

                            // space
                            SizedBox(
                              height: 27.0,
                            ),

                            // Location field label
                            Text(
                              'Location',
                              style: fieldLabelStyle,
                            ),

                            // space
                            SizedBox(
                              height: 5.0,
                            ),

                            // location field
                            TextFormField(
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                setState(() {
                                  location = value.trim();
                                });
                              },
                              style: TextStyle(fontSize: 17.0),
                              decoration: formInputDecoration,
                              validator: (value) {
                                // validate field

                                // if location is empty at the time of validation return helper text
                                if (value!.trim().isEmpty) {
                                  return 'Please enter location';
                                }
                                // valid location
                                else {
                                  return null;
                                }
                              },
                            ),

                            // space
                            SizedBox(
                              height: 27.0,
                            ),

                            // Type field label
                            Text(
                              'Type (Public/Private)',
                              style: fieldLabelStyle,
                            ),

                            // space
                            SizedBox(
                              height: 5.0,
                            ),

                            // type field
                            TextFormField(
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                setState(() {
                                  type = value.trim();
                                });
                              },
                              style: TextStyle(fontSize: 17.0),
                              decoration: formInputDecoration,
                              validator: (value) {
                                // validate field

                                // if location is empty at the time of validation return helper text
                                if (value!.trim().isEmpty) {
                                  return 'Please enter type';
                                }
                                // contains numbers
                                // else if (value.contains('')) {
                                //   return 'College/high school name must not numbers';
                                // }
                                // contains characters other than alphabets
                                else if (!nameRegExp.hasMatch(value)) {
                                  return 'Please enter valid type';
                                }
                                // valid type
                                else {
                                  return null;
                                }
                              },
                            ),

                            // space
                            SizedBox(
                              height: 27.0,
                            ),

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
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                setState(() {
                                  email = value.trim();
                                });
                              },
                              style: TextStyle(fontSize: 17.0),
                              decoration: formInputDecoration,
                              validator: (value) {
                                // validate field

                                // if email is empty at the time of validation return helper text
                                if (value!.trim().isEmpty) {
                                  return 'Please enter email';
                                }
                                // not contains @ & . in email
                                else if (!value.contains('@') ||
                                    !value.contains('.')) {
                                  return 'Please enter valid email';
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
                              obscureText:
                                  !_passwordVisible, // This will obscure text dynamically
                              style: TextStyle(fontSize: 17.0),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 10.0, color: Colors.black)),
                                // hide show icon
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color.fromARGB(
                                        255, 123, 123, 123),
                                  ),
                                  onPressed: () {
                                    // Update the state i.e. toogle the state of passwordVisible variable
                                    setState(() {
                                      _passwordVisible =
                                          !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                // if password is empty
                                if (value!.trim().length == 0) {
                                  return 'Please enter password';
                                }
                                // if password is less than 6 characters return helper text
                                else if (value!.trim().length < 6) {
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
                              height: 27.0,
                            ),

                            // Confirm Password field label
                            Text(
                              'Confirm password',
                              style: fieldLabelStyle,
                            ),

                            // space
                            SizedBox(
                              height: 5.0,
                            ),

                            // confirm password field
                            TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  confirmPassword = value.trim();
                                });
                              },
                              obscureText:
                                  !_confirmPasswordVisible, // This will obscure text dynamically
                              style: TextStyle(fontSize: 17.0),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 10.0, color: Colors.black)),
                                // hide show icon
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    _confirmPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color.fromARGB(
                                        255, 123, 123, 123),
                                  ),
                                  onPressed: () {
                                    // Update the state i.e. toogle the state of passwordVisible variable
                                    setState(() {
                                      _confirmPasswordVisible =
                                          !_confirmPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                // if password is empty
                                if (value!.trim().length == 0) {
                                  return 'Please enter password again';
                                }
                                // if password is less than 6 characters return helper text
                                else if (value.trim().length < 6) {
                                  return 'Password must be 6 characters long';
                                }
                                // both passwords are not same
                                else if (value != password) {
                                  return 'Both passwords must be same';
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
                                  "Already have an account? ",
                                  style: TextStyle(fontSize: 17.0),
                                ),
                                ElevatedButton(
                                  // change auth student widget's state
                                  onPressed: widget.toggleFunc,

                                  child: Text('Sign in',
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
                                    // if form is val12id
                                    // create University class object and Profile object and pass to the register function to register the uni after checking
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   const SnackBar(
                                    //       content: Text('Signing up...')),
                                    // );
                                    // show progress screen
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProgressScreen(
                                                    text: 'Signing up...')));
                                    // print(name);
                                    // print(location);
                                    // print(type);
                                    // print(email);
                                    // print(password);

                                    // university profile object
                                    UniveristyProfile uniProfile =
                                        UniveristyProfile.forRegister(
                                            name: name,
                                            location: location,
                                            type: type);

                                    // register university account
                                    String? result = await University(
                                            email: email, password: password)
                                        .register(uniProfile);

                                    // error occured (either while creating account or profile)
                                    if (result == null) {
                                      // pop splash screen
                                      Navigator.pop(context);
                                      // ScaffoldMessenger.of(context)
                                      //     .hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Error occured!')),
                                      );
                                    }
                                    // if account with username already exists
                                    else if (result == 'exists') {
                                      // pop splash screen
                                      Navigator.pop(context);
                                      // ScaffoldMessenger.of(context)
                                      //     .hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Account with email already exists!')),
                                      );
                                    }
                                    // account and profile successfully created (account doc id is returned)
                                    // else if (result == 'success') {
                                    else {
                                      // save user data in shared pref.
                                      SharedPreferences pref =
                                          await SharedPreferences.getInstance();
                                      pref.setString('uid',
                                          result); // set the uid as uni account doc id
                                      pref.setString(
                                          'userEmail', email); // set user email
                                      pref.setString('userType',
                                          'university'); // set user type

                                      // ScaffoldMessenger.of(context)
                                      //     .hideCurrentSnackBar();

                                      // show snackbar
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Signed up successfully!')),
                                      );

                                      // pop splash screen
                                      Navigator.pop(context);

                                      // clear route stack and show home screen
                                      // pop two screens below
                                      Navigator.pop(context);
                                      Navigator.pop(context);

                                      // push home screen for university
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeWrapper()));
                                    }
                                  }
                                },
                                child: Text(
                                  'Sign up',
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
