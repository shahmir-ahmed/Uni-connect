import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;

// University class
class University {
  String username;
  String password;

  // university accounts collection (creates cllection if not already exists)
  final universityCollection =
      FirebaseFirestore.instance.collection('universities');

  // constructor
  University({required this.username, required this.password});

  // login
  Future<String?> login() async {
    try {
      // check if account with the username and passowrd exists or not
      QuerySnapshot snapshot = await universityCollection
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
      QuerySnapshot snapshot = await universityCollection
          .where('username', isEqualTo: username)
          .get();

      // if no doc found with the username
      if (snapshot.docs.isEmpty) {
        // register university account
        // create university account document
        DocumentReference documentReference = await universityCollection
            .add({'username': username, 'password': password});

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

  // university profile collection
  final profileCollection =
      FirebaseFirestore.instance.collection('university_profiles');

  // constructor for when registering university account
  UniveristyProfile.forRegister(
      {required this.name, required this.location, required this.type});

  // empty constructor
  UniveristyProfile.empty();

  // for profile
  UniveristyProfile(
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
  Future getProfileImagePath(String imageName) async {
    try {
      final ref = storage.FirebaseStorage.instance
          .ref()
          .child('uni_profile_images')
          .child(imageName);

      // print('ref: $ref'); // to check what gets print when there is no image of this name : ref: Reference(app: [DEFAULT], fullPath: uni_profile_images/c4JoUpPtAvIYGcWZx6or.jpg)
      // print('here');
      final imageUrl = await ref
          .getDownloadURL(); // get the image path // error is here of object not found so null is returned in catch block

      // print('imageurl: $imageUrl');

      return imageUrl;
    } catch (e) {
      print("Err in retrieving image: ${e.toString()}");
      return null;
    }
  }

  // document snapshot to university profile object
  UniveristyProfile _documentSnapshotToUniversityProfile(
      DocumentSnapshot documentSnapshot, String imagePath) {
    // return profile object with all the details set
    return UniveristyProfile(
        profileDocId: documentSnapshot.id,
        profileImage: imagePath,
        name: documentSnapshot.get('name'),
        location: documentSnapshot.get('location'),
        type: documentSnapshot.get('type'),
        description: documentSnapshot.get('description'),
        fieldsOffered: documentSnapshot.get('fields_offered') ?? []);
  }

  // get profile stream
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

      // get the profile image of the university (if exists) (getting here because needs to show in home screen)
      final imagePath = await getProfileImagePath(profileDocId) ??
          ''; // set empty path if there is no image found i.e. null is returned

      // return stream of type university profile object
      return profileCollection.doc(profileDocId).snapshots().map((snapshot) =>
          _documentSnapshotToUniversityProfile(snapshot, imagePath!));
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
          .map((doc) => UniveristyProfile.forSearch(
              profileDocId: doc.id ?? '',
              profileImage: '',
              name: doc.get("name").toString(),
              location: doc.get("location").toString()))
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
  String? updateFollowers() {
    try {
      // update the university followers list
      return 'success';
    } catch (e) {
      // print error
      print("ERR in updateFollowers: ${e.toString()}");
      return null;
    }
  }
}
