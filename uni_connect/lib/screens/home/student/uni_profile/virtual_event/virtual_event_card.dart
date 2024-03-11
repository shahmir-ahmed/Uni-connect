import 'package:flutter/material.dart';
import 'package:uni_connect/classes/virtual_event.dart';
import 'package:uni_connect/screens/home/student/uni_profile/virtual_event/student_virtual_event_screen.dart';

class VirtualEventCard extends StatelessWidget {
  VirtualEventCard({required this.uniName, required this.virtualEvent});

  // virtual event object
  VirtualEvent virtualEvent;

  // uni name
  String uniName;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  virtualEvent.status == 'live'
                      ? Text('${uniName.substring(0, 20)} is live')
                      : Text('${uniName.substring(0, 20)} was live')
                ],
              ),

              // video image on clicking which live stream can be joined can be joined
              virtualEvent.status == 'live'
                  ? Container(
                      height: 100.0,
                      width: 100.0,
                      child: MaterialButton(
                        onPressed: () {
                           Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StudentVirtualEventScreen(channelName: virtualEvent.uniProfileId as String, eventTitle: virtualEvent.title as String)));
                        },
                        child: Image(image: AssetImage('assets/live-image.png'))))
                  :
                  // if event has ended
                  Container(
                      height: 100.0,
                      width: 100.0,
                      child: Image(image: AssetImage('assets/play_video.jpg'))),

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
    );
  }
}
