import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/blog.dart';
import 'package:uni_connect/screens/home/student/resources/blogs/blogs_screen.dart';
import 'package:uni_connect/screens/home/student/resources/blogs/blog_tile.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  // tabs for top navigation bar
  TabBar tabBar = TabBar(
      unselectedLabelColor: Color.fromARGB(255, 218, 218, 218),
      labelColor: Colors.white,
      indicatorColor: Colors.white,
      tabs: <Tab>[
        Tab(
            icon: Text(
          'Blogs',
          style: TextStyle(fontSize: 16.0),
        )),
        Tab(
            icon: Text(
          'Videos',
          style: TextStyle(fontSize: 16.0),
        )),
      ]);

  // build method
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Resources'),
          backgroundColor: Colors.blue[400],
          bottom: tabBar,
        ),
        body: TabBarView(
          children: [
            // blogs tab bar view widget
            /*
            Container(
              // color: Colors.red,
              child: Center(
                child: Text(
                  'Blogs',
                ),
              ),
            ),
            */
            SingleChildScrollView(
              child: StreamProvider.value(
                value: Blog.empty().getAllBlogsStream(),
                initialData: null,
                child: BlogsScreen())
            ),
            // videos tab bar view widget
            Container(
              // color: Colors.blue,
              child: Center(
                child: Text(
                  'Videos',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
