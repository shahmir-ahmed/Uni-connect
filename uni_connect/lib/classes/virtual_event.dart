import 'package:cloud_firestore/cloud_firestore.dart';

class VirtualEvent {
  // attributes
  String? eventId;
  String? title;
  String? uniProfileId;
  String? status;

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
      required this.uniProfileId});

  VirtualEvent.onlyId({required this.eventId}); // only event id constructor

  // empty constructor
  VirtualEvent.empty();

  // create virtual event document
  Future<String> createVirtualEvent() async {
    try {
      final docRef = await virtualEventsCollection.add(
          {'title': title, 'status': 'live', 'uni_profile_id': uniProfileId});

      return docRef
          .id; // return doc id so that it can be used to update the status of stream when streamm ends
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
    return snapshot.docs
        .map((doc) => VirtualEvent(
            eventId: doc.id,
            title: doc.get('title') ?? '',
            status: doc.get('status') ?? '',
            uniProfileId: doc.get('uni_profile_id') ?? ''))
        .toList();
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
}
