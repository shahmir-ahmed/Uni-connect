import 'package:cloud_firestore/cloud_firestore.dart';

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
        return 'Valid';
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

        // create university profile document with university account document id
        String? result = await uniProfile.createProfile(docId);

        // profile successfully created
        if (result == 'success') {
          return 'success';
        }
        // error creating profile
        else if(result==null){
          return null;
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

  // university profile collection
  final profileCollection =
      FirebaseFirestore.instance.collection('university_profiles');

  // constructor for when registering university account
  UniveristyProfile.forRegister(
      {required this.name, required this.location, required this.type});

  // for profile
  UniveristyProfile(
      {this.name = '',
      this.location = '',
      this.type = '',
      this.description = ''});

  // create profile in database (when registering)
  Future<String?> createProfile(String uniDocId) async {
    try {
      // create university profile document with id as university account document id
      await profileCollection.doc(uniDocId).set({
        'name': name,
        'description': "",
        'location': location,
        'type': type,
        'fields_offered': [],
      });

      return 'success'; // succes message
    } catch (e) {
      print("EXCEPTION: ${e.toString()}");
      return null;
    }
  }

  // get profile stream
}
