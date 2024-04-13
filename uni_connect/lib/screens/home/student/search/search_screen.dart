import 'package:flutter/material.dart';
import 'package:uni_connect/classes/student.dart';
import 'package:uni_connect/classes/university.dart';
import 'package:uni_connect/screens/home/student/search/universites_list.dart';
import 'package:uni_connect/shared/constants.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({required this.stdProfileId});

  // student profile id
  String stdProfileId;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // search field query
  String searchQuery = '';

  // recommended unis list
  List<UniveristyProfile> recommendedUnis = [];

  recommendUnis() async {
    // List<UniveristyProfile> recommendedUnis = [];

    // get all unis list
    List<UniveristyProfile> unis = await UniveristyProfile.empty()
        .profileCollection
        .get()
        .then((snapshot) => snapshot.docs
            .map((doc) => UniveristyProfile(
                profileDocId: doc.id ?? '',
                profileImage: '',
                name: doc.get("name").toString() ?? '',
                location: doc.get("location").toString() ?? '',
                type: doc.get('type') ?? '',
                description: doc.get('description') ?? '',
                fieldsOffered: doc.get('fields_offered') ?? [],
                followers: doc.get('followers') ?? [],
                uniAccountId: doc.get('university_id') ?? '',
                ))
            .toList());
    // get student fields of interest
    StudentProfile student = await StudentProfile.empty()
        .profileCollection
        .doc(widget.stdProfileId)
        .get()
        .then((snapshot) => StudentProfile.withFieldsAndFollowing(
            fieldsOfInterest: snapshot.get('fields_of_interest'),
            followingUnis: snapshot.get('following_unis')));

    // iterate through each uni in list
    for (var uni in unis) {
      // calculate the number of fields in common between student fields of interest and uni fields offered i.e. get those fields from uni fields offered which are which are present in student field of interest and then how many are they
      int commonFields = uni.fieldsOffered
          .where(
              (fieldOffered) => student.fieldsOfInterest.contains(fieldOffered))
          .length;
      // print('commonFields $commonFields');
      // now calculate relevance score based on common fields and students fields of interest e.g. 4 common / 10 interest = 0.4
      double relevanceScore =
          commonFields.toDouble() / student.fieldsOfInterest.length.toDouble();

      // print('relevanceScore $relevanceScore');
      if (relevanceScore > 0.3) {
        // add uni in recommended list
        recommendedUnis.add(uni);
        // set the relevance score if this uni
        uni.relevanceScore = relevanceScore;
      }
    }

    // check if student has already followed this uni then not show this uni in suggestions
    // filter out those unis which are not present in the following unis list
    recommendedUnis = recommendedUnis
        .where(
          (recommendedUni) =>
              !student.followingUnis.contains(recommendedUni.profileDocId),
        )
        .toList();

    setState(() {
      // Sort recommended posts by relevance score
      recommendedUnis
          .sort((a, b) => b.relevanceScore!.compareTo(a.relevanceScore!));
    });

    // print('recommendedUnis: $recommendedUnis');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recommendUnis(); // set recommended unis for the student
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Search'),
        backgroundColor: Colors.blue[400],
      ),

      // main container in screen in center
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          // color: Colors.orange,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 30.0),
                // color: Colors.amber,
                width: 280.0,
                height: 70.0,
                // search field
                child: TextField(
                  decoration: formInputDecoration.copyWith(
                      hintText: "Enter university name"),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.trim();
                    });
                  },
                ),
              ),
              // suggestions/ search results container
              Container(
                  // if search query is empty and suggestions list is also empty show blank screen
                  child: (searchQuery.isEmpty && recommendedUnis.isEmpty)
                      ? SizedBox()
                      :
                      // search query is empty and suggestions are present then show suggestions
                      (searchQuery.isEmpty && recommendedUnis.isNotEmpty)
                          ? Container(
                              margin: EdgeInsets.only(top: 40.0),
                              child: Column(
                                children: [
                                  Text(
                                    "Top Suggestions For You",
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  // space
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  // suggested unis list
                                  Column(
                                      children: recommendedUnis
                                          .map((recommededUni) =>
                                              UniversityTile(
                                                  uniObj: recommededUni))
                                          .toList())
                                ],
                              ))
                          :
                          // otherwise show search results
                          // search results conatiner
                          Container(
                              margin: EdgeInsets.only(top: 40.0),
                              child: Column(
                                children: [
                                  Text("Search results"),
                                  // results
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 0.0),
                                    // show unis in tile with logo, name
                                    // fetch the unis here from db which match the search
                                    // or
                                    // run a stream of unis profile and filter out unis according to search
                                    child: StreamProvider.value(
                                      initialData: null,
                                      value: UniveristyProfile.empty()
                                          .getUnisStream(),
                                      child: UniversitiesList(
                                          searchQuery: searchQuery),
                                    ),
                                    /*
                                        ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage:
                                                AssetImage("assets/uni.jpg"),
                                            // radius: 30.0,
                                          ),
                                          title: Text("Numl"),
                                          subtitle: Text("H9"),
                                        ),
                                        ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage:
                                                AssetImage("assets/uni.jpg"),
                                            // radius: 30.0,
                                          ),
                                          title: Text("Riphah"),
                                          subtitle: Text("I-10"),
                                        )
                                        */
                                  )
                                ],
                              ),
                            ))
            ],
          ),
        ),
      ),
    );
  }
}
