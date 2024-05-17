import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/student.dart';
import 'package:uni_connect/classes/university.dart';
import 'package:uni_connect/screens/home/student/saved_unis_list/edit_list_screen.dart';
import 'package:uni_connect/screens/home/student/search/universites_list.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';
import 'package:uni_connect/shared/constants.dart';

class SavedUnisListScreen extends StatefulWidget {
  const SavedUnisListScreen({super.key});

  @override
  State<SavedUnisListScreen> createState() => _SavedUnisListScreenState();
}

class _SavedUnisListScreenState extends State<SavedUnisListScreen> {
  // saved unis list with id, dp, name
  List<UniveristyProfile> savedUnisList = [];

  StudentProfile? stdProfileObj; // student profile object

  // list loaded var.
  bool listLoaded = false;

  // show unis with dp, name
  // load saved unis list to display
  _loadSavedUnisList() async {
    // for all saved unis ids fetch the uni with complete details and add in the list
    for (var i = 0; i < stdProfileObj!.savedUnis!.length; i++) {
      final uniObj = await UniveristyProfile.empty()
          .profileCollection
          .doc(stdProfileObj!.savedUnis![i])
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
      print('saved unis list');
    });
  }

  @override
  Widget build(BuildContext context) {
    // consume student profile object having saved unis list and following unis list, stream
    stdProfileObj = Provider.of<StudentProfile?>(context);

    // load unis list to diaply (with name and dp) if unis are fetched
    if (stdProfileObj != null && !listLoaded) {
      _loadSavedUnisList(); // load list to display
      listLoaded = true; // list loaded
    }

    // print('saved unis list obj: $objSavedUnisList');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Text('My List'), backgroundColor: Colors.blue[400]),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // space
              SizedBox(
                height: 15.0,
              ),
              // edit list button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (stdProfileObj != null) {
                        // show edit list screen
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                // show edit saved unis list screen
                                builder: (context) => EditSavedUnisListScreen(
                                      studentProfile:
                                          stdProfileObj as StudentProfile,
                                    )));
                        setState(() {
                          // empty current list
                          savedUnisList = [];
                          // set list loaded as false to load new list
                          listLoaded = false;
                        });
                      }
                    },
                    icon: Icon(Icons.edit),
                    label: Text("Edit list"),
                    style: mainScreenButtonStyle,
                  ),
                ],
              ),
              // space
              SizedBox(
                height: 15.0,
              ),
              // heading
              Text(
                'Your saved universities:',
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
              // space
              SizedBox(
                height: 25.0,
              ),
              // if value in stream is null then show loading screen
              stdProfileObj == null
                  ? WithinScreenProgress.withPadding(
                      text: '',
                      paddingTop: 0.0,
                    )
                  :
                  // if list is not empty then show unis
                  stdProfileObj!.savedUnis!.isNotEmpty
                      ? savedUnisList.isEmpty
                          ? WithinScreenProgress.withPadding(
                              text: '',
                              paddingTop: 0.0,
                            )
                          :
                          // saved unis list container
                          ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: savedUnisList.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // numbering
                                    // serial number
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
                                    // uni details tile
                                    UniversityTile.unTappable(
                                      uniObj: savedUnisList[index],
                                      trailing: false,
                                    ),
                                    // space
                                    SizedBox(
                                      width: 20.0,
                                    )
                                  ],
                                );

                                /*
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(children: [
                                    Text(savedUnisList[index].name.length > 32
                                        ? '${index + 1}. ${savedUnisList[index].name.substring(0, 32)}'
                                        : '${index + 1}. ${savedUnisList[index].name}'),
                                  ]),
                                );
                                */
                              })

                      // if list is empty then show message of not saved any yet
                      : Center(
                          child:
                              Text('You have not saved any universities yet.'))
            ],
          ),
        ),
      ),
    );
  }
}
