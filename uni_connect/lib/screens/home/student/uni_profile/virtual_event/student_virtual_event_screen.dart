import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uni_connect/classes/student.dart';
import 'package:uni_connect/classes/virtual_event.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';

class StudentVirtualEventScreen extends StatefulWidget {
  StudentVirtualEventScreen(
      {required this.channelName,
      required this.virtualEvent,
      required this.stdProfileId});

  // channel name
  String channelName;

  // virtual event object
  VirtualEvent virtualEvent;

  // student profile id
  String stdProfileId;

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

  // late Map<String, dynamic> config; // Configuration parameters
  // int localUid = -1;
  String agoraAppId = "4be7200f4d154bc0bed8a60f35b010e9", channelName = '';
  List<int> remoteUids = []; // Uids of remote users in the channel
  bool isJoined = false; // Indicates if the local user has joined the channel
  bool isBroadcaster = false; // Client role
  RtcEngine? agoraEngine; // Agora engine instance

  // List<dynamic>? eventComments; // event comments list

  // comment by set check
  // bool commentBySet = false;

  String commentText = ''; // comment field text

  // controller for comment field to clear it
  final TextEditingController _textEditingController = TextEditingController();

  late ScrollController _scrollController;

  double _previousMaxScrollExtent = 0.0;

  // remote users in the stream except the streamer
  int users = 0;

  // function to clear comment field using controller
  void clearTextField() {
    _textEditingController.clear();
  }

/*
  // get, create and set new field i.e. comment by' name in comments list using the profile id with the comment
  _setCommentByOnComment() async {
    // for loop to iterate through every comment
    for (int i = 0; i < eventComments!.length; i++) {
      // this creates a new pair in map, now set the name at the new key's value
      eventComments![i]['comment_by_name'] = await StudentProfile.empty()
          .profileCollection
          // using profile id with the comment get the student profile doc
          .doc(eventComments![i]['comment_by_profile_id'])
          .get()
          // when the doc is fetched return the value at the name field in the doc ie. the name of student
          .then((documentRef) => documentRef.get('name'));
    }

    // now set the flag as true
    setState(() {
      commentBySet = true;
    });
  }
  */

  bool scrolled = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
/*
    // when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('here');
      // Scroll to the last item when the widget is built

      _scrollController.addListener(() {
        print('in listener');
        if (_scrollController.hasClients && !scrolled) {
          _scrollToBottom();
          scrolled = true;
        }
        // _scrollListener();
        if (_scrollController.hasClients &&
            _scrollController.position.maxScrollExtent >
                _previousMaxScrollExtent) {
          _scrollToBottom();
          print('greater');
        }
        if (_scrollController.hasClients) {
          _previousMaxScrollExtent = _scrollController.position.maxScrollExtent;
        }
      });
    });
    */
    // Initialize Agora SDK
    initializeAgora();
    // print('here');
  }

/*
  void _scrollListener() {
    // WidgetsBinding.instance!.addPostFrameCallback((_) {
    if (_scrollController.position.maxScrollExtent > _previousMaxScrollExtent) {
      _scrollToBottom();
    }
    _previousMaxScrollExtent = _scrollController.position.maxScrollExtent;
    print('here');
    // });
  }
  */

  void _scrollToBottom() {
    print('scroll to bottom');
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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

      await agoraEngine!.enableVideo();

      await agoraEngine!
          .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
      // if (isBroadcaster) {
      await agoraEngine!.setClientRole(role: ClientRoleType.clientRoleAudience);
      // } else {
      // await _engine.setClientRole(ClientRole.Audience);
      // }

      // Register the event handler
      agoraEngine!.registerEventHandler(getEventHandler());

      // set channel name
      channelName = widget.channelName;

      // join the channel
      await agoraEngine!.joinChannel(
          token: "",
          channelId: channelName,
          uid: 0, // generate random uid
          options: ChannelMediaOptions());

      // set event comments
      // eventComments = widget.virtualEvent.comments;

      // set comment by on comments
      // _setCommentByOnComment();
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
        setState(() {
          users++; // the student who is watching the stream count on his/her side
        });
        // increase the count of users field in this event document in database (for uni side live stream screen)
        // final newUsers = widget.virtualEvent.usersCount! + 1;
        VirtualEvent.onlyId(eventId: widget.virtualEvent.eventId)
            .incrementUser();
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
        // except the stream all other users who have joined the stream increase the users count
        if (remoteUid != 1) {
          setState(() {
            users++;
          });
        }
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
          users--;
        });
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
    // print('max: ${_scrollController.position.maxScrollExtent}');
    // print('current: $_previousMaxScrollExtent');

    // if not null then return view
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
          // event title
          widget.virtualEvent.title != null
              ? Container(
                  decoration: BoxDecoration(
                      // color:
                      //     Color.fromARGB(255, 237, 237, 237).withOpacity(0.5),
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  margin: EdgeInsets.only(left: 25.0),
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    widget.virtualEvent.title!.length > 18
                        ? widget.virtualEvent.title!.substring(0, 18).trim()
                            as String
                        : widget.virtualEvent.title as String,
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                )
              : SizedBox(),
          // students in stream watching
          Row(children: [
            ElevatedButton.icon(
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
                users.toString(),
                style: TextStyle(color: Colors.white),
              ),
            ),
            // leave stream button
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
          ])
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
              margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              decoration: BoxDecoration(
                  // color: Color.fromARGB(255, 237, 237, 237).withOpacity(0.4),
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              height: 200.0,
              width: 250.0,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Container(
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // using the event comments in which coment by name is set to display comments
                    children: widget.virtualEvent.comments!
                        .map((commentMap) => ListTile(
                              leading: CircleAvatar(
                                radius: 15.0,
                                backgroundImage:
                                    AssetImage('assets/student.jpg'),
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
                  padding: EdgeInsets.only(left: 20.0),
                  width: MediaQuery.of(context).size.width - 100,
                  child: TextFormField(
                    controller: _textEditingController,
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
                          // get student name using id and set
                          String commentByName = await StudentProfile.empty()
                              .profileCollection
                              // using profile id with the comment get the student profile doc
                              .doc(widget.stdProfileId)
                              .get()
                              // when the doc is fetched return the value at the name field in the doc ie. the name of student
                              .then((documentRef) => documentRef.get('name'));

                          // add the new comment map in the list
                          widget.virtualEvent.comments!.add({
                            'comment': commentText,
                            'comment_by_name': commentByName,
                            'comment_by_profile_id': widget.stdProfileId,
                          }); // simple add comment_by_name by getting from db

                          /*

                          setState(() {
                            // set comment by set as false (so that again show loading when new comment comes and )
                            commentBySet = false;
                          });

                          // set name on new comment
                          _setCommentByOnComment(); // new comment update is shown b/c set state is called inside this method and so post comments varaible chhages are reflected
                          */

                          // print(postComments);
                          // call comment method
                          String? result = await widget.virtualEvent.comment();

                          if (result == 'success') {
                            // clear comment text field
                            clearTextField();

                            // clear comment text
                            setState(() {
                              commentText = '';
                            });
                          } else {
                            // set latest commments color as red

                            // show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error commenting')),
                            );
                          }
                        },
                        child: Icon(Icons.send, color: Colors.blue),
                      )
              ],
            ),
          ]),
    );
  }

// on call end button click
  void _onCallEnd(BuildContext context) async {
    // showAlertDialog(context);
    // decrease user count as user has left the stream now
    await VirtualEvent.onlyId(eventId: widget.virtualEvent.eventId)
        .decrementUser();
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
