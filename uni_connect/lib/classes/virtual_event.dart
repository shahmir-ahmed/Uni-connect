import 'package:cloud_firestore/cloud_firestore.dart';

class VirtualEvent {
  // attributes
  String? eventId;
  String? title;
  String? uniProfileId;
  String? status;
  List<dynamic>? comments;
  int? usersCount;

  final virtualEventsCollection =
      FirebaseFirestore.instance.collection('virtual_events'); // collection

  // methods
  // constructor
  VirtualEvent.withoutId(
      {required this.title, required this.status, required this.uniProfileId});

  VirtualEvent(
      {required this.eventId,
      required this.title,
      required this.status,
      required this.uniProfileId,
      required this.comments,
      required this.usersCount
      });

  VirtualEvent.onlyId({required this.eventId}); // only event id constructor

  VirtualEvent.onlyComments(
      {required this.comments}); // only comments constructor

  VirtualEvent.onlyUsersCount(
      {required this.usersCount}); // only users count constructor

  VirtualEvent.onlyStatus(
      {required this.status}); // only status count constructor

  // empty constructor
  VirtualEvent.empty();

  // create virtual event document
  Future<String> createVirtualEvent() async {
    try {
      final docRef = await virtualEventsCollection.add({
        'title': title,
        'status': 'live',
        'uni_profile_id': uniProfileId,
        'comments': [],
        'users_count': 0
      });

      return docRef
          .id; // return doc id so that it can be used to update the status of stream when stream ends
    } catch (e) {
      print('Error in createVirtualEvent: $e');
      return 'error';
    }
  }

  // end virtual event
  // update document's virtual event status as ended
  updateVirtualEventStatus() async {
    try {
      // update the event status
      await virtualEventsCollection.doc(eventId).update({'status': 'ended'});

      return 'success';
    } catch (e) {
      print('Error in updateVirtualEventStatus: $e');
      return 'error';
    }
  }

  // virtual events documents collection snapshot to list of type virtual event objects
  _snapshotToVirtualEventsList(QuerySnapshot<Map<String, dynamic>> snapshot) {
    try {
      return snapshot.docs
          .map((doc) => VirtualEvent(
              eventId: doc.id,
              title: doc.get('title') ?? '',
              status: doc.get('status') ?? '',
              uniProfileId: doc.get('uni_profile_id') ?? '',
              comments: doc.get('comments') ?? [],
              usersCount: doc.get('users_count') ?? 0
              ))
          .toList();
    } catch (e) {
      print('Error in _snapshotToVirtualEventsList $e');
    }
  }

  // return stream of list type virtual event objects
  Stream<List<VirtualEvent>>? getVirtualEventsStream() {
    try {
      return virtualEventsCollection
          .snapshots()
          .map((snapshot) => _snapshotToVirtualEventsList(snapshot));
    } catch (e) {
      print('Error in getVirtualEventsStream: $e');
      return null;
    }
  }

  // virtual event document snapshot to virtual event object having comments only
  _snapshotToVirtualEventComment(snapshot) {
    try {
      return VirtualEvent.onlyComments(
          comments: snapshot.get('comments') ?? []);
    } catch (e) {
      print('Error in _snapshotToVirtualEvent $e');
    }
  }

  // return stream of type virtual event object having comments only
  Stream<VirtualEvent>? getVirtualEventCommentsStream() {
    try {
      return virtualEventsCollection
          .doc(eventId)
          .snapshots()
          .map((snapshot) => _snapshotToVirtualEventComment(snapshot));
    } catch (e) {
      print('Error in getVirtualEventCommentsStream: $e');
      return null;
    }
  }


  // add new comment
  Future<String> comment() async {
    try {
      // update the comments field on this document
      await virtualEventsCollection.doc(eventId).update({'comments': comments});
      return 'success';
    } catch (e) {
      print('Error in comment(): $e');
      return 'error';
    }
  }

  // increment users count
  Future<String> incrementUser() async {
    try {
      // increase the user count by 1
      await virtualEventsCollection.doc(eventId).update({'users_count': FieldValue.increment(1)});
      return 'success';
    } catch (e) {
      print('Error in incrementUser(): $e');
      return 'error';
    }
  }

  // decrement users count
  Future<String> decrementUser() async {
    try {
      // decrease the user count by 1
      await virtualEventsCollection.doc(eventId).update({'users_count': FieldValue.increment(-1)});
      return 'success';
    } catch (e) {
      print('Error in decrementUser(): $e');
      return 'error';
    }
  }
  
  // virtual event document snapshot to virtual event object having users count only
  _snapshotToVirtualEventUsers(snapshot) {
    try {
      return VirtualEvent.onlyUsersCount(
          usersCount: snapshot.get('users_count') ?? 0);
    } catch (e) {
      print('Error in _snapshotToVirtualEventUsers $e');
    }
  }

  // return stream of type virtual event object having comments only
  Stream<VirtualEvent>? getVirtualEventUsersStream() {
    try {
      return virtualEventsCollection
          .doc(eventId)
          .snapshots()
          .map((snapshot) => _snapshotToVirtualEventUsers(snapshot));
    } catch (e) {
      print('Error in getVirtualEventUsersStream: $e');
      return null;
    }
  }
}
