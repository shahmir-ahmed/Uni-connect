import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/university.dart';
import 'package:uni_connect/screens/home/student/uni_profile/university_profile_screen.dart';

class UniversitiesList extends StatefulWidget {
  // const UniversitiesList({super.key});

  UniversitiesList({required this.searchQuery});

  String searchQuery;

  @override
  State<UniversitiesList> createState() => _UniversitiesListState();
}

class _UniversitiesListState extends State<UniversitiesList> {
  // fetch the uni profile photo
  Future<String> _getProfilePhoto(profileDocId) async {
    // get university profile image
    // get the profile image of the university (if exists) (getting here because needs to show in search)
    final imagePath = await UniveristyProfile.empty()
            .getProfileImagePath(profileDocId) ??
        ''; // set empty path if there is no image found i.e. null is returned
    return imagePath;
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
                .where((uni) => uni!.name
                    .toLowerCase()
                    .contains(widget.searchQuery.toLowerCase()))
                .map((uni) => Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    padding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                    child: ListTile(
                      onTap: () {
                        // show uni profile screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UniProfileScreen(
                                    uniProfile: uni,
                                  )),
                        );
                      },
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
                .toList());
  }
}
