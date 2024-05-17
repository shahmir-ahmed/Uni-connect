import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uni_connect/screens/home/student/resources/blogs/blog_web_view.dart';

class BlogCard extends StatelessWidget {
  // blog id (for image)
  // blog title
  String? title;
  // blog url
  String? url;
  // blog category
  String? category;
  // blog cover image url
  String? coverImageUrl;
  // blog publishing date
  Timestamp? publishingDate;

  BlogCard(
      {required this.title,
      required this.url,
      required this.publishingDate,
      required this.coverImageUrl,
      required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 210, 209, 209)),
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      margin: EdgeInsets.symmetric(vertical: 10.0),
      // color: Colors.amber,
      height: 160.0,
      width: MediaQuery.of(context).size.width - 20,
      child: GestureDetector(
        onTap: () {
          // show blog in webview
          // print('tapped');
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => BlogWebView(blogUrl: url!)));
        },
        // card
        child: Card(
          elevation: 0.0,
          color: Colors.white,
          // main row
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // space
              SizedBox(
                width: 2.0,
              ),
              // cover image container
              Container(
                height: 150.0,
                width: 150.0,
                child: Image(
                  image: NetworkImage(coverImageUrl as String),
                  fit: BoxFit.contain,
                  // height: 180.0,
                ),
              ),
              // title, date column container
              Container(
                width: MediaQuery.of(context).size.width - 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // < 80 then show all
                    // > 80 then trim characters to 80 and add... at the end
                    title!.length > 80
                        ? Text('${title!.substring(0, 80).trim()}...')
                        : Text(title as String),
                    // space
                    SizedBox(
                      height: 5.0,
                    ),
                    // date
                    Text(
                      "${publishingDate!.toDate().day}-${publishingDate!.toDate().month}-${publishingDate!.toDate().year}",
                      style: TextStyle(
                          fontSize: 11.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
