import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_connect/classes/university.dart';
import 'package:uni_connect/screens/authenticate_university/authenticate_university.dart';
import 'package:uni_connect/screens/main_screen.dart';
import 'package:uni_connect/screens/progress_screen.dart';
import 'package:uni_connect/shared/constants.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({required this.uniAccountId});

  // uni account id for updating password
  String uniAccountId;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // form values
  String newPassword = '';

  // form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // password visible or not flag
  late bool _password1Visible;

  // password 2 visible or not flag
  late bool _password2Visible;

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("No"),
      onPressed: () {
        // close the alert dialog
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        "Yes",
      ),
      onPressed: () async {
        // close the alert dialog
        Navigator.of(context).pop();

        // show progress screen (in case slow logging out)
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProgressScreen(text: 'Logging out...')));

        // logout user
        await _logoutUser();

        // ScaffoldMessenger.of(context).hideCurrentSnackBar();

        Navigator.pop(context); // pop progress screen
        Navigator.pop(context); // pop settings screen
        Navigator.pop(context); // pop home wrapper
        // push main screen
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainScreen()));
        // push authenticate university screen with signin true
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AuthenticateUniversity(
                      showSignIn: true,
                    )));
        // logout message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logged out successfully!')),
        );
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Logout?"),
      content: Text("Are you sure you want to logout?"),
      actions: [
        continueButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // confirmation alert dialog
  showAlertDialog2(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        // close the alert dialog
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        "Yes",
      ),
      onPressed: () async {
        // print('password1 $password1');

        // close the alert dialog
        Navigator.of(context).pop();

        // show progress screen
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProgressScreen(text: 'Updating password...')));

        // University class object
        University uni = University.withIdPassword(
            id: widget.uniAccountId, password: newPassword);

        // update account password
        final result = await uni.updatePassword(); // wait here

        print("result: $result");

        // error occured
        if (result == 'error') {
          // pop progress screen
          Navigator.pop(context);

          // show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error occured')),
          );
        }
        // password updated
        else {
          // pop progress screen
          Navigator.pop(context);
          // pop settings screen
          Navigator.pop(context);

          // show welcome message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password updated successfully!')),
          );
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Confirm?"),
      content: Text("Are you sure you want to update password?"),
      actions: [
        continueButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // logout function
  Future<void> _logoutUser() async {
    // clear shared pref data for app
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Initiating _passwordVisible to false
    _password1Visible = false;
    // Initiating _passwordVisible to false
    _password2Visible = false;
  }

  // build method
  @override
  Widget build(BuildContext context) {
    // widget tree
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text('Update password'),
            // title: Text('Uni-connect'),
            // centerTitle: true,
            backgroundColor: Colors.blue[400],
            actions: [
              MaterialButton(
                onPressed: () async {
                  showAlertDialog(context);
                },
                child: Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                highlightElevation: 0.0,
                highlightColor: Colors.blue[400],
              )
            ]),
        // settings screen body
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(20.0),
              // main column
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*
                    // row for icon and heading
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // column for vertical widgets
                        Column(
                          children: [
                            // space
                            SizedBox(
                              height: 50.0,
                            ),
                            // heading
                            Text(
                              'Update password',
                              style: TextStyle(
                                  fontSize: 22.0, fontWeight: FontWeight.bold),
                            )
                          ],
                        )
                      ],
                    ),
                    */

                    // space
                    SizedBox(
                      height: 50.0,
                    ),

                    // Update password Form
                    Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // New Password field label
                            Text(
                              'New Password',
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
                                  newPassword = value.trim();
                                });
                              },
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              enableSuggestions: false,
                              obscureText:
                                  !_password1Visible, // This will obscure text dynamically
                              style: TextStyle(fontSize: 17.0),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 10.0, color: Colors.black)),
                                // hide show icon
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    _password1Visible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color.fromARGB(
                                        255, 123, 123, 123),
                                  ),
                                  onPressed: () {
                                    // Update the state i.e. toogle the state of passwordVisible variable
                                    setState(() {
                                      _password1Visible = !_password1Visible;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                // if password is empty
                                if (value!.trim().isEmpty) {
                                  return 'Please enter new password';
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

                            // Password field label
                            Text(
                              'Confirm new password',
                              style: fieldLabelStyle,
                            ),

                            // space
                            SizedBox(
                              height: 5.0,
                            ),

                            // password field
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              enableSuggestions: false,
                              obscureText:
                                  !_password2Visible, // This will obscure text dynamically
                              style: TextStyle(fontSize: 17.0),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 10.0, color: Colors.black)),
                                // hide show icon
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    _password2Visible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color.fromARGB(
                                        255, 123, 123, 123),
                                  ),
                                  onPressed: () {
                                    // Update the state i.e. toogle the state of passwordVisible variable
                                    setState(() {
                                      _password2Visible = !_password2Visible;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                // if password is empty
                                if (value!.trim().isEmpty) {
                                  return 'Please enter password again';
                                }
                                // if password is less than 6 characters return helper text
                                else if (value!.trim().length < 6) {
                                  return 'Password must be 6 characters long';
                                }
                                // password 2 not matches with password 1
                                else if (value != newPassword) {
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
                              height: 30.0,
                            ),

                            // submit button
                            MaterialButton(
                                onPressed: () async {
                                  // validate form
                                  if (_formKey.currentState!.validate()) {
                                    // if form is valid
                                    // ask for confirmation
                                    // show alert for confirmation
                                    showAlertDialog2(context);
                                  }
                                },
                                child: Text(
                                  'Update password',
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
