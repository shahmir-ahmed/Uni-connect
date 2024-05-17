import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BlogWebView extends StatefulWidget {
  BlogWebView({required this.blogUrl});

  // blog url
  String blogUrl;

  @override
  State<BlogWebView> createState() => _BlogWebViewState();
}

class _BlogWebViewState extends State<BlogWebView> {
  WebViewController? controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initializing web view controller
    setState(() {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(widget.blogUrl));
    });
  }

  @override
  Widget build(BuildContext context) {
    return controller == null
        ? Scaffold(
            appBar: AppBar(
              title: Text('Blog'),
              backgroundColor: Colors.blue[400],
            ),
            body: Container(
                color: Colors.red,
                child: Center(child: WithinScreenProgress(text: ''))))
        : Scaffold(
            appBar: AppBar(
              title: Text('Blog'),
              backgroundColor: Colors.blue[400],
            ),
            body: WebViewWidget(controller: controller as WebViewController));
  }
}
