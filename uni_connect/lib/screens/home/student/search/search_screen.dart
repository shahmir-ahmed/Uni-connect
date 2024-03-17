import 'package:flutter/material.dart';
import 'package:uni_connect/classes/university.dart';
import 'package:uni_connect/screens/home/student/search/universites_list.dart';
import 'package:uni_connect/shared/constants.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // search field query
  String searchQuery = '';

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
        child: StreamProvider.value(
          initialData: null,
          value: UniveristyProfile.empty().getUnisStream(),
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
                      child: searchQuery.isEmpty
                          ? Container(
                              margin: EdgeInsets.only(top: 40.0),
                              child: Column(
                                children: [
                                  Text("Top Suggestions For You"),
                                  // suggested unis list
                                ],
                              ))
                          :
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
                                    child: UniversitiesList(
                                        searchQuery: searchQuery),
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
              )),
        ),
      ),
    );
  }
}
