import 'package:cloud_firestore/cloud_firestore.dart';

class Blog {
  // attributes
  // blog id
  // String? id;
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

  // blogs collection
  final blogsCollection = FirebaseFirestore.instance.collection('blogs');

  // methods

  // constructors
  Blog(
      {required this.title,
      required this.url,
      required this.publishingDate,
      required this.coverImageUrl,
      required this.category});

  Blog.empty();

  // snapshot to blogs list
  _snapshotToBlogsList(QuerySnapshot<Map<String, dynamic>> snapshot) {
    try {
      // maps all docs to list of type blog objects
      return snapshot.docs
          .map((doc) => Blog(
              title: doc.get('title'),
              url: doc.get('url'),
              publishingDate: doc.get('date_published'),
              coverImageUrl: doc.get('cover_image_url'),
              category: doc.get('category')))
          .toList();
    } catch (e) {
      print('Err in _snapshotToBlogsList: $e');
      return null;
    }
  }

  // get all blogs stream (list of type blog objects)
  Stream<List<Blog>?>? getAllBlogsStream() {
    try {
      return blogsCollection
          .snapshots()
          .map((snapshot) => _snapshotToBlogsList(snapshot));
    } catch (e) {
      print('Err in getAllBlogsStream: $e');
      return null;
    }
  }
}
