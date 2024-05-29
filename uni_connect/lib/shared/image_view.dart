import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:photo_view/photo_view.dart';
import 'package:panorama/panorama.dart';
import 'package:uni_connect/screens/progress_screen.dart';
// import 'package:uni_connect/screens/within_screen_progress.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:uni_connect/screens/within_screen_progress.dart';

// widget to view an image when clicked in a photo view widget

// widget to view an image when clicked in a seperate window either it is a network and panorama, only network or asset
class ImageView extends StatelessWidget {
  // constructor
  ImageView(
      {required this.assetName,
      required this.isNetworkImage,
      required this.isPanorama,
      this.file});

  final String assetName; // image path
  late final bool isNetworkImage; // is the image network image
  late final bool isPanorama; // is the image panorama
  File? file; // file object of file image

  @override
  Widget build(BuildContext context) {
    // return Container(child: PhotoView(imageProvider: AssetImage(assetName))); // display image passed here in a phot view

    // if image passed is a network image and panorama i.e. 360
    if (isNetworkImage && isPanorama) {
      return Container(
          child: Panorama(
              child: Image(
                  image: NetworkImage(
                      assetName)))); // error of motion_sensors in gradle
    }
    // if the image is only network image and not panorama i.e simple image
    else if (isNetworkImage) {
      // if(isNetworkImage){
      return InteractiveViewer(
          child: Container(child: Image(image: NetworkImage(assetName))));
    }
    // if the image has no asset name and is panorama i.e file image in cache of system and in create post image is 360
    else if (assetName.isEmpty && isPanorama) {
      return Container(child: Panorama(child: Image(image: FileImage(file!))));
    }
    // if the image has no asset name i.e file image in cache of system
    else if (assetName.isEmpty) {
      return InteractiveViewer(
          child: Container(child: Image(image: FileImage(file!))));
    }
    // if the image is nor network nor panorama and nor asset image i.e. no media type of post in db (worst case)
    // show progress screen
    else {
      // return ProgressScreen.withBgColorBlack(text: '');
      return WithinScreenProgress.withPadding(
        text: '',
        paddingTop: 350.0,
      );
    }
  }
}
