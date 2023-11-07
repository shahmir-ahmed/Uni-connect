import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:uni_connect/classes/comment.dart';
import 'package:uni_connect/classes/like.dart';

// post class
class Post {
  // attributes
  // posts collection
  final postsCollection = FirebaseFirestore.instance.collection('posts');

  // post image/video file
  // File? media;
  String? mediaPath;

  // post media type (image/360 image/video)
  String? mediaType;

  // post description
  String? description;

  // foreign key of uni profile doc id
  String? uniProfileId;

  // post id
  String? postId;

  // methods
  // constructor
  Post(
      {required this.postId,
      required this.mediaType,
      required this.mediaPath,
      required this.description,
      required this.uniProfileId});

  Post.withUniId(
      {required this.mediaType,
      required this.mediaPath,
      required this.description,
      required this.uniProfileId});

  // constructor
  Post.withoutAnyId(
      {required this.mediaType,
      required this.mediaPath,
      required this.description});

  // constructor
  Post.withId(
      {required this.postId,
      required this.mediaType,
      required this.mediaPath,
      required this.description});

  // constructor
  Post.withoutMedia(
      {required this.postId,
      required this.mediaType,
      required this.description,
      this.uniProfileId});

  // empty constructor
  Post.empty();

  // create post in db
  Future<String?> createPost() async {
    try {
      // create post doc
      DocumentReference documentReference = await postsCollection.add({
        'post_description': description,
        'post_media_type': mediaType,
        'university_profile_id': uniProfileId // or uni id can be named
      });

      // get newly created post id
      String postId = documentReference.id;

      // upload post media with the post id as media file name
      final ref = storage.FirebaseStorage.instance
          .ref()
          .child('post_media')
          .child(
              postId); // get the reference to the file in the post_media folder

      await ref.putFile(File(mediaPath!)); // upload the media at the reference

      // create likes document in the likes collection for this post
      Like.empty().likesCollection.doc(postId).set({'liked_by': []});

      // create comments document in the comments collection for this post
      Comment.empty().commentsCollection.doc(postId).set({
        'comments': [
          // commnet_by and comment Map for each comment
          // {}
        ]
      });

      return 'success';
    } catch (e) {
      print(e.toString());
      return 'error';
    }
  }

  // converting and returning snapshot of posts collection to list of posts object
  List<Post>? _postsCollectionToList(QuerySnapshot collection) {
    try {
      return collection.docs
          .map((doc) => Post.withoutMedia(
              postId: doc.id,
              mediaType: doc.get('post_media_type') ??
                  '', // issue was here in name field so put try catch in every function
              // media: media,
              description: doc.get('post_description') ??
                  '', // issue was here in post_description field so put try catch in every function
              uniProfileId: doc.get('university_profile_id') ?? ''))
          .toList();
    } catch (e) {
      print("ERR in _postsCollectionToList function: ${e.toString()}");
    }
  }

  // get all posts from db
  // view all posts of uni
  // stream of all posts
  Stream<List<Post>?>? getPostsStream() {
    // take stream of all the posts and then filter out the posts of the university based on the profile id in the uni posts widget b/c specific docs stream cannot be created
    try {
      return postsCollection
          .snapshots()
          .map((collection) => _postsCollectionToList(collection));
    } catch (e) {
      print("ERR in getPostsStream: ${e.toString()}");
    }
  }

  // get post media path (image/video)
  Future<String> getPostMediaPath() async {
    // filename i.e. id of the post
    try {
      // get ref object to the post media file
      final ref = storage.FirebaseStorage.instance
          .ref()
          .child('post_media')
          .child(postId!);

      final mediaUrl = await ref.getDownloadURL(); // get the file/media path

      // return the url of media
      return mediaUrl;
    } catch (e) {
      print("Err in retrieving post media: ${e.toString()}");
      return '';
    }
  }

  // view post

  // updadte post document only (I.e. post descrription in doc)
  String? updatePostDoc() {
    try {
      // update document description
      postsCollection.doc(postId).update({
        'post_description': description,
      });
      return 'success';
    } catch (e) {
      print(e.toString());
      return 'error';
    }
  }

/*
  // update post image
  Future<String> updatePostImage() async {
    try {
      // update image
      final ref = storage.FirebaseStorage.instance
          .ref()
          .child('post_media')
          .child(postId!);

      // overwrite current file media with the name at the location
      // put new file object at the ref by overwriting the current
      // ref.writeToFile(File(mediaPath!)); // not workking
      await ref.delete(); // delete the current object at path and
      ref.putFile(File(mediaPath!)); // put new file at the reference

      return 'success'; // return
    } catch (e) {
      print(e);
      return 'error';
    }
  }
*/

  // update post doc and image
  Future<String> updatePost() async {
    try {
      // update document data
      postsCollection.doc(postId).update({
        'post_description': description,
        'post_media_type': mediaType,
      });

      // update image
      final ref = storage.FirebaseStorage.instance
          .ref()
          .child('post_media')
          .child(postId!);

      // overwrite current file media with the name at the location
      // put new file object at the ref by overwriting the current
      // ref.writeToFile(File(mediaPath!)); // not workking
      await ref.delete(); // delete the current object at path and
      ref.putFile(File(mediaPath!)); // put new file at the reference

      return 'success'; // return
    } catch (e) {
      print(e);
      return 'error';
    }
  }

  // delete post
  Future deletePost() async {
    try {
      // delete post media
      final ref = storage.FirebaseStorage.instance
          .ref()
          .child('post_media')
          .child(postId!);
      // delete the media at the reference
      await ref.delete();

      // delete post document
      await postsCollection.doc(postId).delete();

      // delete post's likes document
      await Like.id(docId: postId).deleteDoc();

      // delete post's comments document
      await Comment.id(docId: postId).deleteDoc();
    } catch (e) {
      print("ERR in deletePost: ${e.toString()}");
    }
  }
}
