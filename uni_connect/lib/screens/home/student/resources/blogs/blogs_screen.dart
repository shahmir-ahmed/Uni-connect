import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uni_connect/classes/blog.dart';
import 'package:uni_connect/screens/home/student/resources/blogs/blog_card.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({super.key});

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  @override
  Widget build(BuildContext context) {
    // consume all blogs
    final blogsList = Provider.of<List<Blog>?>(context);

    return blogsList != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: blogsList
                .where((blog) =>
                    blog.category == "counseling" ||
                    blog.category == "school mgmt")
                .map((blog) => BlogCard(
                    title: blog.title,
                    url: blog.url,
                    publishingDate: blog.publishingDate,
                    coverImageUrl: blog.coverImageUrl,
                    category: blog.category))
                .toList()
              // Sort the posts based on category
              // ..sort((a, b) => b.category!.compareTo(a.category!))
            // then based on date published
            ..sort((a, b) => b.publishingDate!.compareTo(a.publishingDate!)),
            )
        : WithinScreenProgress.withPadding(text: '', paddingTop: 10.0);
  }
}
