import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;

// University class
class University {
  String? id;
  String? email;
  String? password;

  // university accounts collection (creates cllection if not already exists)
  final universityCollection =
      FirebaseFirestore.instance.collection('universities');

  // constructor
  University({required this.email, required this.password});

  University.withId(
      {required this.id, required this.email, required this.password});

  University.withIdPassword({required this.id, required this.password});

  University.id({required this.id});

  // login
  Future<String?> login() async {
    try {
      // check if account with the username and passowrd exists or not
      QuerySnapshot snapshot = await universityCollection
          .where('username', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      // if no account with username and password exists
      if (snapshot.docs.isEmpty) {
        // print('here');
        return 'Invalid';
      }
      // if account with username and password exists
      else {
        // return uni account doc id
        // return 'Valid';
        return snapshot.docs.first.id;
      }
    } catch (e) {
      print("EXCEPTION: ${e.toString()}");
      // print('HERE');
      return null;
    }
  }

  // register
  Future<String?> register(UniveristyProfile uniProfile) async {
    try {
      // check account with the username already exists or not
      QuerySnapshot snapshot =
          await universityCollection.where('username', isEqualTo: email).get();

      // if no doc found with the username
      if (snapshot.docs.isEmpty) {
        // register university account
        // create university account document
        DocumentReference documentReference = await universityCollection
            .add({'username': email, 'password': password});

        // get the newly created document id
        String docId = documentReference.id;

        // create university profile document with university id field as university account document id
        String? result = await uniProfile.createProfile(docId);

        // error creating profile
        if (result == null) {
          return null;
        }
        // profile successfully created
        else {
          return docId; // doc id
        }
      } else {
        // account with the username already exists
        return 'exists';
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
/*
  // document snapshot to university type object with id
  _snapshotToUniObject(snapshot) {
    try {
      return University.withIdPassword(
          id: snapshot.id,
          email: snapshot.get('username') ?? '',
          password: snapshot.get('password') ?? '');
    } catch (e) {
      print('Err in _snapshotToUniObject(): ${e.toString()}');
      return null;
    }
  }

  // get username and password stream
  Stream<University?>? getAccountStream() {
    try {
      return universityCollection
          .doc(id)
          .snapshots()
          .map((snapshot) => _snapshotToUniObject(snapshot));
    } catch (e) {
      print('Err in getAccountStream(): ${e.toString()}');
      return null;
    }
  }
  */

  // update password using id
  Future<String> updatePassword() async {
    try {
      await universityCollection.doc(id).update({'password': password});
      return 'success';
    } catch (e) {
      print('Err in updatePassword(): ${e.toString()}');
      return 'error';
    }
  }
}

// University Profile class
class UniveristyProfile {
  // university profile attributes
  late String name;
  late String location;
  late String type;
  late String description;
  late String profileDocId;
  late String profileImage;
  late List<dynamic> fieldsOffered;
  late List<dynamic> followers;
  String? uniAccountId;

  double?
      relevanceScore; // relevance score of this uni for student recommendations

  // university profile collection
  final profileCollection =
      FirebaseFirestore.instance.collection('university_profiles');

  // constructor for when registering university account
  UniveristyProfile.forRegister(
      {required this.name, required this.location, required this.type});

  // empty constructor
  UniveristyProfile.empty();

  // for profile
  UniveristyProfile({
    required this.profileDocId,
    required this.profileImage,
    required this.name,
    required this.location,
    required this.type,
    required this.description,
    required this.fieldsOffered,
    required this.followers,
    required this.uniAccountId,
  });

  // for profile
  UniveristyProfile.updateProfile(
      {required this.profileDocId,
      required this.profileImage,
      required this.name,
      required this.location,
      required this.type,
      required this.description,
      required this.fieldsOffered});

  // for search result
  UniveristyProfile.forSearch({
    required this.profileDocId,
    required this.profileImage,
    required this.name,
    required this.location,
  });

  // for with id object
  UniveristyProfile.withId({
    required this.profileDocId,
  });

  // for with followers object
  UniveristyProfile.withFollowers({
    required this.followers,
  });

  // for with id and followers object
  UniveristyProfile.withIdAndFollowers({
    required this.profileDocId,
    required this.followers,
  });

  // for with fields offered object
  UniveristyProfile.forSuggestion({
    required this.fieldsOffered,
  });

  // for saved unis list
  UniveristyProfile.forSavedUni({
    required this.profileDocId,
    required this.profileImage,
    required this.name,
    required this.location,
  });

  // create profile in database (when registering)
  Future<String?> createProfile(String uniDocId) async {
    try {
      // create university profile document with id as university account document id
      DocumentReference documentReference = await profileCollection.add({
        'name': name,
        'description': "",
        'location': location,
        'type': type,
        'fields_offered': [],
        'followers': [],
        'university_id': uniDocId
      });

      // return 'success'; // success message

      return documentReference.id; // profile doc id
    } catch (e) {
      print("EXCEPTION: ${e.toString()}");
      return null;
    }
  }

  // get university profile image path
  Future getProfileImagePath() async {
    try {
      final ref = storage.FirebaseStorage.instance
          .ref()
          .child('uni_profile_images')
          .child(profileDocId);

      // print('ref: $ref'); // to check what gets print when there is no image of this name : ref: Reference(app: [DEFAULT], fullPath: uni_profile_images/c4JoUpPtAvIYGcWZx6or.jpg)
      // print('here');
      final imageUrl = await ref
          .getDownloadURL(); // get the image path // error is here of object not found so null is returned in catch block

      print('imageurl: $imageUrl');

      return imageUrl;
    } catch (e) {
      print("Err in retrieving image: ${e.toString()}");
      return null;
    }
  }

  // document snapshot to university profile object
  UniveristyProfile _documentSnapshotToUniversityProfile(
      // DocumentSnapshot documentSnapshot, String imagePath) 
      DocumentSnapshot documentSnapshot) 
      {
    // print('imagePath: $imagePath');
    // get the image path again when document data is update so that the same image path when setting up stream is not used again when document data is updated (edit cannot get here so get in the UI when new obj arrives)
    // return profile object with all the details set
    return UniveristyProfile(
        profileDocId: documentSnapshot.id,
        profileImage: '',
        name: documentSnapshot.get('name'),
        location: documentSnapshot.get('location'),
        type: documentSnapshot.get('type'),
        description: documentSnapshot.get('description'),
        fieldsOffered: documentSnapshot.get('fields_offered') ?? [],
        followers: documentSnapshot.get('followers') ?? [],
        uniAccountId: documentSnapshot.get('university_id') ?? '');
  }

  // get profile stream (based on university account id)
  Future<Stream<UniveristyProfile?>?> getProfileStream(String uniId) async {
    try {
      // get the university profile object from db based on logged in uni account doc id
      QuerySnapshot snapshot = await profileCollection
          .where('university_id', isEqualTo: uniId)
          .get();

      QueryDocumentSnapshot queryDocumentSnapshot =
          snapshot.docs.first; // get the only document from list

      // get the profile doc id
      String profileDocId = queryDocumentSnapshot.id;
/*
      // get the profile image of the university (if exists) (getting here because needs to show in home screen)
      final imagePath = await UniveristyProfile.withId(
                  profileDocId: profileDocId)
              .getProfileImagePath() ??
          ''; // set empty path if there is no image found i.e. null is returned
          */

      // return stream of type university profile object
      return profileCollection.doc(profileDocId).snapshots().map((snapshot) =>
          // _documentSnapshotToUniversityProfile(snapshot, imagePath!)
          _documentSnapshotToUniversityProfile(snapshot)
          );
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // snapshot to list of university profile objects
  List<dynamic>? _snaphshotToUniversityProfileList(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    try {
      // snapshot to university profile type objects and then all in a list return
      return snapshot.docs
          .map((doc) => UniveristyProfile(
              profileDocId: doc.id ?? '',
              profileImage: '',
              name: doc.get("name").toString() ?? '',
              location: doc.get("location").toString() ?? '',
              type: doc.get('type') ?? '',
              description: doc.get('description') ?? '',
              fieldsOffered: doc.get('fields_offered') ?? [],
              followers: doc.get('followers') ?? [],
              uniAccountId: doc.get('university_id') ?? ''))
          .toList();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // get all university profiles stream
  Stream<List<dynamic>?>? getUnisStream() {
    try {
      // return stream of list of university profiles
      return profileCollection
          .snapshots()
          .map((snapshot) => _snaphshotToUniversityProfileList(snapshot));
    } catch (e) {
      // print error
      print("ERR in getUnisStream: ${e.toString()}");
      return null;
    }
  }

  // update university followers list
  Future<String> updateFollowers() async {
    try {
      // update the university followers list
      await profileCollection
          .doc(profileDocId)
          .update({'followers': followers});

      return 'success';
    } catch (e) {
      // print error
      print("ERR in updateFollowers: ${e.toString()}");
      return 'error';
    }
  }

  // update university profile about
  Future<String> updateProfile() async {
    try {
      // update the university followers list
      await profileCollection.doc(profileDocId).update({
        'name': name,
        'description': description,
        'location': location,
        'type': type,
        'fields_offered': fieldsOffered
      });

      // if new profile image is selected
      if (profileImage.isNotEmpty) {
        // print('here');
        // update profile pic in storage
        // upload uni profile pic with the uni profile id as media file name
        final ref = storage.FirebaseStorage.instance
            .ref()
            .child('uni_profile_images')
            .child(
                profileDocId); // get the reference to the file in the uni_profile_images folder

        // print('ref: $ref');

        // check if image already exists at path then delete the image at path otherwosie upload new image
        try {
          final ref = storage.FirebaseStorage.instance
              .ref()
              .child('uni_profile_images')
              .child(profileDocId);

          // print('ref: $ref'); // to check what gets print when there is no image of this name : ref: Reference(app: [DEFAULT], fullPath: uni_profile_images/c4JoUpPtAvIYGcWZx6or.jpg)
          // print('here');
          final imageUrl = await ref.getDownloadURL();

          // if no error occured while getting download url means url is present then delete
          await ref.delete(); // delete the current object at path and
        } catch (e) {
          print('Image not deleted: $e');
        }

        // put new file at the reference after deleting if image is already present otherwise without deleting
        await ref.putFile(File(profileImage)); // put new file at the reference
      }

      return 'success';
    } catch (e) {
      // print error
      print("ERR in updateProfile: ${e.toString()}");
      return 'error';
    }
  }

/*
  // document snapshot to university object having followers list only
  _snapshotToUniFollowers(DocumentSnapshot<Map<String, dynamic>> snapshot){
    try {
      return UniveristyProfile.withFollowers(followers: snapshot.get('followers') ?? []);
    } catch (e) {
      print('Error in _snapshotToUniFollowers: $e');
      return null;
    }
  }

  // return stream of university followers
  Stream<UniveristyProfile>? getUniversityFollowersStream() {
    try {
      return profileCollection.doc(profileDocId).snapshots().map((snapshot) => _snapshotToUniFollowers(snapshot));
    } catch (e) {
      print('Error in getUniversityFollowerStream $e');
      return null;
    }
  }
  */
}
