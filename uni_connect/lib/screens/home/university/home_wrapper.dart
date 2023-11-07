import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_connect/classes/university.dart';
import 'package:uni_connect/screens/home/university/university_home.dart';
import 'package:uni_connect/screens/progress_screen.dart';

// wrapper to have the stream of uni profile
class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  // uni id from shared pref.
  String? uniId;

  // stream for uni profile data
  Stream<UniveristyProfile?>? stream;

  // function to get university profile doc id from shared preferences to show the profile of uni based on that uid
  Future getUniId() async {
    // get the shared preferences instance
    SharedPreferences pref = await SharedPreferences.getInstance();
    // get the shared preferences data
    String? uid = pref.getString('uid'); // user account doc id

    // set the uid
    setState(() {
      uniId = uid!;
    });
  }

  @override
  Widget build(BuildContext context) {
    // get the uni account doc id from shared pref.
    if (uniId == null) {
      // call only when uni id is not present
      getUniId();
    }

    // get the profile stream i.e this method gets the profile doc then image and then the stream so until the doc and image is retrieved stream is not returned and the stream provider cannot take future object so calling the method here when the uniId is set
    if (uniId != null && stream == null) {
      // if uni id is fetched (not null) and stream is null (initially)
      UniveristyProfile.empty().getProfileStream(uniId!).then((value) {
        // this is called again and again b/c setstate reruns build method and uniId is not null (previous condition)
        setState(() {
          stream = value; // set the stream when it is returned in future
        });
      });
    } // as soon as stream is returned here set it as value of stream provider

    // if uniId is not there show loading screen otherwise check stream object is there if not then show loading screen otherwsie set the stream as value of stream provider
    return uniId == null
        ? ProgressScreen(text: 'Loading home...')
        : stream == null
            ? ProgressScreen(text: 'Loading profile...')
            : 
            // university profile stream setup
            StreamProvider.value(
                value: stream, initialData: null, child: UniversityHome());
  }
}
