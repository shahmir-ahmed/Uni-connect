import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;

// Student class
class Student {
  String? id;
  String? email;
  String password;

  // student accounts collection (creates cllection if not already exists)
  final studentsCollection = FirebaseFirestore.instance.collection('students');

  // constructor
  Student({required this.email, required this.password});

  Student.withIdPassword({required this.id, required this.password});

  // login
  Future<String?> login() async {
    try {
      // check if account with the username and passowrd exists or not
      QuerySnapshot snapshot = await studentsCollection
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
        // return 'Valid';
        return snapshot.docs.first.id; // return the student doc id
      }
    } catch (e) {
      print("EXCEPTION: ${e.toString()}");
      // print('HERE');
      return null;
    }
  }

  // register
  Future<String?> register(StudentProfile studentProfile) async {
    try {
      // check account with the username already exists or not
      QuerySnapshot snapshot =
          await studentsCollection.where('username', isEqualTo: email).get();

      // if no doc found with the username
      if (snapshot.docs.isEmpty) {
        // register new student
        // create student account document
        DocumentReference documentReference = await studentsCollection
            .add({'username': email, 'password': password});

        // get the newly created document id
        String docId = documentReference.id;

        // create student profile document with, student account document id as id of profile document
        String? result = await studentProfile.createProfile(docId);

        // profile successfully created
        if (result == 'success') {
          // return 'success'; // success
          return docId; // doc id
        }
        // error creating profile
        else if (result == null) {
          return null;
        }
      } else {
        // account with the username already exists
        return 'exists';
      }
    } catch (e) {
      print("EXCEPTION in student register() method: ${e.toString()}");
      return null;
    }
  }

  // update password using id
  Future<String> updatePassword() async {
    try {
      await studentsCollection.doc(id).update({'password': password});
      return 'success';
    } catch (e) {
      print('Err in updatePassword(): ${e.toString()}');
      return 'error';
    }
  }
}

// Student Profile class
class StudentProfile {
  // student profile attributes
  late String profileDocId;
  late String profileImageUrl;
  late String name;
  late String gender;
  late String college;
  late List<dynamic> fieldsOfInterest;
  late List<dynamic> uniLocationsPreferred;

  // following unis list
  late List<dynamic> followingUnis;

  // saved unis list
  List<dynamic>? savedUnis;

  // student profile collection
  final profileCollection =
      FirebaseFirestore.instance.collection('student_profiles');

  // constructor required when registering student account
  StudentProfile.forRegister({required this.name, required this.college});

  // for profile
  StudentProfile({
    required this.profileDocId,
    required this.name,
    required this.college,
    required this.gender,
    required this.fieldsOfInterest,
    required this.uniLocationsPreferred,
    required this.followingUnis,
    required this.profileImageUrl,
  });

  // empty const.
  StudentProfile.empty();

  // const. for unis student is following
  StudentProfile.followingUnis({required this.followingUnis});

  // with id only
  StudentProfile.withId({required this.profileDocId});

  // with fields of interest and following unis only (for recommeding unis)
  StudentProfile.withFieldsAndFollowing(
      {required this.fieldsOfInterest, required this.followingUnis});

  // for updating profile constructor
  // for profile
  StudentProfile.forUpdateProfile(
      {required this.profileDocId,
      required this.profileImageUrl,
      required this.name,
      required this.gender,
      required this.college,
      required this.fieldsOfInterest});

  // for saved unis list screen
  StudentProfile.forSavedAndFollowingUnisList(
      {required this.profileDocId,
      required this.savedUnis,
      required this.followingUnis});

  // for save new list in edit list screen
  StudentProfile.withIdAndSavedUnisList({
    required this.profileDocId,
    required this.savedUnis,
  });

  // create student profile in database (when registering)
  Future<String?> createProfile(String studentDocId) async {
    try {
      // create student profile document with id as student account document id
      await profileCollection.doc(studentDocId).set({
        'name': name,
        'gender': "",
        'college': college,
        'fields_of_interest': [],
        'uni_locations_preferred': [],
        'following_unis': [],
        'saved_unis': [],
      });

      return 'success'; // success message
    } catch (e) {
      print("EXCEPTION in createProfile: ${e.toString()}");
      return null;
    }
  }

  // profile snapshot to object
  List<dynamic>? _snaphshotToFollowingUnisList(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    try {
      // snapshot to university profile type objects and then all in a list return
      // print(snapshot.data());
      return snapshot.get("following_unis");
    } catch (e) {
      print("ERR in _snaphshotToFollowingUnisList: ${e.toString()}");
      return null;
    }
  }

  // get following unis stream for a specific student (can be used as get profile stream)
  Stream<List<dynamic>?>? getFollowingUnisStream() {
    try {
      // print("profileDocId in getFollowingUnisStream: $profileDocId");
      // return the stream if profile id is passed (this happens when id is fetched from shared pref when this function is called )
      // if(profileDocId!=null){
      // return stream of profile of a specific student
      return profileCollection
          .doc(profileDocId)
          .snapshots()
          .map((snapshot) => _snaphshotToFollowingUnisList(snapshot));
      // }
    } catch (e) {
      // print error
      print("ERR in getProfileStream: ${e.toString()}");
      return null;
    }
  }

