import 'package:flutter/material.dart';
import 'package:uni_connect/classes/virtual_event.dart';
import 'package:uni_connect/screens/home/student/uni_profile/virtual_event/student_virtual_event_screen.dart';

class VirtualEventCard extends StatelessWidget {
  VirtualEventCard(
      {required this.uniName,
      required this.virtualEvent,
      required this.stdProfileId});

  // virtual event object
  VirtualEvent virtualEvent;

  // uni name
  String uniName;

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
              color: Colors.white,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              // container inside card
              child: Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // uni profile image
                        Container(
                          padding: EdgeInsets.only(right: 15.0),
                          child: CircleAvatar(
                            backgroundImage: AssetImage('assets/uni.jpg'),
                          ),
                        ),
                        // virtualEvent.status == 'live'
                        // ?
                        Text('${uniName.substring(0, 22)}.. is live')
                        // : Text('${uniName.substring(0, 22)} was live')
                      ],
                    ),

                    // video image on clicking which live stream can be joined can be joined
                    // virtualEvent.status == 'live'
                    // ?
                    Container(
                        height: 100.0,
                        width: 100.0,
                        child: MaterialButton(
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
                    // :
                    // if event has ended
                    // Container(
                    //     height: 100.0,
                    //     width: 100.0,
                    //     child: Image(image: AssetImage('assets/play_video.jpg'))),

                    // Space
                    SizedBox(
                      height: 10.0,
                    ),

                    // live stream title
                    Text(virtualEvent.title as String),
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
