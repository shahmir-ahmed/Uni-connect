import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/virtual_event.dart';
import 'package:uni_connect/screens/home/student/uni_profile/virtual_event/virtual_event_card.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';

class VirtualEventCards extends StatefulWidget {
  VirtualEventCards({required this.uniName, required this.uniProfileId});

  // uni profile id
  String uniProfileId;

  // uni name
  String uniName;

  @override
  State<VirtualEventCards> createState() => _VirtualEventCardsState();
}

class _VirtualEventCardsState extends State<VirtualEventCards> {
  @override
  Widget build(BuildContext context) {
    // consume virtual events stream
    final virtualEvents = Provider.of<List<VirtualEvent>?>(context);

    // print('virtualEvents: $virtualEvents');

    // check for this uni virtual events, filter out those and show only those
    return virtualEvents != null
        ? SingleChildScrollView(
            child: Column(
              children: virtualEvents
                  .where((event) => event.uniProfileId == widget.uniProfileId)
                  .map((event) => VirtualEventCard(
                        uniName: widget.uniName,
                        virtualEvent: event,
                      ))
                  .toList(),
            ),
          )
        : Container(
            child: WithinScreenProgress(text: 'Loading...'),
          );
  }
}
