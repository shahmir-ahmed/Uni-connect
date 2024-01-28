import 'package:cloud_firestore/cloud_firestore.dart';

// Student class
class Student {
  String username;
  String password;

  // student accounts collection (creates cllection if not already exists)
  final studentsCollection = FirebaseFirestore.instance.collection('students');

  // constructor
  Student({required this.username, required this.password});

  // login
  Future<String?> login() async {
    try {
      // check if account with the username and passowrd exists or not
      QuerySnapshot snapshot = await studentsCollection
          .where('username', isEqualTo: username)
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
          await studentsCollection.where('username', isEqualTo: username).get();

      // if no doc found with the username
      if (snapshot.docs.isEmpty) {
        // register new student
        // create student account document
        DocumentReference documentReference = await studentsCollection
            .add({'username': username, 'password': password});

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
      print("EXCEPTION: ${e.toString()}");
      return null;
    }
  }
}

// Student Profile class
class StudentProfile {
  // student profile attributes
  late String name;
  late String gender;
  late String college;
  late String fieldsOfInterest;
  late String uniLocationsPreferred;
  late String profileDocId;

  // following unis list
  late List<dynamic> followingUnis;

  // student profile collection
  final profileCollection =
      FirebaseFirestore.instance.collection('student_profiles');

  // constructor required when registering student account
  StudentProfile.forRegister({required this.name, required this.college});

  // for profile
  StudentProfile(
      {required this.name,
      required this.college,
      required this.gender,
      required this.fieldsOfInterest,
      required this.uniLocationsPreferred});

  // empty const.
  StudentProfile.empty();

  // const. for unis student is following
  StudentProfile.followingUnis({required this.followingUnis});

  // with id
  StudentProfile.withId({required this.profileDocId});

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
      });

      return 'success'; // success message
    } catch (e) {
      print("EXCEPTION: ${e.toString()}");
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
  Stream<List<dynamic>?>? getFollowingUnisStream(profileDocId) {
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

  // add the university profile id in student's following list
  // update the student's following list
  String followUnFollowUni(dynamic followingList) {
    try {
      // set the new following list on the student's document following_unis field by update method to merge with any existing data in the document
      profileCollection
          .doc(profileDocId)
          .update({'following_unis': followingList});

      return "success";
    } catch (e) {
      // print error
      print("ERR in followUnFollowUni: ${e.toString()}");
      return "error";
    }
  }
}
