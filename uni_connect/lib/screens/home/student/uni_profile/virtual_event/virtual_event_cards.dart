import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/virtual_event.dart';
import 'package:uni_connect/screens/home/student/uni_profile/virtual_event/virtual_event_card.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';

class VirtualEventCards extends StatefulWidget {
  VirtualEventCards({required this.uniName, required this.uniImage ,required this.uniProfileId, required this.stdProfileId});

  // uni profile id
  String uniProfileId;

  // uni name
  String uniName;

  // uni profile image
  String uniImage;

  // student profile id
  String stdProfileId;

  @override
  State<VirtualEventCards> createState() => _VirtualEventCardsState();
}

class _VirtualEventCardsState extends State<VirtualEventCards> {
  @override
  Widget build(BuildContext context) {
    // consume virtual events stream
    final virtualEvents = Provider.of<List<VirtualEvent>?>(context);

    // print('virtualEvents: $virtualEvents');

    // sort to show live events on top
    if (virtualEvents != null) {
      virtualEvents.sort((a, b) {
        if (a.status == 'live') {
          return -1; // 'live' status comes before 'not live'
        } else if (b.status == 'live') {
          return 1; // 'live' status comes before 'not live'
        } else {
          return 0;
        }
      });
    }

    // check for this uni virtual events, filter out those and show only those
    return virtualEvents != null
        ? SingleChildScrollView(
            child: Column(
              children: virtualEvents
                  .where((event) => event.uniProfileId == widget.uniProfileId)
                  .map((event) => VirtualEventCard(
                        uniName: widget.uniName,
                        uniImage: widget.uniImage,
                        virtualEvent: event,
                        stdProfileId: widget.stdProfileId
                      ))
                  .toList(),
            ),
          )
        : Container(
            child: WithinScreenProgress(text: 'Loading...'),
          );
  }
}
