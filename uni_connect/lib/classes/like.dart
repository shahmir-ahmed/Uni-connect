import 'package:cloud_firestore/cloud_firestore.dart';

// Post ---> has 1..* likes (edit: so need to make it a property of post not a seperate class)
class Like {
  // atts.

  // collection object
  final likesCollection = FirebaseFirestore.instance.collection('likes');

  // document id
  String? docId; // like doc id is the post id

  // uni profile id
  // String? uniProfileId;

  // list of user ids who have liked the post
  List<dynamic>? likedBy;

  // constructor
  Like({this.likedBy, this.docId});

  // 2
  Like.likedBy({this.likedBy});

  // 3
  Like.id({this.docId});

  // 4
  Like.empty();

  // methods

  // likes document snapshot to like type object
  _snapshotToLike(DocumentSnapshot snapshot) {
    try {
      return Like(docId: snapshot.id, likedBy: snapshot.get('liked_by') ?? []);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // get the like stream of a specific post
  Stream<Like?>? getLikesStream() {
    try {
      // return the stream of like document for the post
      return likesCollection
          .doc(docId)
          .snapshots()
          .map((snapshot) => _snapshotToLike(snapshot));
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // like a post
  Future<String?> likePost() async {
    try {
      // set the new liked by list of this like document
      await likesCollection.doc(docId).set({'liked_by': likedBy});
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // unlike a post (same update list logic)
  Future<String?> unLikePost() async {
    try {
      // set the new liked by list of this like document
      await likesCollection.doc(docId).set({'liked_by': likedBy});
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // delete like document
  Future deleteDoc() async {
    try {
      await likesCollection.doc(docId).delete();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
