import 'package:flutter/material.dart';
import 'package:uni_connect/screens/home/university/create_post..dart';
import 'package:uni_connect/screens/home/university/settings_screen.dart';

class UniversityHome extends StatefulWidget {
  // String email; // university email

  // const StudentHome({super.key});
  // UniversityHome({required this.email}); // set email

  @override
  State<UniversityHome> createState() => _UniversityHomeState();
}

class _UniversityHomeState extends State<UniversityHome> {
  // selected index of bottom navigation bar
  int _selectedIndex = 1;

  // tabs for top navigation bar
  TabBar tabBar = TabBar(
      unselectedLabelColor: Colors.black,
      labelColor: Colors.blue[500],
      indicatorColor: Colors.blue[500],
      tabs: <Tab>[
        Tab(
            icon: Text(
          'Posts',
          style: TextStyle(fontSize: 16.0),
        )),
        Tab(
            icon: Text(
          'Live Videos',
          style: TextStyle(fontSize: 16.0),
        )),
        Tab(
            icon: Text(
          'About',
          style: TextStyle(fontSize: 16.0),
        )),
      ]);

  // bottom sheet to choose method to uplaod image
  void _showCreateOptions(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          color: Colors.white,
          height: 150,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // space above
                SizedBox(height: 12.0),
                // create post button
                ElevatedButton.icon(
                  onPressed: () {
                    // pop this create options bottom sheet
                    Navigator.pop(context);
                    // show create post widget
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CreatePost()));
                  },
                  icon: const Icon(Icons.post_add),
                  label: const Text("Create post"),
                ),
                // create virtual event button
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.event),
                  label: const Text("Create virtual event"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // show welcome message (cannot show)
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(
    //   SnackBar(
    //       content: Text('Welcome $widget.email!')),
    // );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Uni-connect'),
          centerTitle: true,
          backgroundColor: Colors.blue[500],
          actions: [
            // settings button
            MaterialButton(
                onPressed: () {
                  // show settings screen
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SettingsScreen()));
                },
                child: Icon(Icons.settings))
          ],
        ),
        body: Container(
          // main body column
          child: Column(children: [
            // top uni details header
            // container for row
            Container(
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.symmetric(vertical: 10.0),
              // width: MediaQuery.of(context).size.width,
              // height: MediaQuery.of(context).size.height / 4, // not set this b/c auto height based on the childs content
              // color: Colors.amber,
              // row 1
              // header row
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // column 1 inside row 1
                  // dp and name expanded widget to take the avalaible width i.e. 50% b/c column 2 is also inside expanded width so it also takes up the avalible which is 50%
                  Expanded(
                    // dp and name column
                    child: Container(
                      // color: Colors.blue,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          // uni profile picture
                          Image(
                            image: AssetImage('assets/arid-logo.jpg'),
                            width: 100,
                            height: 100,
                          ),

                          // space
                          SizedBox(
                            height: 8.0,
                          ),

                          // uni name
                          Text(
                            'PMAS Arid Agriculture University Rawalpindi',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // column 2 inside row 1
                  // column 2 for followers and location
                  Expanded(
                    // container to give height to expanded widget
                    child: Container(
                      // color: Colors.pink,
                      // height: 120.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // space
                          SizedBox(
                            height: 15.0,
                          ),
                          // folowers column
                          Column(
                            children: <Widget>[
                              // uni followers count
                              Text(
                                'Followers',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              // space
                              SizedBox(
                                height: 8.0,
                              ),
                              // followers count
                              Text(
                                '260',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),

                          // space
                          SizedBox(
                            height: 20.0,
                          ),

                          // location row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              // location icon
                              Icon(
                                Icons.location_on,
                                size: 20.0,
                              ),
                              // uni location
                              Expanded(
                                // to wrap location text
                                child: Container(
                                  margin: EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    'Murree Road, Shamsabad, Rawalpindi',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // container for navigation bar and its content
            /*
            Container(
              // margin: EdgeInsets.only(top: 80.0),
              child: DefaultTabController(
                length: 3,
                // column to contain tab bar and tab bar views
                child: Column(
                  children: [
                    // tab bar container
                    Container(
                      color: Colors.grey[300],
                      // top navigation bar (posts - live videos - about)
                      child: tabBar,
                    ),
                    // tab bar view container
                    Container(
                      // Tab bar views
                      child: TabBarView(children: [
                        // posts widget
                        MaterialApp(home: Center(child: Text('Posts'))),
          
                        // live videos widget
                        MaterialApp(home: Center(child: Text('Live videos'))),
          
                        // about widget
                        MaterialApp(home: Center(child: Text('About')))
                      ]),
                    )
                  ],
                ),
              ),
            )
            */

            // the tab bar with the items
            SizedBox(
              height: 50,
              child: AppBar(backgroundColor: Colors.grey[300], bottom: tabBar),
            ),

            // create widgets for each tab bar here
            Expanded(
              child: TabBarView(
                // tab bar views
                children: [
                  // first tab bar view widget
                  Container(
                    // color: Colors.red,
                    child: Center(
                      child: Text(
                        'Posts',
                      ),
                    ),
                  ),

                  // second tab bar viiew widget
                  Container(
                    // color: Colors.pink,
                    child: Center(
                      child: Text(
                        'Live videos',
                      ),
                    ),
                  ),

                  // third tab bar view widget
                  Container(
                    // color: Colors.orange,
                    child: Center(
                      child: Text(
                        'About',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
        // bottom navigation bar
        bottomNavigationBar: BottomNavigationBar(
            iconSize: 35.0,
            selectedFontSize: 18.0,
            unselectedFontSize: 18.0,
            backgroundColor: Colors.blue[200],
            selectedLabelStyle:
                TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            currentIndex: _selectedIndex,
            onTap: (value) {
              // setState(() {
              //   _selectedIndex = value;
              // });
              // on create option clicked show create options modal
              if (value == 0) {
                _showCreateOptions(context);
              }
            },
            items: [
              // create button
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.add_circle_outline_sharp,
                    color: Colors.black87,
                  ),
                  label: 'Create',
                  activeIcon: Icon(
                    Icons.add_circle_outline_sharp,
                    color: Colors.blue[600],
                  )),

              // profile button
              BottomNavigationBarItem(
                  // icon: Image(
                  //   image: AssetImage('assets/arid-logo.jpg'),
                  //   width: 30,
                  //   height: 30,
                  // ),
                  icon: Icon(
                    Icons.account_circle_sharp,
                    color: Colors.black87,
                  ),
                  label: 'Profile',
                  // activeIcon: Image(
                  //   image: AssetImage('assets/arid-logo.jpg'),
                  //   width: 30,
                  //   height: 30,
                  // )
                  activeIcon: Icon(
                    Icons.account_circle_sharp,
                    color: Colors.blue[600],
                  )),
            ]),
      ),
    );
  }
}
