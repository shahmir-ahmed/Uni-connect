import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/virtual_event.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';

class VirtualEventScreen extends StatefulWidget {
  VirtualEventScreen({required this.uniProfileId, required this.title});

  // uni profile id for channel name
  String uniProfileId;

  // stream title
  String title;

  @override
  State<VirtualEventScreen> createState() => _VirtualEventState();
}

class _VirtualEventState extends State<VirtualEventScreen> {
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
  bool isBroadcaster = true; // Client role
  RtcEngine? agoraEngine; // Agora engine instance

  bool muted = false;

  // event firebase doc id
  String eventId = '';

  // remote users in the stream except the streamer
  // int users = 0;

  @override
  void initState() {
    super.initState();
    // Initialize Agora SDK
    initializeAgora();

    // set channel name
    channelName = widget.uniProfileId;

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
      await agoraEngine!
          .setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      // } else {
      //   await _engine.setClientRole(ClientRole.Audience);
      // }

      // Register the event handler
      agoraEngine!.registerEventHandler(getEventHandler());

      // join the channel
      await agoraEngine!.joinChannel(
          token: "",
          channelId: channelName,
          uid: 1, // host uid
          options: ChannelMediaOptions());

      // create a document in virtual_event collections with stream title, uni id and status
      final result = await VirtualEvent.withoutId(
              title: widget.title,
              status: 'live',
              uniProfileId: widget.uniProfileId)
          .createVirtualEvent();

      if (result == 'error') {
        // error occured
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error going live!')),
        );
      } else {
        setState(() {
          eventId = result; // set the id
        });
      }
    } catch (e) {
      print('Error initializing Agora: $e');
    }
  }

  // Not works at the broadcaster side
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
        setState(() {
          // users++; // remote user (student) joined
        });
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
        setState(() {
          // users--; // remote user (student) left
        });
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

        // close live stream screen
        // Navigator.of(context).pop();
        

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
      title: Text("End virtual event?"),
      content: Text("Are you sure you want to end virtual event?"),
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

  // Render video from the local user in the channel
  AgoraVideoView localVideoView() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: agoraEngine!,
        canvas: const VideoCanvas(uid: 0), // Use uid = 0 for local view
      ),
    );
  }

  // called when back is pressed on the screen
  Future<bool> _onWillPop() async {
    return (await showAlertDialog(context)) ?? false;
  }

  // build method
  @override
  Widget build(BuildContext context) {
    // print('widget.title ${widget.title}');
    // return agoraEngine != null ? localVideoView() : Container();
    if (agoraEngine == null) {
      return Scaffold(
          body: Center(
              child: WithinScreenProgress(
        text: '',
      )));
    }
    // live screen
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Center(
          child: Stack(
            children: <Widget>[
              localVideoView(),
              _header(),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  // header of screen
  Widget _header() {
    return Container(
      alignment: Alignment.topRight,
      padding: const EdgeInsets.only(top: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // stream title
          Container(
            decoration: BoxDecoration(
                // color: Color.fromARGB(255, 237, 237, 237).withOpacity(0.5),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            margin: EdgeInsets.only(left: 25.0),
            padding: EdgeInsets.all(8.0),
            child: Text(
              widget.title.length > 18
                  ? "${widget.title.substring(0, 18).trim()}..."
                  : widget.title,
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
          // students in stream watching
          Row(
            children: [
              // if event id is present then fetched user count stream and supply down to the users count widget
              eventId.isNotEmpty
                  ? StreamProvider.value(
                      initialData: null,
                      value: VirtualEvent.onlyId(eventId: eventId)
                          .getVirtualEventUsersStream(),
                      child: UsersCountWidget())
                  : SizedBox(),
              // stream end button
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
        ],
      ),
    );
  }

  // footer of screen
  Widget _footer() {
    return Container(
      // color: Colors.brown,
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end, // this done
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // stream setup of event's comments
          Container(
            height: 200.0,
            width: 250.0,
            margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            decoration: BoxDecoration(
                // color: Color.fromARGB(255, 237, 237, 237).withOpacity(0.5),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            // margin: EdgeInsets.symmetric(horizontal: 12.0),
            child: SingleChildScrollView(
                child: eventId.isEmpty
                    ? Container()
                    : StreamProvider.value(
                        value: VirtualEvent.onlyId(eventId: eventId)
                            .getVirtualEventCommentsStream(),
                        initialData: null,
                        child: EventComments())),
          ),

          // mic button
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
            // camera button
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
          ]),
        ],
      ),
    );
  }

// on call end button click
  void _onCallEnd(BuildContext context) {
    showAlertDialog(context);
  }

  // on mute button click
  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    // agoraEngine!.muteLocalAudioStream(muted);
    agoraEngine!.enableLocalAudio(!muted);
  }

  // on switch camera button click
  void _onSwitchCamera() {
    agoraEngine!.switchCamera();
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
  /*
    // update stream status to ended
    final result =
        VirtualEvent.onlyId(eventId: eventId).updateVirtualEventStatus();

    if (result == 'error') {
      print('Error updating stream status');
    }
    */

    // message
    // after 2 sec show
    // Future.delayed(Duration(seconds: 2), () {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Virtual event ended!')),
    //   );
    // });
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Virtual event ended!')),
    // );

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

// user count widget that shows users in stream count
class UsersCountWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final eventObj = Provider.of<VirtualEvent?>(context);

    // print('userCount: $eventObj');

    return eventObj != null
        ? ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.remove_red_eye_rounded,
              color: Colors.white,
              size: 20.0,
            ),
            // shape: BeveledRectangleBorder(),
            style: ButtonStyle(
                elevation: MaterialStatePropertyAll(0.0),
                backgroundColor: MaterialStatePropertyAll(Colors.black),
                padding: MaterialStatePropertyAll(
                  const EdgeInsets.all(12.0),
                )),
            label: Text(
              eventObj.usersCount.toString(),
              style: TextStyle(color: Colors.white),
            ),
          )
        : SizedBox();
  }
}

// comments widget
class EventComments extends StatefulWidget {
  const EventComments({super.key});

  @override
  State<EventComments> createState() => _EventCommentsState();
}

class _EventCommentsState extends State<EventComments> {
  // comments list
  // List<dynamic>? comments;

  @override
  Widget build(BuildContext context) {
    // consume stream
    final eventObj = Provider.of<VirtualEvent?>(context);

    // print(eventObj);

    return eventObj != null
        ? eventObj.comments!.isEmpty
            ? Container()
            : Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: eventObj.comments!
                      .map((commentMap) =>
                          // Text(commentMap['comment'])
                          ListTile(
                            leading: CircleAvatar(
                              radius: 15.0,
                              backgroundImage: AssetImage('assets/student.jpg'),
                            ),
                            title: Text(
                              commentMap['comment_by_name'],
                              style: TextStyle(
                                  fontSize: 12.0, color: Colors.white),
                            ),
                            subtitle: Text(
                              commentMap['comment'],
                              style: TextStyle(color: Colors.white),
                            ),
                          ))
                      .toList(),
                ),
              )
        : Container();
  }
}
