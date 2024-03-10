import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class VirtualEvent extends StatefulWidget {
  const VirtualEvent({super.key});

  @override
  State<VirtualEvent> createState() => _VirtualEventState();
}

class _VirtualEventState extends State<VirtualEvent> {
  // Add your Agora App ID here
  // static const String agoraAppId = '4be7200f4d154bc0bed8a60f35b010e9';

  // Declare AgoraRtcEngine instance
  // late RtcEngine _rtcEngine;

  // agora view video container
  // Container? container;

  late Map<String, dynamic> config; // Configuration parameters
  int localUid = -1;
  String appId = "4be7200f4d154bc0bed8a60f35b010e9", channelName = "uni_live_stream";
  List<int> remoteUids = []; // Uids of remote users in the channel
  bool isJoined = false; // Indicates if the local user has joined the channel
  bool isBroadcaster = true; // Client role
  RtcEngine? agoraEngine; // Agora engine instance

  @override
  void initState() {
    super.initState();
    // Initialize Agora SDK
    initializeAgora();
  }

  Future<void> initializeAgora() async {
    try {
      // Retrieve or request camera and microphone permissions
      // await [Permission.microphone, Permission.camera].request();

      // Create an instance of the Agora engine
      agoraEngine = createAgoraRtcEngine();

      await agoraEngine!.initialize(RtcEngineContext(appId: appId));

      // if (currentProduct != ProductName.voiceCalling) {
      await agoraEngine!.enableVideo();
      // }

      // Register the event handler
      agoraEngine!.registerEventHandler(getEventHandler());
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
      },
      // Occurs when a local user joins a channel
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        isJoined = true;
        print(
            "Local user uid:${connection.localUid} joined the channel");
        // Notify the UI
        Map<String, dynamic> eventArgs = {};
        eventArgs["connection"] = connection;
        eventArgs["elapsed"] = elapsed;
        // eventCallback("onJoinChannelSuccess", eventArgs);
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
        // eventCallback("onUserOffline", eventArgs);
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
        canvas: const VideoCanvas(uid: 0), // Use uid = 0 for local view
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return localVideoView();
  }
}
