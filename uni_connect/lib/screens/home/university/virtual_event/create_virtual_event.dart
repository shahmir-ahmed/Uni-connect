import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';
import 'package:uni_connect/shared/constants.dart';
import 'package:camera/camera.dart';
import 'package:uni_connect/screens/home/university/virtual_event/uni_virtual_event_screen.dart';
import 'package:http/http.dart' as http;

class CreateVirtualEvent extends StatefulWidget {
  CreateVirtualEvent({required this.uniProfileId, required this.uniName});

  // uni profile id
  String uniProfileId;

  // uni name
  String uniName;

  @override
  State<CreateVirtualEvent> createState() => _CreateVirtualEventState();
}

class _CreateVirtualEventState extends State<CreateVirtualEvent> {
  // form key
  final _formKey = GlobalKey<FormState>();

  // stream title
  String streamTitle = '';

  // for front camera view
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;

  late List<CameraDescription> cameras;

  // send notification to followers of live
  void _sendNotification() async {
    try {
      // Sending message payload
      var message = {
        "to":
            "/topics/${widget.uniProfileId}_followers", // Topic to which the notification will be sent i.e users subscribed to this uni's followers topic
        "priority": "high",
        "notification": {
          // "title": "🔴 ${widget.uniName.substring(0, 19)}. is live!",
          "title": "🔴 ${widget.uniName} is live!",
          "body": "${streamTitle}",
        },
        // 'data': {'type': 'live'} for clicking notification and redirecting to live screen
      };

      // Send the notification by API post request to the fcm url
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          body: jsonEncode(message),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization':
                'key=AAAA3Pwia-c:APA91bFOvIXySqYs72V6HeB0ksF1UJfnI4y_hpRCLdtQM9A-HcATpMyHdGQSzmkyAh7gGJdJm2B9z3IHuCMZ2ybYO4YViKmru2AAREOhk-t2gcYGCXdouQUGHPprQyi0_ceOy3lEyvjA'
          });

      print("Notification sent successfully!");
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

/*
    // Initialize the camera controller
    _controller = CameraController(
      CameraDescription(
        sensorOrientation: 0,
        name: '0',
        lensDirection: CameraLensDirection.front,
      ),
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
    */

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    CameraDescription frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);

    setState(() {
      _initializeControllerFuture = _controller.initialize();
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  // build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text(
            'Create virtual event',
          ),
          backgroundColor: Colors.blue[400]),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // user video
              Container(
                  // decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.all(Radius.circular(30.0))),
                  width: 350.0,
                  height: 350.0,
                  // child: Image.asset('assets/uni.jpg'),
                  child: _initializeControllerFuture != null
                      ? FutureBuilder<void>(
                          future: _initializeControllerFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              // If the Future is complete, display the preview.
                              return Center(child: CameraPreview(_controller));
                            } else {
                              // Otherwise, display a loading indicator.
                              return Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                child: Center(
                                    child: WithinScreenProgress.withHeight(
                                  text: '',
                                  height: 350.0,
                                )),
                              );
                            }
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                          child: WithinScreenProgress.withHeight(
                              text: '', height: 350.0),
                        )),

              // space
              SizedBox(height: 30.0),

              // live stream title
              // label
              Text(
                'Title',
                style: TextStyle(fontSize: 16.0),
              ),

              // space
              SizedBox(height: 4.0),

              // input field
              Form(
                  key: _formKey,
                  child: TextFormField(
                    decoration: formInputDecoration,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (value) {
                      setState(() {
                        streamTitle = value.trim();
                      });
                    },
                    validator: (value) {
                      if (value!.trim().isNotEmpty) {
                        return null;
                      } else {
                        return 'Please enter title';
                      }
                    },
                  )),

              // space
              SizedBox(height: 25.0),

              // go live button
              Center(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        style: buttonStyle,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // if form is valid
                            // notify all followers
                            // send notifications to all the users who are subscribed to profileId_followers topic
                            _sendNotification();
                            // pop the create event screen
                            Navigator.pop(context);
                            // show live stream screen
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VirtualEventScreen(
                                        uniProfileId: widget.uniProfileId,
                                        title: streamTitle)));
                          }
                        },
                        label: Text(
                          'Go Live',
                        ),
                        icon: Icon(Icons.play_arrow_rounded),
                      ))),
            ],
          ),
        ),
      ),
    );
  }
}
