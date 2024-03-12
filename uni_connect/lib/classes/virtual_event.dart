import 'package:cloud_firestore/cloud_firestore.dart';

class VirtualEvent {
  // attributes
  String? eventId;
  String? title;
  String? uniProfileId;
  String? status;
  List<dynamic>? comments;

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
      required this.comments});

  VirtualEvent.onlyId({required this.eventId}); // only event id constructor

  // empty constructor
  VirtualEvent.empty();

  // create virtual event document
  Future<String> createVirtualEvent() async {
    try {
      final docRef = await virtualEventsCollection.add({
        'title': title,
        'status': 'live',
        'uni_profile_id': uniProfileId,
        'comments': []
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
              comments: doc.get('comments') ?? []))
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
}
