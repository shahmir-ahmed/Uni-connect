import 'package:flutter/material.dart';
import 'package:uni_connect/classes/university.dart';
import 'package:uni_connect/screens/home/student/search/universites_list.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';

class FollowingUnisScreen extends StatefulWidget {
  FollowingUnisScreen({required this.followingUnisIds});

  // following unis profile id list
  List<dynamic> followingUnisIds;

  @override
  State<FollowingUnisScreen> createState() => _FollowingUnisScreenState();
}

class _FollowingUnisScreenState extends State<FollowingUnisScreen> {
  List<UniveristyProfile> followingUnisList = [];

  // load following list
  _loadFollowingUnisList() async {
    // get all unis student is following
    // for all following unis ids fetch the uni with complete details and add in the list
    for (var i = 0; i < widget.followingUnisIds.length; i++) {
      final uniObj = await UniveristyProfile.empty()
          .profileCollection
          .doc(widget.followingUnisIds[i])
          .get()
          .then((doc) => UniveristyProfile(
              profileDocId: doc.id ?? '',
              profileImage: '',
              name: doc.get("name").toString() ?? '',
              location: doc.get("location").toString() ?? '',
              type: doc.get('type') ?? '',
              description: doc.get('description') ?? '',
              fieldsOffered: doc.get('fields_offered') ?? [],
              followers: doc.get('followers') ?? []));

      followingUnisList.add(uniObj);
    }

    // sorting unis by name
    setState(() {
      followingUnisList.sort((a, b) => a.name.compareTo(b.name));
    }); // Instead of performing asynchronous work inside a call to setState(), first execute the work (without updating the widget state), and then synchronously update the state inside a call to setState().
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadFollowingUnisList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Following universities'),
        backgroundColor: Colors.blue[400],
      ),
      body: followingUnisList.isEmpty
          ? Center(child: WithinScreenProgress(text: 'Loading...'))
          : Container(
              padding: EdgeInsets.only(top: 20.0),
              // color: Colors.blueAccent,
              child: Column(
                // map each following uni to a tile
                children: followingUnisList
                    .map((followingUni) => UniversityTile(uniObj: followingUni))
                    .toList(),
              ),
            ),
    );
  }
}
