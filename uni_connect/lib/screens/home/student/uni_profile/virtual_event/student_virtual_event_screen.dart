import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/virtual_event.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';

class StudentVirtualEventScreen extends StatefulWidget {
  StudentVirtualEventScreen(
      {required this.channelName, required this.virtualEvent});

  // channel name
  String channelName;

  // event title
  // String eventTitle;

  // virtual event object
  VirtualEvent virtualEvent;

  @override
  State<StudentVirtualEventScreen> createState() => _StudentVirtualEventState();
}

class _StudentVirtualEventState extends State<StudentVirtualEventScreen> {
  // Add your Agora App ID here
  // static const String agoraAppId = '4be7200f4d154bc0bed8a60f35b010e9';

  // Declare AgoraRtcEngine instance
  // late RtcEngine _rtcEngine;

  // agora view video container
  // Container? container;

  late Map<String, dynamic> config; // Configuration parameters
  int localUid = -1;
  String agoraAppId = "4be7200f4d154bc0bed8a60f35b010e9", channelName = '';
  List<int> remoteUids = []; // Uids of remote users in the channel
  bool isJoined = false; // Indicates if the local user has joined the channel
  bool isBroadcaster = false; // Client role
  RtcEngine? agoraEngine; // Agora engine instance

  String commentText = '';

  @override
  void initState() {
    super.initState();
    // Initialize Agora SDK
    initializeAgora();

    // set channel name
    channelName = widget.channelName;

    // print('channelName: $channelName');
  }

  Future<void> initializeAgora() async {
    try {
      // Retrieve or request camera and microphone permissions
      await [Permission.microphone, Permission.camera].request();

      // print(status); // granted

      // rebuilding UI to show local video when object is initialized
      setState(() {
        // Create an instance of the Agora engine
        agoraEngine = createAgoraRtcEngine();
      });

      await agoraEngine!.initialize(RtcEngineContext(appId: agoraAppId));

      // if (currentProduct != ProductName.voiceCalling) {
      await agoraEngine!.enableVideo();
      // }

      await agoraEngine!
          .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
      // if (isBroadcaster) {
      await agoraEngine!.setClientRole(role: ClientRoleType.clientRoleAudience);
      // } else {
      //   await _engine.setClientRole(ClientRole.Audience);
      // }

      // Register the event handler
      agoraEngine!.registerEventHandler(getEventHandler());

      // join the channel
      agoraEngine!.joinChannel(
          token: "",
          channelId: channelName,
          uid: 0, // generate random uid
          options: ChannelMediaOptions());
    } catch (e) {
      print('Error initializing Agora: $e');
    }
  }

  // Handle and respond to Agora events
  RtcEngineEventHandler getEventHandler() {
    return RtcEngineEventHandler(
      // Occurs when the network connection state changes
      onConnectionStateChanged: (RtcConnection connection,
          ConnectionStateType state, ConnectionChangedReasonType reason) {
        if (reason ==
            ConnectionChangedReasonType.connectionChangedLeaveChannel) {
          remoteUids.clear();
          isJoined = false;
        }
        // Notify the UI
        Map<String, dynamic> eventArgs = {};
        eventArgs["connection"] = connection;
        eventArgs["state"] = state;
        eventArgs["reason"] = reason;
        // eventCallBack("onConnectionStateChanged", eventArgs);
        // setState(() {});
      },
      // Occurs when a local user joins a channel
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        isJoined = true;
        print("Local user uid:${connection.localUid} joined the channel");
        // Notify the UI
        Map<String, dynamic> eventArgs = {};
        eventArgs["connection"] = connection;
        eventArgs["elapsed"] = elapsed;
        // eventCallback("onJoinChannelSuccess", eventArgs);
        // setState(() {});
      },
      // Occurs when a remote user joins the channel
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        remoteUids.add(remoteUid);
        print("Remote user uid:$remoteUid joined the channel");
        // Notify the UI
        Map<String, dynamic> eventArgs = {};
        eventArgs["connection"] = connection;
        eventArgs["remoteUid"] = remoteUid;
        eventArgs["elapsed"] = elapsed;
        // eventCallback("onUserJoined", eventArgs);
        // setState(() {});
      },
      // Occurs when a remote user leaves the channel
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        remoteUids.remove(remoteUid);
        print("Remote user uid:$remoteUid left the channel");
        // Notify the UI
        Map<String, dynamic> eventArgs = {};
        eventArgs["connection"] = connection;
        eventArgs["remoteUid"] = remoteUid;
        eventArgs["reason"] = reason;
        // setState(() {});
        // eventCallback("onUserOffline", eventArgs);
        // if host left the channel end the stream for students also
        if (remoteUid == 1) {
          Navigator.pop(
              context); // screen will be disposed so will the agora engine ddestroy and other things
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Virtual event ended by the host!')),
          );
        }
      },
    );
  }

