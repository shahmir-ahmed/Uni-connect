import 'package:flutter/material.dart';
import 'package:uni_connect/classes/university.dart';
import 'package:uni_connect/shared/constants.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen({required this.uniProfile});

  // uni profile object
  UniveristyProfile? uniProfile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // form attributes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.blue[400],
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(20.0),
            // form
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.orange,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // profile photo upload, preview
                        CircleAvatar(
                          backgroundImage: AssetImage('assets/uni.jpg'),
                          radius: 50.0,
                        ),
                        // upload button
                        ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.upload),
                            label: Text('Upload')),
                      ],
                    ),
                  ),

                  // space
                  SizedBox(
                    height: 28.0,
                  ),

                  // name row
                  Text(
                    'Name: ',
                    style: fieldLabelStyle,
                  ),
                  // field
                  TextFormField(
                    decoration: formInputDecoration,
                    initialValue: widget.uniProfile!.name,
                    onChanged: (value) {
                      // name = value;
                    },
                  )
                ],
              ),
            )),
      ),
    );
  }
}
