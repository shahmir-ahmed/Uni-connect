import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/student.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uni_connect/classes/university.dart';

class FollowUnFollowButton extends StatefulWidget {
  FollowUnFollowButton(
      {required this.uniProfileId,
      required this.stdProfileDocId,
      required this.followersList});

  String uniProfileId; // uni profile id
  String? stdProfileDocId; // student profile id
  List<dynamic> followersList; // uni followers list

  @override
  State<FollowUnFollowButton> createState() => _FollowUnFollowButtonState();
}

class _FollowUnFollowButtonState extends State<FollowUnFollowButton> {
  // student is following this uni flag
  bool following = false;

  // firebase messaging instance
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  showAlertDialog(
      BuildContext context, String message, List<dynamic> followingList) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("No"),
      onPressed: () {
        // close the alert dialog
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text(
        "Yes",
      ),
      onPressed: () async {
        // close the alert dialog
        Navigator.of(context).pop();
        
        // if follow button is clicked
        if (message == "Follow") {
          // update the existing following list of student by adding this uni in it
          followingList.add(widget.uniProfileId);

          // update the existing followers list of uni by adding this student in it
          widget.followersList.add(widget.stdProfileDocId);

          // add this uni profile id in student's following_unis list
          // if (widget.stdProfileDocId != null) {
          String result =
              await StudentProfile.withId(profileDocId: widget.stdProfileDocId!)
                  .followUnFollowUni(followingList);

          // add this student profile id in uni's followers list
          String result2 = await UniveristyProfile.withIdAndFollowers(
                  profileDocId: widget.uniProfileId,
                  followers: widget.followersList)
              .updateFollowers();

          // list updated successfullly
          // if (result == "success") {
          if (result == "success" && result2 == "success") {
            // set following as yes means show unfollow button
            setState(() {
              following = true;
            });

            // subscribe user to uniProfileId_followers topic (subscribes this device to the topic and send notification to the device which was used to follow the uni)
            await _firebaseMessaging
                .subscribeToTopic('${widget.uniProfileId}_followers');

            // hide any current snackbar shown
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            // show new snackbar
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${message}ed successfully!')));
          } else {
            // hide any current snackbar shown
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            // show new snackbar
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error ${message.toLowerCase()}ing!')));
          }
          // }
        } else {
          // remove this uni profile id from student's following_unis list
          // update the existing list and sent the list to function
          followingList.remove(widget.uniProfileId);

          // remove this uni profile id from student's following_unis list
          // update the existing list and sent the list to function
          widget.followersList.remove(widget.stdProfileDocId);

          // remove this uni profile id from student's following_unis list
          // if (widget.stdProfileDocId != null) {
          String result =
              await StudentProfile.withId(profileDocId: widget.stdProfileDocId!)
                  .followUnFollowUni(followingList);

          // remove this student profile id in uni's followers list
          String result2 = await UniveristyProfile.withIdAndFollowers(
                  profileDocId: widget.uniProfileId,
                  followers: widget.followersList)
              .updateFollowers();

          // if (result == "success") {
          // both lists updated successfullly
          if (result == "success" && result2 == "success") {
            // set following as no means show follow button
            setState(() {
              following = false;
            });

            // unsubscribe user to uniProfileId_followers topic
            await _firebaseMessaging
                .unsubscribeFromTopic('${widget.uniProfileId}_followers');

            // hide any current snackbar shown
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            // show new snackbar
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${message}ed successfully!')));
          } else {
            // hide any current snackbar shown
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            // show new snackbar
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error ${message.toLowerCase()}ing!')));
          }
          // }
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      // title: Text("$message?"),
      content: Text("$message university?"),
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

  @override
  Widget build(BuildContext context) {
    // get the value in the following unis list type stream
    final followingList = Provider.of<List<dynamic>?>(context);

    // get the value from the uni followers list type stream
    // final followersList = Provider.of<List<dynamic>?>(context);

    // print("followingList value: $followingList"); // empty list if empty and null if stream has no value passed yet
    // print("uniProfileId value: ${widget.uniProfileId}"); (correct)

    // check only if following list is present
    if (followingList != null) {
      // check if students following list has this uni profile id
      if (followingList.contains(widget.uniProfileId)) {
        // set following as true
        // setState(() {
        //   following = true;
        // });
        following = true;
      }
    }

    // based on following list stream have no value yet then show empty container
    return followingList == null
        ? Container()
        // now there is list so based on flag check that student is following the uni or not
        : following
            ? MaterialButton(
                onPressed: () {
                  // show alert message for confirmation of unfollowing
                  showAlertDialog(context, "Unfollow", followingList);
                },
                child: Text('Unfollow'),
                color: Colors.grey,
                textColor: Colors.white,
              )
            : MaterialButton(
                onPressed: () {
                  // show alert message for confirmation of following
                  showAlertDialog(context, "Follow", followingList);
                },
                child: Text('Follow'),
                color: Colors.blue,
                textColor: Colors.white,
              );
  }
}
