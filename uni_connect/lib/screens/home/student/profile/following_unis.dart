import 'package:flutter/material.dart';
import 'package:uni_connect/classes/university.dart';
import 'package:uni_connect/screens/home/student/search/universites_list.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';

class FollowingUnisScreen extends StatefulWidget {
  FollowingUnisScreen({required this.followingUnisIds});

  // constructor for add university in saved uni list screen
  FollowingUnisScreen.forSavedUnis(
      {this.screenTitle = true,
      required this.followingUnisIds,
      required this.savedUnisIds});

  // following unis profile id list
  List<dynamic> followingUnisIds;

  // saved unis profile id list
  List<dynamic>? savedUnisIds;

  // screen title only for add university in saved uni list screen
  bool? screenTitle;

  @override
  State<FollowingUnisScreen> createState() => _FollowingUnisScreenState();
}

class _FollowingUnisScreenState extends State<FollowingUnisScreen> {
  // unis to be displayed in screen (with complete details)
  List<UniveristyProfile>? followingUnisList;

  // new saved unis profile id list
  List<dynamic> newSavedUnisIds = [];

  // remove a uni which is added (after clicking on the uni by user) in the saved uni list, from following uni list
  _removeUniFromList(uniObj) {
    // remove and reflect change
    setState(() {
      followingUnisList!.remove(uniObj);
    });
  }

  // add uni in the saved uni list (selected by user from add uni screen)
  addUniInSavedUniList(UniveristyProfile uniObj) {
    // remove uni from following uni list
    _removeUniFromList(uniObj);
    // add the uni profile id in the edit list screen's list (directly from here changing the list in edit list screen without creating new list here and adding in it)
    // widget.savedUnisIds!.add(uniObj.profileDocId);
    newSavedUnisIds.add(uniObj.profileDocId);
  }

  // load following list
  _loadFollowingUnisList() async {
    followingUnisList = []; // initialize list
    // get all unis student is following
    // for all following unis ids fetch the uni with complete details and add in the list
    // if saved unis list is present then
    if (widget.savedUnisIds != null) {
      for (var i = 0; i < widget.followingUnisIds.length; i++) {
        // if this following uni is not in saved uni list then fetch details of the uni
        if (!widget.savedUnisIds!.contains(widget.followingUnisIds[i])) {
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
                  followers: doc.get('followers') ?? [],
                  uniAccountId: doc.get('university_id') ?? ''));

          followingUnisList!.add(uniObj);
        }
      }
    }
    // for following unis screen in profile
    else {
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
                followers: doc.get('followers') ?? [],
                uniAccountId: doc.get('university_id') ?? ''));

        followingUnisList!.add(uniObj);
      }
    }

    // sorting unis by name
    setState(() {
      followingUnisList!.sort((a, b) => a.name.compareTo(b.name));
    }); // Instead of performing asynchronous work inside a call to setState(), first execute the work (without updating the widget state), and then synchronously update the state inside a call to setState().
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // load following unis list
    _loadFollowingUnisList();
    // if the list is present copy here
    if (widget.savedUnisIds != null) {
      // copy the saved unis list (first time)
      newSavedUnisIds = List<dynamic>.from(widget.savedUnisIds as Iterable);
    }
  }

  @override
  Widget build(BuildContext context) {
    // for add uni in saved uni list return new list back when screen is closed
    return WillPopScope(
      onWillPop: () async {
        // pop the screen with new saved uni ids passed to edit screen
        Navigator.pop(context, newSavedUnisIds);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: widget.screenTitle == null
              ? Text('Following universities')
              : Text('Add university in list'),
          backgroundColor: Colors.blue[400],
        ),
        body: followingUnisList == null
            ? Center(child: WithinScreenProgress(text: 'Loading...'))
            // if no uni present in the list (when all following unis are added in the saved unis list) (this screen will not be shown in profilw when user has not followed any uni)
            : followingUnisList!.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Center(
                      child: Text(
                          'All universities are already added in the saved universities list.'),
                    ))
                : Container(
                    padding: EdgeInsets.only(top: 20.0),
                    // color: Colors.blueAccent,
                    child: Column(
                      // map each following uni to a tile
                      children: followingUnisList!
                          .map((followingUni) => widget.screenTitle == null
                              ? UniversityTile(uniObj: followingUni)
                              : UniversityTile.forSavedUniList(
                                  uniObj: followingUni,
                                  addUniInSavedUniList: addUniInSavedUniList))
                          .toList(),
                    ),
                  ),
      ),
    );
  }
}