/*
// Render view from a remote user in the channel
  AgoraVideoView remoteVideoView(int remoteUid) {
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: agoraEngine!,
        canvas: VideoCanvas(uid: remoteUid),
        connection: RtcConnection(channelId: channelName),
      ),
    );
  }
  */

  // Render video from the local user in the channel
  AgoraVideoView localVideoView() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: agoraEngine!,
        canvas: const VideoCanvas(
            uid:
                1), // uid = 1 for host video (b/c I have set this uid for host)
      ),
    );
  }

  /*
  // show alert dialog for logout button in drawer menu
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

        // update stream status to ended
        final result =
            VirtualEvent.onlyId(eventId: eventId).updateVirtualEventStatus();

        if (result == 'error') {
          print('Error updating stream status');
        }

        // close live stream screen
        Navigator.of(context).pop();

        // message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Virtual event ended!')),
        );
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Leave virtual event?"),
      content: Text("Are you sure you want to leave virtual event?"),
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
  */

  // build method
  @override
  Widget build(BuildContext context) {
    // return agoraEngine != null ? localVideoView() : Container();

    if (agoraEngine == null) {
      return Scaffold(
          body: Center(
              child: WithinScreenProgress(
        text: '',
      )));
    }

    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
            // remoteVideoView(1),
            localVideoView(),
            // Container(
            //     alignment: Alignment.bottomCenter,
            //     child: Image(image: AssetImage('assets/live_video_image.jpg'))),
            _header(),
            _footer(),
          ],
        ),
      ),
    );
  }

  // event screen header
  Widget _header() {
    return Container(
      alignment: Alignment.topRight,
      padding: const EdgeInsets.only(top: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 25.0),
            child: Text(
              widget.virtualEvent.title as String,
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.login_outlined,
              color: Colors.white,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(12.0),
          ),
        ],
      ),
    );
  }

  // input field with comment list footer
  Widget _footer() {
    return Container(
      // height: 250.0,
      // color: Colors.pink,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // comments list
            Container(
              margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 7.0),
              decoration: BoxDecoration(
                  // color: Color.fromARGB(255, 237, 237, 237),
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              height: 200.0,
              width: 250.0,
              child: SingleChildScrollView(
                // controller: ScrollController(onAttach: (position) => ,),
                child: Container(
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.virtualEvent.comments!
                        .map((commentMap) =>
                            // Text(commentMap['comment'])
                            ListTile(
                              leading: CircleAvatar(
                                radius: 15.0,
                                backgroundImage:
                                    AssetImage('assets/student.jpg'),
                              ),
                              title: Text(
                                'Name',
                                style: TextStyle(fontSize: 12.0),
                              ),
                              subtitle: Text(commentMap['comment']),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
            // input field, button row
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // student profile pic
                // CircleAvatar(
                //   backgroundImage: AssetImage('assets/student.jpg'),
                // ),
                // comment field
                Container(
                  padding: EdgeInsets.only(left: 7.0),
                  width: MediaQuery.of(context).size.width - 100,
                  child: TextFormField(
                    decoration: InputDecoration(
                      constraints: BoxConstraints(maxHeight: 47.0),
                      contentPadding: EdgeInsets.all(10.0),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                    ),
                    onChanged: (value) {
                      setState(() {
                        commentText = value.trim();
                      });
                    },
                  ),
                ),
                // comment send button
                // based on comment var show button
                commentText == ''
                    ?
                    // cannot send button
                    MaterialButton(
                        // color: Colors.pink,
                        minWidth: 5,
                        onPressed: () {
                          // do nothing
                        },
                        child: Icon(Icons.send),
                      )
                    // can send button
                    : MaterialButton(
                        minWidth: 5,
                        onPressed: () async {
                          // get uni profile doc id
                          // setState(() {
                          // remove the comment_by_name key from map
                          // postComments = postComments!
                          //     .forEach((comment) =>
                          //         comment.remove('comment_by_name'))
                          //     .toList();

                          // add the new comment in the list
                          widget.virtualEvent.comments!.add({
                            'comment': commentText,
                            // 'comment_by_profile_id': widget.commenterProfileId,
                          });

                          // set name on new comment
                          // _setCommentByOnComment(); // new comment update is shown b/c set state is called inside this method and so post comments varaible chhages are reflected
                          // });

                          // print(postComments);
                          // call comment method
                          String? result = await widget.virtualEvent.comment();

                          if (result == 'success') {
                            // clear comment text field

                            // clear comment text
                            setState(() {
                              commentText = '';
                            });

                            // show comment posted message
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(content: Text('Comment posted!')),
                            // );
                          } else {
                            // set latest commments color as red

                            // show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error commenting')),
                            );
                          }

                          // clear comment text field
                          // setState(() {
                          //   this.comment = '';
                          // });
                        },
                        child: Icon(Icons.send, color: Colors.blue),
                      )
              ],
            ),
          ]),
    );
  }

// on call end button click
  void _onCallEnd(BuildContext context) {
    // showAlertDialog(context);
    Navigator.pop(context);
  }

// on screen dispose
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // print('in dispose func.');
    leave();
  }

  // Leave the channel when the local user ends the call
  Future<void> leave() async {
    // Clear saved remote Uids
    remoteUids.clear();

    // Leave the channel
    if (agoraEngine != null) {
      await agoraEngine!.leaveChannel();
    }
    isJoined = false;

    // Destroy the Agora engine instance
    destroyAgoraEngine();
  }

  // Clean up the resources used by the app
  void destroyAgoraEngine() {
    // Release the RtcEngine instance to free up resources
    if (agoraEngine != null) {
      agoraEngine!.release();
      agoraEngine = null;
    }
  }
}
