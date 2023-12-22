import 'package:flutter/material.dart';
import 'package:uni_connect/shared/constants.dart';

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
      appBar: AppBar(
        title: Text('Search'),
      ),

      // main container in screen in center
      body: Container(
          width: MediaQuery.of(context).size.width,
          // color: Colors.orange,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 30.0),
                // color: Colors.amber,
                width: 250.0,
                height: 50.0,
                // search field
                child: TextField(
                  decoration: formInputDecoration,
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
                          )

                          )
                      :
                      // search results conatiner
                      Container(
                          margin: EdgeInsets.only(top: 40.0),
                          child: Column(
                            children: [
                              Text("Search results"),
                              // results
                              Container(
                                // show unis in tile with logo, name
                                // fetch the unis here from db which match the search
                              )
                            ],
                          ),


                        ))
            ],
          )),
    );
  }
}