  // update the student's following list
  Future<String> followUnFollowUni(dynamic followingList) async {
    try {
      // set the new following list on the student's document following_unis field by update method to merge with any existing data in the document
      await profileCollection
          .doc(profileDocId)
          .update({'following_unis': followingList});

      return "success";
    } catch (e) {
      // print error
      print("ERR in followUnFollowUni: ${e.toString()}");
      return "error";
    }
  }

  // student profile doc snapshot to student profile type object
  StudentProfile? _snapshotToStudentProfileObject(doc) {
    try {
      return StudentProfile(
        profileDocId: doc.id,
        name: doc.get('name') ?? '',
        college: doc.get('college') ?? '',
        gender: doc.get('gender') ?? '',
        fieldsOfInterest: doc.get('fields_of_interest') ?? [],
        followingUnis: doc.get('following_unis') ?? [],
        uniLocationsPreferred: doc.get('uni_locations_preferred') ?? [],
        profileImageUrl: '',
      );
    } catch (e) {
      // print error
      print("ERR in _snapshotToStudentProfileObject: ${e.toString()}");
      return null;
    }
  }

  // get student profile stream
  Stream<StudentProfile?>? getStudentProfileStream() {
    try {
      return profileCollection
          .doc(profileDocId)
          .snapshots()
          .map((snapshot) => _snapshotToStudentProfileObject(snapshot));
    } catch (e) {
      // print error
      print("ERR in getStudentProfileStream: ${e.toString()}");
      return null;
    }
  }

  // update profile method
  Future<String> updateProfile() async {
    try {
      // update the university followers list
      await profileCollection.doc(profileDocId).update({
        'name': name,
        'gender': gender,
        'college': college,
        'fields_of_interest': fieldsOfInterest
      });

      // if new profile image is selected
      if (profileImageUrl.isNotEmpty) {
        print('here');
        // update profile pic in storage
        // upload student profile pic with the student profile id as media file name
        final ref = storage.FirebaseStorage.instance
            .ref()
            .child('student_profile_images')
            .child(
                profileDocId); // get the reference to the file in the uni_profile_images folder

        // print('ref: $ref');

        // check if image already exists at path then delete the image at path otherwosie upload new image
        try {
          // print('ref: $ref'); // to check what gets print when there is no image of this name : ref: Reference(app: [DEFAULT], fullPath: uni_profile_images/c4JoUpPtAvIYGcWZx6or.jpg)
          // print('here');
          final imageUrl = await ref.getDownloadURL();

          // if no error occured while getting download url means url is present then delete
          await ref.delete(); // delete the current object at path and
        } catch (e) {
          print('Image not deleted: $e');
        }

        // put new file at the reference after deleting if image is already present otherwise without deleting
        await ref
            .putFile(File(profileImageUrl)); // put new file at the reference
      }

      return 'success';
    } catch (e) {
      // print error
      print("ERR in updateProfile: ${e.toString()}");
      return 'error';
    }
  }

  // get and return student profile image for student home screen
  Future<String> getProfileImage() async {
    try {
      // get profile image path from storage
      // check if image already exists at path then set the image path
      final ref = storage.FirebaseStorage.instance
          .ref()
          .child('student_profile_images')
          .child(profileDocId);

      // print('ref: $ref'); // to check what gets print when there is no image of this name : ref: Reference(app: [DEFAULT], fullPath: uni_profile_images/c4JoUpPtAvIYGcWZx6or.jpg)
      // print('here');
      final imageUrl = await ref.getDownloadURL();

      // if no error occured while getting download url means url is present then set
      return imageUrl; // set the image oath on the profile image of this object
    } catch (e) {
      // print error
      print("ERR in getProfileImage: ${e.toString()}");
      return 'error';
    }
  }

  // get student name for student home screen
  Future<String> getName() async {
    try {
      // get name field using doc id
      name = await profileCollection
          .doc(profileDocId)
          .get()
          .then((snapshot) => snapshot.get('name'));

      return name;
    } catch (e) {
      // print error
      print("ERR in getName: ${e.toString()}");
      return 'error';
    }
  }

  // student profile doc snapshot to student profile type object having saved unis list only
  StudentProfile? _snapshotToSavedAndFollowingUnisListObject(doc) {
    try {
      return StudentProfile.forSavedAndFollowingUnisList(
          profileDocId: doc.id,
          savedUnis: doc.get('saved_unis'),
          followingUnis: doc.get('following_unis'));
    } catch (e) {
      // print error
      print(
          "ERR in _snapshotToSavedAndFollowingUnisListObject: ${e.toString()}");
      return null;
    }
  }

  // get student saved unis list and following unis stream
  Stream<StudentProfile?>? getSavedAndFollowingUnisListStream() {
    try {
      return profileCollection.doc(profileDocId).snapshots().map(
          (snapshot) => _snapshotToSavedAndFollowingUnisListObject(snapshot));
    } catch (e) {
      // print error
      print("ERR in getSavedUnisListStream: ${e.toString()}");
      return null;
    }
  }

  // update saved unis list in db
  Future updateSavedUnisList() async {
    try {
      await profileCollection
          .doc(profileDocId)
          .update({'saved_unis': savedUnis});
      return 'success';
    } catch (e) {
      print('Err in updateSavedUnisList: $e');
      return 'error';
    }
  }
}
