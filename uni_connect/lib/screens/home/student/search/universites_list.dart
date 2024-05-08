import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/university.dart';
import 'package:uni_connect/screens/home/student/uni_profile/university_profile_screen.dart';

class UniversitiesList extends StatefulWidget {
  // const UniversitiesList({super.key});

  UniversitiesList({required this.searchQuery});

  String searchQuery; // search query

  @override
  State<UniversitiesList> createState() => _UniversitiesListState();
}

class _UniversitiesListState extends State<UniversitiesList> {
  // uni profileimage
  // String? profileImage;

  // // fetch the uni profile photo
  // _getProfilePhoto(profileId) async {
  //   try {
  //     // get university profile image
  //     // get the profile image of the university (if exists) (getting here because needs to show in search)
  //     final imagePath = await UniveristyProfile.withId(profileDocId: profileId)
  //             .getProfileImagePath() ??
  //         ''; // set empty path if there is no image found i.e. null is returned
  //     setState(() {
  //       profileImage = imagePath;
  //     });
  //   } catch (e) {
  //     print('Error in _getProfilePhoto: $e');
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _getProfilePhoto(profileDocId); // id
  }

  @override
  Widget build(BuildContext context) {
    // get the latest value in the stream
    final unis = Provider.of<List<dynamic>?>(context);

    // print("unis: $unis");

    // based on value got or not got for unis from stream show unis
    return unis == null
        ? Column(
            children: [],
          )
        :
        // according to search query show unis in column
        // if the query is empty show all unis
        /*
        widget.searchQuery.isEmpty
            ? Column(
                children: unis
                    .map((uni) => Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        padding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 20.0),
                        child: ListTile(
                          tileColor: Color.fromARGB(255, 239, 239, 239),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                          leading: CircleAvatar(
                            backgroundImage: AssetImage("assets/uni.jpg"),
                            // radius: 30.0,
                          ),
                          title: Text("${uni!.name}"),
                          subtitle: Text("${uni.location}"),
                        )))
                    .toList(),
              )
            :
            */
        // if the query is not empty show those unis which have search query in their name
        Column(
            children: unis
                // search
                .where((uni) => uni!.name
                    .toLowerCase()
                    .contains(widget.searchQuery.toLowerCase()))
                // convert each object to tile
                .map((uni) => UniversityTile(
                      uniObj: uni,
                    ))
                .toList());
  }
}

class UniversityTile extends StatefulWidget {
  // const. for following uni list on profile
  UniversityTile({
    required this.uniObj,
  });

  // const. that do nothing on tile tap
  UniversityTile.unTappable(
      {super.key,
      required this.uniObj,
      required this.trailing,
      this.unTappable = true});

  // for add university screen in saved uni list
  UniversityTile.forSavedUniList(
      {required this.uniObj,
      required this.addUniInSavedUniList,
      this.forAddUniInSavedUniList = true}); // by default true for this const.

  UniveristyProfile uniObj; // uni object

  // for add uni in saved uni list tile (add university screen)
  bool forAddUniInSavedUniList = false;

  // for saved uni list tile (my list, edit list screen)
  bool unTappable = false;

  // trailing for edit list screen tile
  bool? trailing = false;

  // add uni in saved uni list method of following unis screen
  Function? addUniInSavedUniList;

  @override
  State<UniversityTile> createState() => _UniversityTileState();
}

class _UniversityTileState extends State<UniversityTile> {
  // uni profile photo
  String profileImage = '';

  // fetch the uni profile photo
  _getProfilePhoto() async {
    try {
      // get university profile image
      // get the profile image of the university (if exists) (getting here because needs to show in search)
      final imagePath = await UniveristyProfile.withId(
                  profileDocId: widget.uniObj.profileDocId)
              .getProfileImagePath() ??
          ''; // set empty path if there is no image found i.e. null is returned
      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          profileImage = imagePath;
        });
      }
    } catch (e) {
      print('Error in _getProfilePhoto: $e');
    }
  }

  // show alert dialog for adding uni in list
  showAlertDialog(BuildContext context) {
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

        // call add uni method of following unis screen
        widget.addUniInSavedUniList!(widget.uniObj);

        // show scaffold message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('University added in the list!')),
        );
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      // title: Text("Confirm?"),
      content: Text("Add university in list?"),
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
    _getProfilePhoto(); // fetch the uni profile image
    // print('here'); // when search query is updated and left to single uni in list (i.e. filtering uni) initstate is not being called on that object
  }

  // if widget changed (while searching filters new uni so change dp also)
  @override
  void didUpdateWidget(UniversityTile oldWidget) {
    if (oldWidget.uniObj != widget.uniObj) {
      _getProfilePhoto();
    }
    super.didUpdateWidget(oldWidget);
  }

  // build method
  @override
  Widget build(BuildContext context) {
    // print('profileImage $profileImage');
    // if (profileImage == '') {
    //   _getProfilePhoto();
    // }
    // tile tree
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        padding: widget.unTappable
            ? EdgeInsets.symmetric(vertical: 15.0, horizontal: 2.0)
            : EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        child: widget.unTappable
            ? Container(
                width: MediaQuery.of(context).size.width - 100,
                child: ListTile(
                  onTap: () {
                    // if for saved uni list tile (add university screen)
                    if (widget.forAddUniInSavedUniList) {
                      // then on tap ask from user to add this uni in list
                      showAlertDialog(context);
                    } else if (widget.unTappable) {
                      // if untappable is true then do nothing on tap
                    } else {
                      // if profile image is not fetched yet then do nothing on tap, if profile image is present then goto uni profile (refetched again at uni profile screen)
                      // if (profileImage != '') {
                      // show uni profile screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UniProfileScreen(
                                  uniProfile: widget.uniObj,
                                )),
                      );
                    }
                    // }
                  },
                  tileColor: Color.fromARGB(255, 239, 239, 239),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  leading: profileImage == ''
                      ? CircleAvatar(
                          backgroundImage: AssetImage("assets/uni.jpg"),
                          // radius: 30.0,
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(profileImage),
                        ),
                  title: Text("${widget.uniObj.name}"),
                  // subtitle: Text("${widget.uniObj.location}"),
                  trailing: widget.trailing == true
                      ? Icon(Icons.drag_indicator_rounded)
                      : null,
                ),
              )
            : ListTile(
                onTap: () {
                  // if for saved uni list tile (add university screen)
                  if (widget.forAddUniInSavedUniList) {
                    // then on tap ask from user to add this uni in list
                    showAlertDialog(context);
                  } else if (widget.unTappable) {
                    // if untappable is true then do nothing on tap
                  } else {
                    // if profile image is not fetched yet then do nothing on tap, if profile image is present then goto uni profile (refetched again at uni profile screen)
                    // if (profileImage != '') {
                    // show uni profile screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UniProfileScreen(
                                uniProfile: widget.uniObj,
                              )),
                    );
                  }
                  // }
                },
                tileColor: Color.fromARGB(255, 239, 239, 239),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                leading: profileImage == ''
                    ? CircleAvatar(
                        backgroundImage: AssetImage("assets/uni.jpg"),
                        // radius: 30.0,
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(profileImage),
                      ),
                title: Text("${widget.uniObj.name}"),
                subtitle: Text("${widget.uniObj.location}"),
              ));
  }
}
