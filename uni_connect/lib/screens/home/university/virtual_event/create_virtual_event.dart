import 'package:flutter/material.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';
import 'package:uni_connect/shared/constants.dart';
import 'package:camera/camera.dart';
import 'package:uni_connect/screens/home/university/virtual_event/virtual_event.dart';

class CreateVirtualEvent extends StatefulWidget {
  CreateVirtualEvent({required this.uniProfileId});

  // uni profile id
  String uniProfileId;

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
  late Future<void>? _initializeControllerFuture;

  late List<CameraDescription> cameras;

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
                  width: 350.0,
                  color: const Color.fromARGB(255, 236, 235, 235),
                  height: 350.0,
                  // child: Image.asset('assets/uni.jpg'),
                  child: _initializeControllerFuture != null
                      ? FutureBuilder<void>(
                          future: _initializeControllerFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              // If the Future is complete, display the preview.
                              return CameraPreview(_controller);
                            } else {
                              // Otherwise, display a loading indicator.
                              return Center(
                                  child: WithinScreenProgress.withHeight(
                                text: '',
                                height: 350.0,
                              ));
                            }
                          },
                        )
                      : Container(
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

              // input field
              Form(
                  key: _formKey,
                  child: TextFormField(
                    decoration: formInputDecoration,
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
                            // pop the create event screen
                            Navigator.pop(context);
                            // show live stream screen
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VirtualEvent(
                                        uniProfileId: widget.uniProfileId, title: streamTitle)));
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
