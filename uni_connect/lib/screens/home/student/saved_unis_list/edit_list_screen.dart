import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:uni_connect/classes/student.dart';
import 'package:uni_connect/classes/university.dart';
import 'package:uni_connect/screens/home/student/profile/following_unis.dart';
import 'package:uni_connect/screens/home/student/search/universites_list.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';
import 'package:uni_connect/shared/constants.dart';

class EditSavedUnisListScreen extends StatefulWidget {
  EditSavedUnisListScreen({required this.studentProfile});

  // student profile object with saved and following unis list
  StudentProfile studentProfile;

  @override
  State<EditSavedUnisListScreen> createState() =>
      _EditSavedUnisListScreenState();
}

class _EditSavedUnisListScreenState extends State<EditSavedUnisListScreen> {
  // saved unis list with id, dp, name
  List<UniveristyProfile> savedUnisList = [];

  // show unis with dp, name
  // load following list
  _loadSavedUnisList() async {
    // initailize list
    savedUnisList = [];
    // for all saved unis ids fetch the uni with complete details and add in the list
    for (var i = 0; i < widget.studentProfile.savedUnis!.length; i++) {
      final uniObj = await UniveristyProfile.empty()
          .profileCollection
          .doc(widget.studentProfile.savedUnis![i])
          .get()
          .then((doc) => UniveristyProfile.forSavedUni(
                profileDocId: doc.id ?? '',
                profileImage: '',
                name: doc.get("name").toString() ?? '',
                location: doc.get("location").toString() ?? '',
              ));

      savedUnisList.add(uniObj);
    }
    // updating widget UI
    setState(() {
      print('updating saved unis list');
    });
  }

  // show alert dialog for removing uni from list
  showAlertDialog(BuildContext context, index) {
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
        setState(() {
          // remove uni id from widget list
          widget.studentProfile.savedUnis!.removeAt(index);
          // remove uni from unis display list
          savedUnisList.removeAt(index);
        });
        // show scaffold message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('University removed from the list!')),
        );
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      // title: Text("Confirm?"),
      content: Text("Remove university from list?"),
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

