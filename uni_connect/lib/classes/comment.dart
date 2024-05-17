import 'package:cloud_firestore/cloud_firestore.dart';

// (edit: Need to make it a property of post not a seperate class)
class Comment {
  // attributes

  // comments collection of all posts
  final commentsCollection = FirebaseFirestore.instance.collection('comments');

  // document id of comments document of the post (which is the post id)
  String? docId;

  // comments list (in which comment and comment_by is saved in a list inside this list)
  // List<Map<String, String>>? comments; // b/c the recived list from firestore is giving error: type 'List<dynamic>' is not a subtype of type 'List<Map<String, String>>?
  List<dynamic>? comments;

  // methods

  // constructor
  Comment({required this.docId, required this.comments});

  //
  Comment.id({this.docId});

  //
  Comment.comments({this.comments});

  //
  Comment.empty();

  // snapshot of a document to comment object
  Comment? _snapshotToComment(snapshot) {
    try {
      // return comment object
      return Comment(
          docId: snapshot.id, comments: snapshot.get('comments') ?? [{}]);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // get the stream for comments for a post
  Stream<Comment?>? getCommentsStream() {
    try {
      // return stream of comment type object for a post
      return commentsCollection
          .doc(docId)
          .snapshots()
          .map((snapshot) => _snapshotToComment(snapshot));
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // delete comment document
  Future deleteDoc() async {
    try {
      await commentsCollection.doc(docId).delete();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // update comment document of the post by comment doc id
  updateComments() async {
    try {
      // update the comments list in the document
      await commentsCollection.doc(docId).set({'comments': comments});

      return 'success';
    } catch (e) {
      print('Err in updateComments: ${e.toString()}');
      return null;
    }
  }
}
