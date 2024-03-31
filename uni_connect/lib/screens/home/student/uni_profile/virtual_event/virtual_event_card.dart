import 'package:flutter/material.dart';
import 'package:uni_connect/classes/virtual_event.dart';
import 'package:uni_connect/screens/home/student/uni_profile/virtual_event/student_virtual_event_screen.dart';

class VirtualEventCard extends StatelessWidget {
  VirtualEventCard(
      {required this.uniName,
      required this.uniImage,
      required this.virtualEvent,
      required this.stdProfileId});

  // virtual event object
  VirtualEvent virtualEvent;

  // uni name
  String uniName;

  // uni profile image
  String uniImage;

  // student profile id
  String stdProfileId;

  @override
  Widget build(BuildContext context) {
    return virtualEvent.status == 'live'
        ? Container(
            // width: MediaQuery.of(context).size.width - 10,
            // height: MediaQuery.of(context).size.height - 380,
            // width: 380.0,
            // height: 380.0,
            padding: const EdgeInsets.all(8.0),
            // main card
            child: Card(
              elevation: 8.0,
              color: Colors.lightBlue,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              // container inside card
              child: Container(
                margin: const EdgeInsets.all(2.0),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    )),
                padding: EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // if there is no profiel picture path
                          uniImage == ''
                              ? CircleAvatar(
                                  backgroundImage: AssetImage('assets/uni.jpg'),
                                  radius: 18,
                                )
                              :
                              // if there is profile picture path
                              CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    uniImage,
                                    // width: 100,
                                    // height: 100,
                                  ),
                                  radius: 18,
                                ),
                          // virtualEvent.status == 'live'
                          // ?
                          // space
                          SizedBox(
                            width: 10.0,
                          ),
                          Text('${uniName.substring(0, 22).trim()}... is live')
                          // : Text('${uniName.substring(0, 22)} was live')
                        ],
                      ),
                    ),

                    // video image on clicking which live stream can be joined can be joined
                    // virtualEvent.status == 'live'
                    // ?
                    Center(
                      child: Container(
                          height: 100.0,
                          width: 100.0,
                          child: MaterialButton(
                              highlightElevation: 0.0,
                              highlightColor: Colors.black,
                              elevation: 0.0,
                              color: Colors.black,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            StudentVirtualEventScreen(
                                                channelName: virtualEvent
                                                    .uniProfileId as String,
                                                virtualEvent: virtualEvent,
                                                stdProfileId: stdProfileId)));
                              },
                              child: Image(
                                  image: AssetImage('assets/live-image.png')))),
                    ),
                    // :
                    // if event has ended
                    // Container(
                    //     height: 100.0,
                    //     width: 100.0,
                    //     child: Image(image: AssetImage('assets/play_video.jpg'))),

                    // Space
                    SizedBox(
                      height: 20.0,
                    ),

                    // live stream title
                    Text(virtualEvent.title as String),

                    // Space
                    SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
              ),
            ),
          )
        : SizedBox(
            height: 0.0,
          );
  }
}