  // show alert dialog for leaving screen
  showAlertDialog2(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Discard"),
      onPressed: () {
        // close the alert dialog
        Navigator.of(context).pop();
        // close the screen
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        "Keep editing",
      ),
      onPressed: () async {
        // close the alert dialog
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Leave list?"),
      content: Text("Your edits won't be saved"),
      actions: [
        cancelButton,
        continueButton,
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

  // show alert dialog for leaving screen
  showAlertDialog3(BuildContext context) {
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
        // save the new list in db
        final result = await StudentProfile.withIdAndSavedUnisList(
                profileDocId: widget.studentProfile.profileDocId,
                savedUnis: widget.studentProfile.savedUnis)
            .updateSavedUnisList();
        if (result == 'success') {
          // show scaffold message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('List saved successfully!')),
          );
        } else {
          // show scaffold message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error while saving list!')),
          );
        }
        // close edit list screen
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Save list?"),
      content: Text("Are you sure you want to save changes to list?"),
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
  void initState() {
    // TODO: implement initState
    super.initState();
    // load unis tbe displayed using ids
    _loadSavedUnisList();
  }

  // called when back is pressed on the screen
  Future<bool> _onWillPop() async {
    return (await showAlertDialog2(context)) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // reorderable list decorator
    Widget proxyDecorator(
        Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          // final double animValue = Curves.easeInOut.transform(animation.value);
          // final double elevation = lerpDouble(0, 6, animValue)!;
          return Material(
            // elevation: elevation,
            color: Colors.white,
            // shadowColor: Colors.white,
            child: child,
          );
        },
        child: child,
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Edit list'),
          backgroundColor: Colors.blue[400],
          actions: [
            // save list button
            MaterialButton(
                // minWidth: 10.0,
                highlightElevation: 0.0,
                highlightColor: Colors.blue[400],
                onPressed: () async {
                  // ask conformation
                  showAlertDialog3(context);
                },
                color: Colors.blue[400],
                elevation: 0.0,
                // minWidth: 18.0,
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                ))
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              // add uni in list button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      // show following unis screen
                      // returns saved unis list (copy the returned list here)
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              // show student following unis list screen
                              builder: (context) =>
                                  FollowingUnisScreen.forSavedUnis(
                                      followingUnisIds:
                                          widget.studentProfile.followingUnis,
                                      savedUnisIds:
                                          widget.studentProfile.savedUnis)));
                      // print('result: $result');
                      // copy the list in the widget here now because this is the new list (either changed or not changed)
                      widget.studentProfile.savedUnis =
                          List<dynamic>.from(result as Iterable);
                      // print(
                      //     'widget.studentProfile.savedUnis: ${widget.studentProfile.savedUnis}');
                      // empty the current list
                      // savedUnisList = [];
                      // load new list
                      _loadSavedUnisList();
                    },
                    icon: Icon(Icons.add),
                    label: Text("Add university"),
                    style: mainScreenButtonStyle,
                  ),
                ],
              ),
              // space
              SizedBox(
                height: 25.0,
              ),
              // instruction to drag
              Text(
                  'Long press and drag up or down to change the order of universities.'),
              // space
              SizedBox(
                height: 25.0,
              ),
              // if ids list is not empty then show unis
              widget.studentProfile.savedUnis!.isNotEmpty
                  ?
                  // if not ready
                  savedUnisList.isEmpty
                      ? WithinScreenProgress.withPadding(
                          text: '',
                          paddingTop: 0.0,
                        )
                      :
                      // if list to display is ready
                      // saved unis list container
                      ReorderableListView.builder(
                          proxyDecorator: proxyDecorator,
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              if (oldIndex < newIndex) {
                                newIndex -= 1;
                              }
                              // sort the display list
                              final item = savedUnisList.removeAt(oldIndex);
                              savedUnisList.insert(newIndex, item);

                              // sort the ids list also
                              final id = widget.studentProfile.savedUnis!
                                  .removeAt(oldIndex);
                              widget.studentProfile.savedUnis!
                                  .insert(newIndex, id);
                            });
                          },
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: savedUnisList.length,
                          itemBuilder: (context, index) {
                            return Row(
                              key: Key('$index'),
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // numbering
                                // serial number
                                /*
                                  Text(
                                    '${index + 1}.',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                  // space
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  */
                                // remove uni button
                                IconButton(
                                    // key: Key('$index'),
                                    onPressed: () {
                                      // ask to remove uni from list
                                      showAlertDialog(context, index);
                                    },
                                    icon: Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                      size: 35.0,
                                    )),
                                // uni details tile
                                UniversityTile.unTappable(
                                  // key: Key('$index'),
                                  uniObj: savedUnisList[index],
                                  trailing: true,
                                ),
                              ],
                            );

                            /*
                              return Row(
                                children: [
                                  Text(savedUnisList[index].name.length > 32
                                      ? '${index + 1}. ${savedUnisList[index].name.substring(0, 32)}'
                                      : '${index + 1}. ${savedUnisList[index].name}'),
                                  IconButton(
                                      onPressed: () {
                                        // ask to remove uni from list
                                        showAlertDialog(context, index);
                                      },
                                      icon: Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                        size: 35.0,
                                      )),
                                ],
                              );
                              */
                            /*
                              return Row(children: [
                                // numbering
                                Text('${index + 1}'),
                                // tile and remove button container
                                Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0))),
                                    // padding: EdgeInsets.symmetric(
                                    //     vertical: 5.0, horizontal: 0.0),
                                    child: ListTile(
                                      onTap: () {
                                        // do nothing
                                      },
                                      tileColor:
                                          Color.fromARGB(255, 239, 239, 239),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.0))),
                                      leading: savedUnisList[index]
                                                  .profileImage ==
                                              ''
                                          ? CircleAvatar(
                                              backgroundImage: AssetImage(
                                                  "assets/uni.jpg"),
                                              // radius: 30.0,
                                            )
                                          : CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  savedUnisList[index]
                                                      .profileImage),
                                            ),
                                      title: Text(
                                          "${savedUnisList[index].name}"),
                                      // subtitle: Text("${widget.uniObj.location}"),
                                      trailing: // remove uni button
                                          IconButton(
                                              onPressed: () {
                                                // ask to remove uni from list
                                                showAlertDialog(
                                                    context, index);
                                              },
                                              icon: Icon(
                                                Icons.cancel,
                                                color: Colors.red,
                                                size: 35.0,
                                              )),
                                    )),
                              ]);
                              */
                          },
                        )

                  // if list is empty then show message of not saved any yet
                  : Center(child: Text('No university added yet.'))
            ],
          ),
        ),
      ),
    );
  }
}
