import 'package:cloud_firestore/cloud_firestore.dart';

// self -help resources video class
class Video {
  String? url; // video url

  // videos collection
  final videosCollection = FirebaseFirestore.instance.collection('videos');

  // methods

  // constructors
  Video({
    required this.url,
  });

  Video.empty();

  // snapshot to videos list
  _snapshotToVideosList(QuerySnapshot<Map<String, dynamic>> snapshot) {
    try {
      // maps all docs to list of type video objects
      return snapshot.docs
          .map((doc) => Video(
                url: doc.get('url'),
              ))
          .toList();
    } catch (e) {
      print('Err in _snapshotToVideosList: $e');
      return null;
    }
  }

  // get all videos stream (list of type video objects)
  Stream<List<Video>?>? getAllVideosStream() {
    try {
      return videosCollection
          .snapshots()
          .map((snapshot) => _snapshotToVideosList(snapshot));
    } catch (e) {
      print('Err in getAllVideosStream: $e');
      return null;
    }
  }
}
