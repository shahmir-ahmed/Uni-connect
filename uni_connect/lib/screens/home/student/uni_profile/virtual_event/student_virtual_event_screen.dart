import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uni_connect/classes/virtual_event.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';

class StudentVirtualEventScreen extends StatefulWidget {
  StudentVirtualEventScreen({required this.channelName, required this.eventTitle});

  // channel name
  String channelName;

  // event title
  String eventTitle;

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
          uid: 0,
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
        setState(() {});
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
        setState(() {});
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
        setState(() {});
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
        setState(() {});
        // eventCallback("onUserOffline", eventArgs);
      },
    );
  }

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
            remoteVideoView(1),
            _header(),
            // _footer(),
          ],
        ),
      ),
    );
  }

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
              widget.eventTitle,
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

/*
// input field with comment list footer
  Widget _footer() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
        ],
      ),
    );
  }
  */

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
